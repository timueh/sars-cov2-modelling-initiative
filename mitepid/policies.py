#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Created on Fri Mar 20 13:03:03 2020.

@author: vbokharaie
"""

def str_policy_info():
    """
    Return a string with info about defined basic policies.

    Returns
    -------
    str_out : str
        info on basic policies.

    """
    # text should be manually updated based on policies defined in get_B_policy
    str_out = """
    ***************************************************************************************
    HOW EACH POLICY IS DEFINED?
    ***************************************************************************************
    ---------------------------------------------------------------------------------------
    Below you can see the policies I have defined.

    Obviously, any other polciy can be easily defined in the code,
        when you find where they are defined.

    list_scales shows the scale for contacts rates in each group as compared to uncontained
        hence the values are in [0,1] range.

    Age groups are 0-10, 10-20, ..., 70-80 and 80+
    ---------------------------------------------------------------------------------------

    # these policies are defined intuitively,
    #------------------------
    if policy == 'Uncontained':
        w_kids = 1
        w_adults = 1
        w_old =  1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Schools_closed':
        w_kids = 0.2
        w_adults = 1
        w_old =  1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Elderly_self_isolate':
        w_kids = 1.0
        w_adults = 1.0
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Kids_Elderly_self_isolate':
        w_kids = 0.2
        w_adults = 1.0
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Social_Distancing':
        w_kids = 0.2
        w_adults = 0.2
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Lockdown':
        w_kids = 0.1
        w_adults = 0.1
        w_old = 0.1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'R0_is_1':
        w_kids = 0.2984
        w_adults = 0.6047
        w_old =  0.1015
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Schools_Offices_closed':
        w_kids = 0.2
        w_adults = 0.5
        w_old = 1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Adults_self_isolate':
        w_adults = 0.4
        list_scales = [1, 1, w_adults, w_adults, w_adults, w_adults, w_adults, 1, 1, ]
    #------------------------
    elif policy == 'Adults_Elderly_Self_isolate':
        w_kids = 1
        w_adults = 0.2
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Lockdown_but_kids':
        w_kids = 1
        w_adults = 0.1
        w_old = 0.1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]

    """
    return str_out

def get_B_policy(file_data_opt=None, country='Germany', policy='Uncontained', B = None, ):
    """
    Return the contact rates for the specified model (SIS/SIR), country, pre-defined policy.

    Parameters
    ----------
    file_data_opt : TYPE
        DESCRIPTION.
    country : TYPE, optional
        DESCRIPTION. The default is 'Germany'.
    policy : TYPE, optional
        DESCRIPTION. The default is 'Uncontained'.
     : TYPE
        DESCRIPTION.

    Returns
    -------
    B_opt : TYPE
        DESCRIPTION.

    """
    # load original (uncontained) Bopt obtained from optimisation performed in matlab
    # variable names in saved files is 'B_opt_' + country, example: B_opt_Germany
    from mitepid.utils import load_mat, scale_B_opt
    if not file_data_opt is None:
        varname = 'B_opt_noramlised'
        print(file_data_opt)
        B_opt_normalised = load_mat(file_data_opt, varname)
        B = Bopt_normalised_2_country(B_opt_normalised, get_pop_distr(country))
    # these policies are defined intuitively,
    # all suggestions to make them more accurate are welcome
    #------------------------
    if policy == 'Uncontained':
        w_kids = 1
        w_adults = 1
        w_old =  1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Schools_closed':
        w_kids = 0.2
        w_adults = 1
        w_old =  1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Elderly_self_isolate':
        w_kids = 1.0
        w_adults = 1.0
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Kids_Elderly_self_isolate':
        w_kids = 0.2
        w_adults = 1.0
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Social_Distancing':
        w_kids = 0.2
        w_adults = 0.2
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Lockdown':
        w_kids = 0.1
        w_adults = 0.1
        w_old = 0.1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'R0_is_1':
        w_kids = 0.2984
        w_adults = 0.6047
        w_old =  0.1015
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Schools_Offices_closed':
        w_kids = 0.2
        w_adults = 0.5
        w_old = 1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Adults_self_isolate':
        w_adults = 0.4
        list_scales = [1, 1, w_adults, w_adults, w_adults, w_adults, w_adults, 1, 1, ]
    #------------------------
    elif policy == 'Adults_Elderly_Self_isolate':
        w_kids = 1
        w_adults = 0.2
        w_old = 0.25
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    #------------------------
    elif policy == 'Lockdown_but_kids':
        w_kids = 1
        w_adults = 0.1
        w_old = 0.1
        list_scales = [w_kids, w_kids, w_adults, w_adults, w_adults, w_adults, w_adults, w_old, w_old, ]
    elif not policy == 'Uncontained':
        raise('Policy was not recognized.')
    if policy == 'Uncontained':
        B_policy = B
    else:
        B_policy = scale_B_opt(B, list_scales)

    return B_policy

def get_pop_distr(country):
    """
    Return population distribution in each country.

    in age ranges of each 10 years till 80 and 80+
    obtained from www.populationpyramid.net

    Parameters
    ----------
    country : str
        name of the country.

    Returns
    -------
    list_out : list of floats
    percentage of popultaion in each age-group.
        age groups are 0-10, 10-20, ..., 70-80, 80+

    """
    dict_pop = {}
    dict_pop['China'] = [11.9, 11.6, 13.5, 15.6, 15.6, 15.0, 10.4, 4.7, 1.7]
    dict_pop['Italy'] = [8.4, 9.5, 10.1, 11.8, 15.3, 15.7, 12.3, 9.8, 7.3]
    dict_pop['Iran'] = [17.4, 13.9, 15.5, 20.0, 13.6, 9.7, 6.2, 2.7, 1.0]
    dict_pop['SouthKorea'] = [8.4, 9.5, 13.3, 14.0, 16.3, 16.4, 12.1, 6.6, 3.5]
    dict_pop['Germany'] = [9.2, 9.6, 11.2, 12.8, 12.5, 16.2, 12.4, 9.1, 6.9]
    dict_pop['Spain'] = [9.3, 10.0, 10.0, 13.2, 17.0, 14.8, 11.0, 8.5, 6.2]
    dict_pop['France'] = [11.8, 12.0, 11.4, 12.3, 12.9, 13.2, 12.0, 8.4, 6.2]
    dict_pop['UK'] = [12.0, 11.2, 12.8, 13.7, 12.9, 13.6, 10.8, 8.5, 5.1]
    dict_pop['USA'] = [12.1, 12.9, 14.0, 13.3, 12.3, 13.0, 11.5, 7.0, 3.9]

    list_out = dict_pop[country]
    return list_out

def Bopt_normalised_2_country(Bopt, list_age_distr):
    """
    Convert the general optimised B matrix to one adapted for a certain country.

    Parameters
    ----------
    Bopt : 2D numpy array
        A Ng x Ng matrix of normalised contact rates obtained from optimisation scheme.
    list_age_distr : list of floats
        population distribution for each age range in each country.

    Returns
    -------
    Bopt_country : 2D numpy array
        Matrix of contact rates

    """
    import numpy as np
    Ng = Bopt.shape[0]
    B_factors = np.zeros(Bopt.shape)
    assert len(list_age_distr) == Ng, 'Look at this: dimension mismatch!!! :/'
    for cc1 in np.arange(Ng):
        for cc2 in np.arange(Ng):
            B_factors[cc1, cc2] = list_age_distr[cc2]/list_age_distr[cc1]
    Bopt_country = np.multiply(Bopt, B_factors)
    return Bopt_country