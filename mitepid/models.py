#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  9 13:50:11 2020.

@author: vbokharaie
"""

def SEIR(states, t, B, Gamma, Mu, Sigma):
    """
    Simulate SEIR compartmental Model.

    Parameters
    ----------
    states : numpy array
        array of size 2*Ng for Infective (I) and Recovered (R) trajectories.
    t : numpy array
        time array of interest.
    B : numpy 2D array
        matrix of contact rates. b_{ij} describes the influence of group j on group i.
    Gamma : numpy array
        a diagonal matrix of transmission rates.
    Mu: numpy array
        a diagonal matrix of birth/death rates (it is assumed birth and death rates are equal)
    Sigma: numpy array
        a diagonal matrix of inhibitions rate (related to how long is latent period)

    Returns
    -------
    dsdt : numpy array
        solution of the model.

    """
    import numpy as np
    Ng = B.shape[0];
    x = states[:Ng]  # I
    y = states[Ng:2*Ng]  # R
    z = states[2*Ng:3*Ng]  # E
    dxdt = np.zeros(Ng);
    dydt = np.zeros(Ng);
    dzdt = np.zeros(Ng);
    for i in np.arange(Ng):
        Sum_j_x = 0;
        for j in np.arange(Ng):
            Sum_j_x = Sum_j_x + B[i, j]* x[j]
        dzdt[i] = (1 - x[i] - y[i] - z[i]) * Sum_j_x - (Mu[i, i] + Sigma[i, i]) * z[i]
        dxdt[i] = Sigma[i, i] * z[i] - (Mu[i, i] + Gamma[i, i]) * x[i]
        dydt[i] = Gamma[i, i] * x[i] - Mu[i,i] * y[i]

    dsdt = np.concatenate((dxdt, dydt, dzdt))
    return dsdt

def SIR(states, t, B, Gamma, Mu):
    """
    Simulate SIR Model.

    Parameters
    ----------
    states : numpy array
        array of size 2*Ng for Infective (I) and Recovered (R) trajectories.
    t : numpy array
        time array of interest.
    B : numpy 2D array
        matrix of contact rates. b_{ij} describes the influence of group j on group i.
    Gamma : numpy array
        a diagonal matrix of transmission rates.
    Mu: numpy array
        a diagonal matrix of birth/death rates (it is assumed birth and death rates are equal)

    Returns
    -------
    dsdt : numpy array
        solution to the model.

    """
    import numpy as np
    Ng = B.shape[0];
    x = states[:Ng]
    y = states[Ng:]
    dxdt = np.zeros(Ng);
    dydt = np.zeros(Ng);

    for i in np.arange(Ng):
        # I
        Sum_j_x = 0;
        for j in np.arange(Ng):
            Sum_j_x = Sum_j_x + B[i, j]* x[j]

        dxdt[i] = (1-x[i]) * Sum_j_x - y[i] * Sum_j_x - (Mu[i, i] + Gamma[i, i]) * x[i]
        # R
        dydt[i] = (Mu[i, i] + Gamma[i, i]) * x[i]

    dsdt = np.concatenate((dxdt, dydt))
    return dsdt


def SIS(x, t, B, Gamma, Mu):
    """
    Simulate SIS model.

    Parameters
    ----------
    x : numpy array
        array of size Ng for Infective (I) trajectories.
    t : numpy array
        time array of interest.
    B : numpy 2D array
        matrix of contact rates. b_{ij} describes the influence of group j on group i.
    Gamma : numpy array
        a diagonal matrix of transmission rates.
    Mu: numpy array
        a diagonal matrix of birth/death rates (it is assumed birth and death rates are equal)

    Returns
    -------
    dxdt : numpy array
        solution to the model.

    """
    import numpy as np
    Ng = x.size;
    dxdt = np.zeros(Ng);
    for i in np.arange(Ng):
        Sum_j = 0;
        for j in np.arange(Ng):
            Sum_j = Sum_j + B[i, j]* x[j];

        dxdt[i] = (1-x[i]) * Sum_j - (Mu[i, i] + Gamma[i, i]) * x[i];
    return dxdt


