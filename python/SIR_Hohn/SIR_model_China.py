#SIR_model.py for Germany

import numpy as np
import scipy.optimize as opt

import matplotlib.pyplot as plt
from pylab import *
import matplotlib.colors as mcolors
from scipy.optimize import curve_fit
import math
from scipy.stats import norm
import matplotlib.mlab as mlab
import scipy.special as sp

# data:
data_file="./Corona_infections_Hubei.txt"
Cinf = np.genfromtxt(data_file,skip_header=0,filling_values=-999.,delimiter="\t")

data_file="./Corona_deaths_Hubei.txt"
Cdead = np.genfromtxt(data_file,skip_header=0,filling_values=-999.,delimiter="\t")

data_file="./Corona_recovered_Hubei.txt"
Crec = np.genfromtxt(data_file,skip_header=0,filling_values=-999.,delimiter="\t")



P=72000.0 # population size of the province Hubei according to Wikipedia
#P=55800000.0 # population size of the province Hubei according to Wikipedia

# parameters: constrained
b= 0.009019 * 1.0/360.0 # birth rate (per year) 
#theta= 0.003024 * 1.0/360.0 # immigration rate of susceptible (people per day)
theta=0.0 # due to closed borders
d= 0.010615 * 1.0/360.0 # death rate of healthy individuals (per year)



# parameters: unconstrained
# infection dynamics:
a= 0.031 # probability that the disease is transmitted upon contact
c=11.0/P # contact rate per susceptible individual

# recovery and mortality
#delta= 0.033 # death rate of infected individuals # based on Chinese data
delta= 0.003 # death rate of infected individuals # based on GERMAN data


#rho= 0.02 # recovery rate for infected individuals
#rho= 0.08 # recovery rate for infected individuals
rho= 0.01 # recovery rate for infected individuals

# immunity or not?
sigma= 0.0 # rate of recovered individuals that become susceptible for reinfection

# initialization
tmax=70
dt=1.0

S=np.zeros(tmax)
I=np.zeros(tmax)
R=np.zeros(tmax)
D=np.zeros(tmax)
time=np.arange(0,tmax,1)


S[0]=P
I[0]=444.0
R[0]=0.0

for i in range(tmax-1):
    if i>11:
        c=7.0/P
        if i>21:
            rho=0.03
            if i>32:
                rho=0.065
                delta= 0.002
                
    
    # susceptible fraction of population
    dSdt= sigma*R[i] - a*c*S[i]*I[i]
    # infected fraction of population
    dIdt=a*c*S[i]*I[i] - delta*I[i] - rho*I[i]
    # recovered fraction of population
    dRdt=rho*I[i] - sigma*R[i] - d*R[i]
    
    S[i+1]=S[i]+dSdt*dt
    I[i+1]=I[i]+dIdt*dt
    R[i+1]=R[i]+dRdt*dt
    D[i+1]=D[i]+delta*I[i]*dt
    



plt.figure(1)
#plt.plot(time,S,'b',label='susceptible')
plt.plot(time,I+R,'r',label='infected')
plt.plot(time,R,'g',label='recovered')
plt.plot(time,D,'c',label='dead')
#plt.plot(time,S+I+R,'k',label='total population')
plt.plot(Cinf,'ro',label='infections')
plt.plot(Cdead,'bo',label='deaths')
plt.plot(Crec,'go',label='recoveries')
plt.xlabel('days after 22th of January')
plt.ylabel('number of people')
plt.legend(loc=5)
plt.title('Corona cases Hubei')

plt.show()

