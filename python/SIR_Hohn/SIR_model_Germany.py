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
data_file="./Corona_infections_Germany.txt"
Ginf = np.genfromtxt(data_file,skip_header=0,filling_values=-999.,delimiter="\t")

data_file="./Corona_deaths_Germany.txt"
Gdead = np.genfromtxt(data_file,skip_header=0,filling_values=-999.,delimiter="\t")



P=81800000.0 # average population size between 1990 and 2018


# parameters: constrained by data from Statistisches Bundesamt
b= 0.009019 * 1.0/360.0 # birth rate (per year) converted to (per day)
#theta= 0.003024 * 1.0/360.0 # immigration rate of susceptible (people per day)
theta=0.0 # due to closed borders
d= 0.010615 * 1.0/360.0 # death rate of healthy individuals (per year)



# parameters: unconstrained
# infection dynamics:
a= 0.03 # probability that the disease is transmitted upon contact
c= 7.60/P # contact rate per susceptible individual

# recovery and mortality
#delta= 0.033 # death rate of infected individuals # based on Chinese data
delta= 0.0021 # death rate of infected individuals # based on GERMAN data


#rho= 0.08 # recovery rate for infected individuals (an earlier guess but completely unconstrained)
rho= 0.03 # recovery rate for infected individuals (constrained by Chinese and Bremen data)

# immunity or not?
sigma= 0.0 # rate of recovered individuals that become susceptible for reinfection

# initialization
tmax=80
dt=1.0

S=np.zeros(tmax)
I=np.zeros(tmax)
R=np.zeros(tmax)
D=np.zeros(tmax)
time=np.arange(0,tmax,1)
DDt=np.zeros(tmax-1)


S[0]=P
I[0]=1.0
R[0]=0.0

for i in range(tmax-1):
    # stepwise changes of parameter values due to changing human behaviour according to political restrictions
    if i>59:
        c= 3.3/P
        if i>67:
            c=1.7/P
            delta=0.0025
            
    # susceptible fraction of population
    #dSdt=theta*S[i]+b*S[i]-d*S[i] - a*c*S[i]*I[i] + sigma*R[i]
    dSdt= sigma*R[i] - a*c*S[i]*I[i] # I switched off birth, migration, and natural mortality because we look at a short time intrval for the time being
    # infected fraction of population
    dIdt=a*c*S[i]*I[i] - delta*I[i] - rho*I[i]
    # recovered fraction of population
    dRdt=rho*I[i] - sigma*R[i] - d*R[i]
    
    S[i+1]=S[i]+dSdt*dt
    I[i+1]=I[i]+dIdt*dt
    R[i+1]=R[i]+dRdt*dt
    D[i+1]=D[i]+delta*I[i]*dt
    
    DDt[i]=np.log(2.0)/np.log(1.0+a*c*S[i]) # is this the correct equation for doubling time?
    

print 'total fatalities=', D[tmax-1]


plt.figure(1)
#plt.plot(time,S,'b',label='susceptible')
plt.plot(time,I+R,'r',label='infected cumulative')
plt.plot(time,I,'m',label='infected active')
plt.plot(time,R,'g',label='recovered')
plt.plot(time,D,'c',label='dead')
#plt.plot(time,S+I+R,'k',label='total population')
plt.plot(Ginf,'ro',label='infections cumulative')
plt.plot(Gdead,'bo',label='deaths')
plt.xlabel('days after 28th of January')
plt.ylabel('number of people')
plt.title('Covid Model for Germany (assuming 0\% unreported cases)')
plt.legend(loc=2)


#plt.figure(2)
#plt.plot(time,I*0.02,'r',label='Pneumonie') # assuming 2 percent of infected develop pneumonia (based on RKI)
#plt.xlabel('days after 11th of March')
#plt.ylabel('number of people')
#plt.legend(loc=5)



plt.figure(3)
plt.plot(DDt,'b',label='Growth factor') # Verdopplungszeit


plt.show()

