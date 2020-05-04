  #   SEIR-Model - Country in lockdown 2020
  #   S ->(beta) E ->(alpha) I ->(gamma) R
  #   R0 = beta/gamma
  #   template from https://de.wikipedia.org/wiki/SEIR-Modell
  #   (c) MMXX by caes
    
from numpy import array as vect   
import numpy as np
from math import log
from data import neu, country, NN
import datetime

  # mission control
Tmax=42; DZ=10; R00=0.581; gamma00=1/4.073; alpha00=1/4.5

  # estimated daily new infections   
neu_prognos=[]; neu_geomean=[]

  # 7d geometric mean
for k in range(0, len(neu)-3):
  if k<3:
    neu_geomean.append(neu[k]/NN)
  else: 
    neu_geomean.append((neu[k-3]*neu[k-2]*neu[k-1]*neu[k]*neu[k+1]*neu[k+2]*neu[k+3])**(1/7)/NN)
  
  # sum
sum=[16]  
for k in range(1, len(neu)):
  sum.append(sum[k-1]+neu[k]) 
  
  # calc real I   
I_emp=[0,0,0,0,0,0] 
for k in range(6, len(neu)):
  I_emp.append(DZ*(sum[k]-sum[k-6]))   

  # timing
t0=datetime.date(2020,2,24); t1=datetime.date(2020,4,1)
vonhinten=len(neu)-(t1-t0).days ; tt=range(0,vonhinten); I_emp = I_emp[-vonhinten:] 

  # inits
I00=1.07*I_emp[0]/NN; E00=1.11*I00; Rec00=I00/2

  # shrink array
def mult(x, n):
    a=[]
    for i in range(0, len(x)): 
      a.append(x[i]*n)
    return a
        
  # root mean square (relative)
def getRMS(sim): 
    t,x = zip(*sim())
    S,E,I,R = zip(*x) 
    rms=0.0
    for i in tt: 
      rms = rms + (1-I_emp[i]/I[10*i])**2 
    rms = (rms/vonhinten)
    return rms  

  # Leonhard Euler said, "Now I will have less distraction", upon losing the use of his right eye.
def euler_method(f,t0,x0,t1,h):
    t = t0; x = x0; a = [[t,x]]
    for k in range(0,1+int((t1-t0)/h)):
        t = t0 + k*h
        x = x + h*f(t,x)
        a.append([t,x])
    return a

def SEIR_model(beta,gamma,alpha):
    def f(t,x):
        S,E,I,R = x
        return vect([-beta*S*I, beta*S*I-alpha*E, alpha*E-gamma*I, gamma*I ])
    return f

def SEIR_sim(beta,gamma,alpha,E0,I0,days,step=0.1):
    x0 = vect([1.0-E0-I0,E0,I0,Rec00])  # init state
    return euler_method(SEIR_model(beta,gamma,alpha),0,x0,days,step)

def sim1():
    R0 = R00; gamma = gamma00
    return SEIR_sim(
      beta = R0*gamma, gamma = gamma, alpha = alpha00,
      E0 = E00, I0 = I00, days = Tmax)
        
