#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 20 12:27:48 2020.

@author: vbokharaie
"""



def load_mat(filename, var_name=None):
    """
    Load data from mat files.

    Parameters
    ----------
    filename : pathlib Path
        filename including possibly multiple variable in matlab mat format.
    var_name : str, optional
        variable to be loaded. The default is None.

    Returns
    -------
    my_data : TYPE
        DESCRIPTION.

    """
    from scipy.io import loadmat

    data_struct = loadmat(filename)
    if not var_name:
        var_name = [x for x in data_struct.keys() if not '__' in x][0]
    my_data = data_struct[var_name]
    return my_data


def save_mat(filename, var):
    """
    Save data to mat files.

    Parameters
    ----------
    filename : pathlib Path
        filename.
    var : str
        variable name.

    Returns
    -------
    None.

    """
    from scipy.io import savemat

    folder = filename.parent
    folder.mkdir(parents=True, exist_ok=True)
    my_dict = {'var_name': var}
    savemat(filename, my_dict)

def sol_aggregate(sol_in, pop_country):
    """
    Calculate the aggregate trajectory of the whole population.

    Each age groups is weighted based on its ratio of the whol population.

    Parameters
    ----------
    sol_in : numpy array
        solution to epid model. shape (N_time x N_groups)
    pop_country : list of floats
        list of relative ratio of each age group in the population.

    Returns
    -------
    sol_out : numpy array
        aggregate trajectory. shape (N_time x 1)

    """
    import numpy as np

    sol = sol_in.copy()
    Ng = sol.shape[1]
    for cc in np.arange(Ng):
        sol[:,cc] = sol[:,cc] * pop_country[cc]/100
    sol_out = np.sum(sol, axis=1)
    sol_out = sol_out.reshape(sol_out.size,1)
    return sol_out

def scale_B_opt(B_opt_in, list_scales=None):
    """
    Scale matrix of contact ratios for a given policy.

    Parameters
    ----------
    B_opt_in : numpy 2D array
        matrix of contact rates.
    list_scales : list floats, optional
        how each row of B_opt_in should be scaled.
        The default is None, in which case return B_opt_in.

    Returns
    -------
    B_opt_out : numpy 2D array
        scaled contact rates.
    """
    list_scales = list(list_scales)
    Ng = B_opt_in.shape[0]
    if len(list_scales)==1:
        list_scales = [list_scales[0]] * Ng
    elif not len(list_scales) == Ng:
        return

    B_opt_out = B_opt_in.copy()
    for idx, el in enumerate(list_scales):
        B_opt_out[idx, :] = B_opt_out[idx, :] * list_scales[idx]

    return B_opt_out

def sort_out_t_policy_x0(policy_definition, xternal_inputs, t_end, Ng):
    """
    Take the list of policies and external inputs, turn them into list of times policies.

    Parameters
    ----------
    policy_definition : dict
        dictionary of time: polciy.
    xternal_inputs : TYPE
        DESCRIPTION.
    t_end : float
        end time, in days.
    Ng : int
        Number of groups defined in the model.

    Returns
    -------
    list_t1 : list of float
        list of begin times for each policy.
    list_t2 : list of float
        list of end times for each policy.
    list_policies : list str
        list of policy names.
    list_x0 : list float
        list initial conditions for each policy, in case there is external input.
    list_t_switch : list float
        original switching times in policy definition.
        This would be different than list_t1, is there is external input without policy change.
    list_all_policies : list str
        list of all policies. Would be different than list_policies if there is
        external input without policy change.

    """
    import numpy as np

    list_t_switch = list(policy_definition.keys())
    list_all_policies = list(policy_definition.values())
    list_x0_xtrnl_dummy = [list(np.zeros(Ng))]*len(list_all_policies)

    list_t_xtrnl = list(xternal_inputs.keys())
    list_x0_xtrnl = list(xternal_inputs.values())
    list_all_policies_dummy = [None]*len(list_x0_xtrnl)

    for idx, t in enumerate(list_t_switch):
        try:
            list_idx = [idx2 for idx2, x in enumerate(list_t_xtrnl) if x == t]
            idx2 = list_idx[0]
        except IndexError:
            continue
        list_x0_xtrnl_dummy[idx] = list_x0_xtrnl[idx2]
        list_t_xtrnl.pop(idx2)
        list_all_policies_dummy.pop(idx2)
        list_x0_xtrnl.pop(idx2)

    list_t = list_t_switch + list_t_xtrnl
    list_policies = list_all_policies + list_all_policies_dummy
    list_x0 = list_x0_xtrnl_dummy + list_x0_xtrnl


    ind_sorted = np.argsort(list_t)
    list_t1 = [list_t[x] for x in ind_sorted]

    list_t2 = list_t1.copy()
    list_t2.append(t_end + 1e-10)
    list_t2.pop(0)
    list_policies = [list_policies[x] for x in ind_sorted]
    list_x0 = [list_x0[x] for x in ind_sorted]

    for idx3 in np.arange(len(list_policies)-1)+1:
        if not list_policies[idx3]:
            list_policies[idx3] = list_policies[idx3-1]

    return list_t1, list_t2, list_policies, list_x0, list_t_switch, list_all_policies