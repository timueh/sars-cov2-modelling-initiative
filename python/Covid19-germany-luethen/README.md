# covid19-germany
## SEIR-Modell in Python

Different stages of the Covid19 epidemic in Germany are simulated and plotted. Some parameters are given according to epidemic research, others fit by a simple algorithm (MSE optimization). Pay attention to numeric output in the shell. Feel free to create your own variations. 

![pre lockdown](./images/pre_lockdown.png)
Exponential growth stage in March 2020

- straight slope (logarithm y-scale) 
- doubling time 2.9 days
- prominent offset at Mar 5, most likely caused by carnival and ski tourism

![during lockdown](./images/apr.png)
April 2020

Fitting params: 
```
[Rt_1d  Rt_SI  Rt_4d]       = 0.9444 0.6488 0.7955
[SI     T2     MSE]         = 7.5622 12.118 2.7639e-03
[R0 1/beta 1/alpha 1/gamma] = 0.5200 8.8164 5.2699 4.5846
```
