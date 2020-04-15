#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  9 13:50:11 2020.

@author: vbokharaie
"""


def SIR(xy, t, B, ALPHA):
    """
    Simulate SIR Model.

    Parameters
    ----------
    xy : numpy array
        array of size 2*Ng for Infective (I) and Recovered (R) trajectories.
    t : numpy array
        time array of interest.
    B : numpy 2D array
        matrix of contact rates. b_{ij} describes the influence of group j on group i.
    ALPHA : numpy array
        an array of all recovery rates.

    Returns
    -------
    array_out : numpy array
        solution to the model.

    """
    import numpy as np
    Ng = ALPHA.size;
    x = xy[:Ng]
    y = xy[Ng:]
    dxdt = np.zeros(Ng);
    dydt = np.zeros(Ng);

    for cc1 in np.arange(Ng):
        # I
        Sigma_x = 0;
        for cc2 in np.arange(Ng):
            Sigma_x = Sigma_x + B[cc1, cc2]* x[cc2];

        dxdt[cc1] = (1-x[cc1]) * Sigma_x - y[cc1] * Sigma_x - ALPHA[cc1] * x[cc1];
        # R
        dydt[cc1] = ALPHA[cc1] * x[cc1];

    array_out = np.concatenate((dxdt, dydt))
    return array_out


def SIS(x, t, B, ALPHA):
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
    ALPHA : numpy array
        an array of all recovery rates.

    Returns
    -------
    dxdt : numpy array
        solution to the model.

    """
    import numpy as np
    Ng = x.size;
    dxdt = np.zeros(Ng);
    for cc1 in np.arange(Ng):
        Sigma = 0;
        for cc2 in np.arange(Ng):
            Sigma = Sigma + B[cc1, cc2]* x[cc2];

        dxdt[cc1] = (1-x[cc1]) * Sigma - ALPHA[cc1] * x[cc1];
    return dxdt


