  #   SEIR-Model - COVID-19 - Germany pre lockdown 2020
  #   S ->(beta) E ->(alpha) I ->(gamma) R
  #   R0 = beta/gamma
  #   start: Mar-1-2020
  #   data source: https://www.worldometers.info/coronavirus/country/germany/
  #   template from https://de.wikipedia.org/wiki/SEIR-Modell
  #   (c) MMXX by caes
    
from numpy import array as vect   
import requests
import re
from math import log
from data import neu

  # switches, slobals 
Tmax=20; NN = 83000000; DZ=7
R00=5.5; gamma00=1/4.0; alpha00=1/4.0; beta00=R00*gamma00; I00=114.0*DZ/NN; E00=1.55*I00
 
  # estimated daily new infections   
neu_prognos=[]    
sum=[16]  
for k in range(1, len(neu)):
  sum.append(sum[k-1]+neu[k]) 
  
  # calc real I   
I_emp=[0,0,0,0,0,0,114*DZ] 
for k in range(7, len(neu)):
  I_emp.append(DZ*(sum[k]-sum[k-7]))   
  
  # timing...
vonhinten=len(neu)-6 ; tt=range(0,vonhinten); I_emp = I_emp[-vonhinten:] 

  # root mean square (relative)
def getRMS(sim): 
    t,x = zip(*sim())
    S,E,I,R = zip(*x) 
    rms=0.0
    for i in range(0,4): 
      rms = rms + (1-I_emp[i]/I[10*i])**2 
    rms = rms/(4)
    return rms  
    
def euler_method(f,t0,x0,t1,h):
    t = t0; x = x0; a = [[t,x*NN]]
    for k in range(0,1+int((t1-t0)/h)):
        t = t0 + k*h
        x = x + h*f(t,x)
        a.append([t,x*NN])
    return a

def SEIR_model(beta,gamma,alpha):
    def f(t,x):
        S,E,I,R = x
        return vect([-beta*S*I, beta*S*I-alpha*E, alpha*E-gamma*I, gamma*I ])
    return f

def SEIR_sim(beta,gamma,alpha,E0,I0,days,step=0.1):
    x0 = vect([1.0-E0-I0,E0,I0,0.0])
    return euler_method(SEIR_model(beta,gamma,alpha),0,x0,days,step)

def diagram(sim):
    import matplotlib.pyplot as plt
    plt.style.use('classic')
    II = I_emp[-vonhinten:]
    figure,ax = plt.subplots(facecolor="#ffffff")
    ax.set_xlim(0, Tmax); #ax.set_ylim(0,4.5e5)
    ax.grid(linestyle='-', linewidth=0.5, color="#888888")
    ax.grid(axis='y', which='major', linestyle='-', linewidth=0.5, color="#888888")
    
    t,x = zip(*sim())
    S,E,I,R = zip(*x) 
    for k in range(0,70): # daily new prognosis
      neu_prognos.append(0.0)  # dummy
    for k in range(70,len(S)):
        neu_prognos.append(beta00*S[k-70]*I[k-70]/NN/DZ)
    
    #ax.semilogy(t,E, color="#ffb000", linestyle='--', label='E_xposed')
    ax.semilogy(t,I,  color="#a00000", linewidth=3,    label='I_nfectious, model')
    #ax.semilogy(t,R, color="#008000", linewidth=3,    label='R_ecovered')    
    ax.semilogy(tt,II, color="#555555", linewidth=1.5,  linestyle=':', marker='.', markersize=10, label='I_nfectious, empiric', alpha=1.8)
    ax.semilogy(tt,neu[-vonhinten:], color="#000000", linewidth=1.5,  linestyle=':', marker=',', markersize=10, label='daily new, reported', alpha=1.8)
    ax.semilogy(t[71:],neu_prognos[71:], color="#ff8800", linewidth=3,  label='daily new, prognos')
    plt.title("Covid19 - Germany - SEIR-Model - t0=1.3.20 - (c) caes\nDZ={0:.1f}  R0={1:.2f}  1/gamma={2:.2f}  1/alpha={3:.2f}  MSE={4:.2E}".format(DZ, R00, 1/gamma00, 1/alpha00, rms1))
    plt.legend(loc='best'); plt.ylabel('N = 83 Mio'); plt.xlabel('days')
    
    damp = I[90]/I[100] # halfing time I
    tau = -1/log(damp)
    T2 = -tau*log(0.5)  
    SI = 0.5/gamma00+1/alpha00  # serial interval
    Rt = []   # time variant reproduction
    for k in range(0, len(I)-1):
      Rt.append(1+10*SI*(I[k+1]/I[k]-1))
    Rt_akt=Rt[90]
    iax=figure.add_axes([.68, .2, .2, .1], facecolor='w')
    iax.plot(t[0:len(Rt)],Rt, color="#006070", linewidth=2)   
    iax.set_ylim(2, 4); iax.set_yticks([2,3,4]); iax.set_title('Rt') 

    print('[R0 Rt_akt SI T2 MSE] = ', R00, Rt_akt, SI, T2, rms1) 
    
    plt.show()

def sim1():
    R0 = R00; gamma = gamma00
    return SEIR_sim(
        beta = R0*gamma, gamma = gamma, alpha = alpha00,
        E0 = E00, I0 = I00, days = Tmax)
        
  ## And here we go
  ## Fitting Section
faktor=1.001; switches=0  ### alpha00
while switches<3:
  rms0=getRMS(sim1)
  alpha00*=faktor
  rms1=getRMS(sim1)
  if rms1>rms0:   # getting worse
    faktor=1/faktor
    switches+=1 
  
faktor=1.001; switches=0  ### gamma00
while switches<3:
  rms0=getRMS(sim1)
  gamma00*=faktor
  rms1=getRMS(sim1)
  if rms1>rms0:   # getting worse
    faktor=1/faktor
    switches+=1  
    
"""
faktor=1.0001; switches=0  ### R00
while switches<2:
  rms0=getRMS(sim1)
  R00=R00*faktor
  rms1=getRMS(sim1)
  if rms1>rms0:   # getting worse
    faktor=1/faktor
    switches+=1 """
    
## so far, so good, so plot
diagram(sim1)