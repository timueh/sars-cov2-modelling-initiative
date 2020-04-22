#Code for SEIR-model to simulate COVID19 outbreak in Germany
#
#Compartments
#S: susceptible individuals
#E: exposed individuals (i.e. asymptomatic during the incubation period)
#I: infectious individuals (with or without symptoms)
#H: quarantined or hospitalized infected
#R: recovered infected

#Parameters
#beta:  transmission rate
#kappa: mean rate of progression to infectious state
#       = 1/DE, where DE is the mean time to onset of infectiousness,
#       assuming that infectiousness starts on average two days before the onset of symptoms
#sigma: transition rate of infectious where symptoms occur to insulation
#       = 1/DI, where DI is the mean duration of infectious period before insulation
#gamma: mean recovery rate of infected individuals
#       = 1/DR, where is the mean time from onset of symptoms to recovery
#alpha: proportion of asymptomatic infectious

#import required modules
import numpy as np
from datetime import datetime
from scipy.integrate import odeint
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
#import matplotlib.dates as mdates
#from pandas.plotting import register_matplotlib_converters
#register_matplotlib_converters()

#assumed parameter values
r0 = 3.3
kappa = 1/3.2   #=1/DE
sigma = 1/6     #=1/DI
gamma = 1/9     #=1/DR
alpha = 0.2

#calculation is per 100,000 population
N = 1E5

#initial numbers per 100,000 population
I0, E0, H0, R0 = 2, 2, 1, 0
#initial conditions set for the simulation correspond roughly to the case numbers
#reported for Germany by the JHU on 03/07/2020;
#taking into account the time delay until a case is confirmed,
#day 0 of the simulation thus corresponds to the actual status on 03/01/2020

#in Germany, extensive contact bans came into force on 03/23,
#and contacts were gradually restricted starting on 03/12
t1=22 #first day of the overall contact restrictions
t2=50 #relaxation of contact restrictions started

#lowest value of the contact restriction factor
crmin =0.15

def cr(t,per,crmin=crmin,t1=t1,t2=t2):
    #returns the factor by which the rate is reduced under the interventions 
    if t < t1-14:
        cr = 1
    elif t < t1:
        cr = cr = np.exp((t-12)/10*np.log(0.5))
    elif t < t2:
        cr = crmin
    elif t < t2+per:
        #the contact rate returns to 90 percent of the previous value
        #within a period of <per> days, linearly from the lowest value
        cr = 0.15+(t-t2)/per*0.75
    else:
        cr = 0.9
    return cr

#model differential equations
def model(y,t,N, r0,kappa,sigma,gamma,alpha,per=200):
    beta = r0/((1-alpha)*(1/sigma)+alpha*(1/gamma))
    S, E, I, H, R = y
    dSdt = -cr(t,per)*beta*I*S/N
    dEdt = cr(t,per)*beta*I*S/N - kappa*E
    dIdt = kappa*E -((1-alpha)*sigma+alpha*gamma)*I
    dHdt = (1-alpha)*sigma*I - gamma*H
    dRdt = alpha*gamma*I + gamma*H
    return dSdt, dEdt, dIdt, dHdt, dRdt

def run_model(t,r0,kappa,sigma,gamma,alpha,per=200):
    S0 = N-I0-E0-H0-R0
    y0 = S0, E0, I0, H0, R0 #initial conditions vector
    y = odeint(model,y0,t,args=(N,r0,kappa,sigma,gamma,alpha,per))
    return y
    
def check_model(r0=r0,kappa=kappa,sigma=sigma,gamma=gamma,alpha=alpha,days=60):
    t = np.arange(0,days+1)
    y = run_model(t, r0,kappa,sigma,gamma,alpha)
    S, E, I, H, R = y.T
    #the cumulative number of (detected) cases is given by
    calc = H+(1-alpha)*R
    #plot calculated numbers
    plt.style.use('seaborn-dark')
    fig, axes = plt.subplots(tight_layout='True')
    legend ='Calculated total number of symptomatic cases'
    axes.plot(t, calc, 'm',alpha=0.8, label=legend)
    #to compare with the number of cases as reported by the JHU
    #time lag between the onset of the disease and its confirmation
    beginn='03/07/2020' 
    day0=datetime.strptime(beginn,'%m/%d/%Y')
    print(day0)
    file='./JHU_confirmed_cases_DE.csv'
    df = pd.read_csv(file,index_col='date',parse_dates=['date'])
    #print(df.info(),df.head,df.tail)
    rep = df.loc[day0:]
    print(rep.head())
    rep.reset_index(inplace=True,drop=True)
    print(rep.head())
    legend='Total confirmed cases 6 days later, as reported by JHU'
    n=83.2E6
    axes.plot(rep/n*N,color='r',alpha=0.8,label=legend)
    axes.set_xticks(t[::5])
    axes.set_ylabel('Cases per 100,000 population')
    axes.grid(which='major',linestyle='dotted')
    axes.grid(which='minor',linestyle='dotted',axis='x')
    #axes.xaxis.set_major_formatter(mdates.DateFormatter('%d.%m.'))
    #axes.xaxis.set_minor_formatter(mdates.DateFormatter('%d.%m.'))
    axes.set_xlabel('Days from 03/01/2020')
    title='SEIR-Model for COVID-19 cases in Germany'
    axes.set_title(title,fontsize=10)
    axes.legend(loc='upper left',fontsize='small',frameon=False)
    plt.show()

def apply_model(days=360,per=[200,300]):
    plt.style.use('seaborn-dark')
    fig, axes = plt.subplots(tight_layout='True')
    axes.text(50,500,'Control relaxation started on day '+ str(t2),
              fontsize='small')#,ha='left',transform=axes.transAxes)
    t = np.arange(0,days+1)
    y = run_model(t, r0,kappa,sigma,gamma,alpha,per[0])
    S, E, I, H, R = y.T
    #he number of cases actually requiring treatment
    #corresponds to the number of individuals in the H-compartment
    legend ='Infected in hospitalization, controls relaxed within '+str(per[0])+' days'
    axes.plot(t, H, 'r',alpha=0.8, label=legend)
    y = run_model(t, r0,kappa,sigma,gamma,alpha,per[1])
    S, E, I, H, R = y.T
    legend ='Infected in hospitalization, controls relaxed within '+str(per[1])+' days'
    axes.plot(t, H, 'm',alpha=0.8, label=legend)    
    axes.set_xticks(t[::30])
    #_=plt.xticks(rotation=45)
    axes.set_ylabel('Cases per 100,000 population')
    #axes.set_ylabel('Percentage of population')
    #axes.yaxis.set_major_formatter(ticker.PercentFormatter(xmax=N))
    axes.grid(which='major',linestyle='dotted')
    axes.grid(which='minor',linestyle='dotted',axis='x')
    axes.set_xlabel('Days from 03/01/2020')
    axes.legend(loc='upper left',fontsize='small',frameon=False)
    title='SEIR-Model for COVID-19 cases in Germany'
    axes.set_title(title,fontsize=10)
    plt.show()