def diagram(sim):
    import matplotlib.pyplot as plt
    global I_emp, neu, sum; neu_prognos=[]
    plt.style.use("classic")
    figure,ax = plt.subplots(facecolor="#ffffff", figsize=(16,12))
    ax.set_xlim(0, Tmax); 
    ax.grid(linestyle="-", linewidth=0.5, color="#888888")
    ax.grid(axis="y", which="major", linestyle="-", linewidth=0.5, color="#888888") 
    t,x = zip(*sim())
    S,E,I,R = zip(*x) 
    for k in range(0,len(S)):
      neu_prognos.append(beta00*S[k]*I[k]/NN/DZ)
    neu=mult(neu, 1/NN); sum=mult(sum, DZ/NN); neu_prognos=mult(neu_prognos, NN)
    ax.semilogy(t,E, color="#ffb000", linestyle="--", label="E_xposed")
    ax.semilogy(t,I, color="#a00000", linewidth=3, label="I_nfectious")
    ax.semilogy(t,R, color="#008000", linewidth=3, label="R_ecovered")    
    ax.semilogy(tt,I_emp[-vonhinten:], color="#555555", linewidth=1.5, linestyle=":", marker=".", markersize=12, label="I, empiric", alpha=1)
    ax.semilogy(t[0:],neu_prognos[0:], color="#ff8800", linewidth=3, label="daily new, prognosis")
    ax.semilogy(tt,neu[-vonhinten:], color="#000000", linewidth=1.5, linestyle=":", marker=",", markersize=10, label="daily new, reported", alpha=1)
    ax.semilogy(tt[:-3],neu_geomean[-(vonhinten-3):], color="#000000", linewidth=1.5, linestyle="-", marker=",", markersize=10, label="daily new, geomean7", alpha=1)
    ax.semilogy(tt,sum[-vonhinten:], color="#000000", linewidth=1.0, linestyle="--", marker=",", markersize=10, label="sum, reported", alpha=1)

    plt.legend(loc="best")
    plt.ylabel("N = " + str(round(NN/1e6)) + " Mio")
    plt.xlabel("days")
    plt.xticks(np.linspace(0, Tmax, int(Tmax/7)+1))
    plt.title("Covid19 - "+country+" - SEIR-Model\n t0=1.4.20 - DZ={0:.1f} - (c) caes".format(DZ))

    damp = I[len(I_emp)*10]/I[len(I_emp)*10-10] # halfing time I
    tau = -1/log(damp)
    T2 = -tau*log(0.5)  
    SI = 0.5/gamma00+1/alpha00  # serial interval
    Rt=[1]   # time variant reproduction
    Rt_emp=[1]
    for k in range(10, len(I)):
      Rt.append((I[k]/I[k-10]))
    for k in range(1, len(I_emp)): 
      Rt_emp.append((I_emp[k]/I_emp[k-1]))
    Rt_akt=Rt[10*len(I_emp)]
    iax=figure.add_axes([.68, .35, .21, .14], facecolor="w", xlim=[0,Tmax])
    iax.plot(t[0:len(Rt)],[1 for _ in Rt], color="#000000", linewidth=0.5)   
    iax.plot(t[0:len(Rt)],Rt, color="#006070", linewidth=0.5)   
    iax.plot(range(0, len(Rt_emp)),Rt_emp[-vonhinten:], color="#006070", linewidth=2)
    iax.set_ylim(0.8,1.2); iax.set_yticks([0.9,1.0,1.1]); iax.set_title("Rt_1d"); iax.set_xticks([7,14,21,28])

    print("[Rt_1d  Rt_SI  Rt_4d]       = {0:.4f} {1:.4f} {2:.4f}".format(Rt_akt, Rt_akt**SI, Rt_akt**4))
    print("[SI     T2     MSE]         = {0:.4f} {1:.3f} {2:.4e}".format(SI, T2, rms1)) 
    print("[R0 1/beta 1/alpha 1/gamma] = {0:.4f} {1:.4f} {2:.4f} {3:.4f}".format(R00, 1/(R00*gamma00), 1/alpha00, 1/gamma00))
    
    plt.show()

  ## And here we go
  ## Fitting Section  
I_emp=mult(I_emp, 1/NN);  

faktor=1.002; switches=0  ### optimize alpha00
while switches<3:
  rms0=getRMS(sim1)
  alpha00=alpha00*faktor
  rms1=getRMS(sim1)
  if rms1>rms0:   # getting worse
    faktor=1/faktor
    switches+=1
"""faktor=1.002; switches=0  ### optimize R00
while switches<3:
  rms0=getRMS(sim1)
  R00=R00*faktor
  rms1=getRMS(sim1)
  if rms1>rms0:   # getting worse
    faktor=1/faktor    
    switches+=1"""
"""faktor=1.002; switches=0  ### optimize gamma00
while switches<3:
  rms0=getRMS(sim1)
  gamma00=gamma00*faktor
  rms1=getRMS(sim1)
  if rms1>rms0:   # getting worse
    faktor=1/faktor
    switches+=1"""
 
  ## so far, so good, so plot
beta00=R00*gamma00 # doppelte Buchfuehrung fuer neu_prognos  
rms1=getRMS(sim1)
diagram(sim1)