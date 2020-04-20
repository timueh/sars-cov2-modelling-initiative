#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 20 12:59:33 2020.

@author: vbokharaie
"""

def main(country,
         policy_name,
         policy_definition,
         dir_save_plots_main='',
         t_end=541,
         x0_vec = [1e-3],
         xternal_inputs={},
         if_title=False):
    """
    Simulate the epid model.

    Calculate trajectory of an epid model for a country and for a defined policy.

    Parameters
    ----------
    country : str
        Name of the country, for which population distribution is defined in the code.
    policy_name : str
        a given name to oplicy used as subfolder name.
    policy_definition : dict
        a dictionary of {time: basic_policy} format.
    dir_save_plots_main : pathlib Path
        main folder to save plots. Then a subfolder in country/policyname is used to save files.
    xternal_inputs : dict
        dictionary of time/xternal_input. To model new Infectiouss fro moutside the populations
            example: incoming flights, etc.
    t_end : float
        end time of simulation, in days
    x0_vec : list of floats
        a list of size 1, Ng, or 2*Ng to specifiy initial conditions. Ng is number of groups.

    Returns
    -------
    dict_out : dictionary
        a dicitonary of all stratified and aggregated solutions of SIS and SIR models.

    """
    # local imports
    from mitepid.models import SIS, SIR
    from mitepid.plots import bplot
    from mitepid.utils import sol_aggregate, load_mat
    from mitepid.utils import sort_out_t_policy_x0
    from mitepid.policies import get_Bopt, str_policy_info, get_pop_distr

    # external imports
    from scipy.integrate import odeint
    import numpy as np
    from numpy.linalg import inv, eigvals
    from pathlib import Path

    print('***************************************************')
    # assuming data files are where the .py file is:
    dir_source_mat = Path(Path(__file__).resolve().parent)
    file_data_opt_SIR = Path(dir_source_mat, 'Optimised_B', 'SIR_B_opt_normalised.mat')
    file_data_opt_SIS = Path(dir_source_mat, 'Optimised_B', 'SIS_B_opt_normalised.mat')

    dir_save_plots_country = Path(dir_save_plots_main, country)

    B_opt_SIS_orig = get_Bopt(file_data_opt_SIS, country, 'Uncontained', )
    B_opt_SIR_orig = get_Bopt(file_data_opt_SIR, country, 'Uncontained', )

    Ng = B_opt_SIS_orig.shape[0]  # number of age groups

    # making the D matrix, alpha represents recovery rate
    alpha = load_mat(file_data_opt_SIR, 'alpha')
    ALPHA = np.ones((Ng, 1)) * alpha
    D = np.zeros((Ng,Ng))
    np.fill_diagonal(D, ALPHA)

    # age groups, used as legends in plots
    age_groups = ['[0-10]',  '[10-20]', '[20-30]', '[30-40]',
                  '[40-50]', '[50-60]', '[60-70]', '[70-80]', '80+',]

    #
    if policy_name == 'Uncontained':
        print('policy is uncontained')
        if_uncontained = True
    else:
        if_uncontained = False


    # initial conditions, t_f
    if len(x0_vec) == 1:
        x0_SIS = np.ones(Ng)*x0_vec
        x0_SIR = np.concatenate((np.ones(Ng)*x0_vec, np.zeros(Ng)))
    elif len(x0_vec) == Ng:
        x0_SIS = x0_vec
        x0_SIR = np.concatenate((x0_vec, np.zeros(Ng)))
    elif len(x0_vec) == 2*Ng:
        x0_SIS = x0_vec[:Ng]
        x0_SIR = x0_vec
    else:
        raise('Something wrong with initial conditions vector!')
    # uncontained solution
    t = np.arange(0, t_end+.01, step=0.1)

    sol_SIS_orig = odeint(SIS, x0_SIS, t, args=(B_opt_SIS_orig, ALPHA))
    sol_SIR_orig = odeint(SIR, x0_SIR, t, args=(B_opt_SIR_orig, ALPHA))
    sol_SIR_I_orig = sol_SIR_orig[:,:Ng]
    sol_SIR_R_orig = sol_SIR_orig[:,Ng:]
    sol_agg_SIS_orig = sol_aggregate(sol_SIS_orig, get_pop_distr(country))
    sol_agg_SIR_I_orig = sol_aggregate(sol_SIR_I_orig, get_pop_distr(country))
    sol_agg_SIR_R_orig = sol_aggregate(sol_SIR_R_orig, get_pop_distr(country))

    list_t1, list_t2, list_policies, list_x0, list_t_switch, list_all_policies = \
        sort_out_t_policy_x0(policy_definition, xternal_inputs, t_end, Ng)

    str_policy = policy_name  # used to make subfolder name
    dir_save_plots = Path(dir_save_plots_country, Path(str_policy))
    dir_save_plots.mkdir(exist_ok = True, parents=True)
    print('Saving in:')
    print(dir_save_plots)
    file_policy = Path(dir_save_plots, 'policy_details.txt')
    with open(file_policy, 'w') as f:
        f.write('\n    time (day) --->  Policy')
        f.write('\n    ------------------------------------------')

    for idx in np.arange(len(list_t1)):
        t_switch1 = list_t1[idx]
        t_switch2 =  list_t2[idx]
        policy = list_policies[idx]
        x0_xtrnal = list_x0[idx]
        with open(file_policy, 'a') as my_tex:
            my_tex.write('\n %10.1f    --->  %s'%(t_switch1, policy))  # remove previous contents

        B_opt_SIS = get_Bopt(file_data_opt_SIS, country, policy)
        B_opt_SIR = get_Bopt(file_data_opt_SIR, country, policy)
        #%% R_0 policy
        rho = np.max(np.abs(eigvals(np.matmul(-inv(D),B_opt_SIR))))  # spectral radius of -inv(D)*B
        print('%s   ---> R_0 = %2.2f'% (policy, rho))

        t_step = np.arange(t_switch1, t_switch2, step=0.1)
        x0_SIS = np.array(x0_SIS) + np.array(x0_xtrnal)
        x0_SIR = np.array(x0_SIR) + np.concatenate((x0_xtrnal, np.zeros(Ng)))
        # solve the ODE
        sol_SIS_step = odeint(SIS, x0_SIS, t_step, args=(B_opt_SIS, ALPHA))
        sol_SIR_step = odeint(SIR, x0_SIR, t_step, args=(B_opt_SIR, ALPHA))

        # update x0
        x0_SIS = sol_SIS_step[-1]
        x0_SIR = sol_SIR_step[-1]

        if idx == 0:
            sol_SIR = sol_SIR_step
            sol_SIS = sol_SIS_step
        else:
            sol_SIR = np.concatenate((sol_SIR, sol_SIR_step))
            sol_SIS = np.concatenate((sol_SIS, sol_SIS_step))

    sol_SIR_I = sol_SIR[:,:Ng]
    sol_SIR_R = sol_SIR[:,Ng:]
    with open(file_policy, 'a') as my_tex:
        my_tex.write('\n \n \n ')
        my_tex.write(str_policy_info())  # just to remove previous contents
    # calculate aggregate solutions
    sol_agg_SIS = sol_aggregate(sol_SIS, get_pop_distr(country))
    sol_agg_SIR_I = sol_aggregate(sol_SIR_I, get_pop_distr(country))
    sol_agg_SIR_R = sol_aggregate(sol_SIR_R, get_pop_distr(country))

    # save various solutions in a sictioanry to return to the main function
    dict_out = {}
    dict_out['sol_agg_SIR_R'] = sol_agg_SIR_R
    dict_out['sol_agg_SIR_I'] = sol_agg_SIR_I
    dict_out['sol_agg_SIS'] = sol_agg_SIS

    dict_out['sol_SIR_R'] = sol_SIR_R
    dict_out['sol_SIR_I'] = sol_SIR_I
    dict_out['sol_SIS'] = sol_SIS
    dict_out['t'] = t

    sol_SIR_I_plot = np.concatenate((sol_SIR_I, sol_SIR_I_orig), axis=1)
    sol_SIR_R_plot = np.concatenate((sol_SIR_R, sol_SIR_R_orig), axis=1)
    sol_SIS_plot = np.concatenate((sol_SIS, sol_SIS_orig), axis=1)

    if not dir_save_plots_main:
        if_plot = False  #  dir_save_plots_main=='' means don't plot
    else:
        plot_type = 1  # can be 1 -> all in one subplots, or 2 -> each age group in one subplot
        if_plot = True
    if if_plot:
        ### SIS
        filesave = Path(dir_save_plots, 'SIS_groups_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        suptitle = country + ' --- SIS'
        bplot(t, sol_SIS_plot, plot_type=1, filesave=filesave,
              labels=age_groups, suptitle=suptitle, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Infectious Ratio',
              Ng=9, cmap='viridis')

        ### SIR_I
        suptitle = ''

        filesave = Path(dir_save_plots, 'SIR_I_groups_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        bplot(t, sol_SIR_I_plot, plot_type=1, filesave=filesave,
              labels=age_groups, suptitle=suptitle, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Infectious Ratio',
              Ng=9, cmap='viridis')
        filesave = Path(dir_save_plots, 'SIR_I_groups_multi_ax_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        bplot(t, sol_SIR_I_plot, plot_type=2, filesave=filesave,
              labels=age_groups, suptitle=suptitle, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Infectious Ratio',
              Ng=9, cmap='Dark2')

        ### SIR_R
        suptitle = ''
        filesave = Path(dir_save_plots, 'SIR_R_groups_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        bplot(t, sol_SIR_R_plot, plot_type=1, filesave=filesave,
              labels=age_groups, suptitle=suptitle, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Recoverd Ratio',
              Ng=9, cmap='viridis', policy_name_pos=0.5)

        suptitle = ''
        filesave = Path(dir_save_plots, 'SIR_R_groups_multi_ax_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        bplot(t, sol_SIR_R_plot, plot_type=2, filesave=filesave,
              labels=age_groups, suptitle=suptitle, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Recoverd Ratio',
              Ng=9, cmap='Dark2', policy_name_pos=0.5)

        ### Aggregate SIS
        if if_uncontained:
            my_labels_I = ['Uncontained']
            my_labels_R = ['Uncontained']

        else:
            my_labels_I = ['Uncontained',
                           'policy',]
            my_labels_R = ['Uncontained',
                           'policy',]

        filesave = Path(dir_save_plots, 'SIS_AGG_' + str_policy+'_tf_'+str(int(t_end))+'.png')

        str_max1 = "{:2.2f}".format((sol_agg_SIS_orig[-1,0])*100)+ '%'
        if if_uncontained:
            sol_agg_SIS_plot = sol_agg_SIS
            str_max2 = ''
        else:
            sol_agg_SIS_plot = np.concatenate((sol_agg_SIS, sol_agg_SIS_orig), axis=1)
            str_max2 = ", {:2.2f}".format((sol_agg_SIS[-1,0])*100)+ '%'

        suptitle = '\nMaximum Ratio of Total Infectious: ' \
            + str_max1 + str_max2

        bplot(t, sol_agg_SIS_plot, plot_type=1, filesave=filesave,
              suptitle=suptitle, labels=my_labels_I, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Infectious Ratio')

        ### Aggregate SIR
        filesave_I = Path(dir_save_plots, 'SIR_I_AGG_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        filesave_R = Path(dir_save_plots, 'SIR_R_AGG_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        str_max_I_1 = "{:2.2f}".format(np.max(sol_agg_SIR_I_orig)*100)+ '%'
        str_max_R_1 = "{:2.2f}".format(np.max(sol_agg_SIR_R_orig)*100)+ '%'
        # Aggregate SIR I
        if if_uncontained:
            sol_agg_SIR_I_plot = sol_agg_SIR_I
            str_max2 = ''
        else:
            sol_agg_SIR_I_plot = np.concatenate((sol_agg_SIR_I_orig,
                                                 sol_agg_SIR_I,), axis=1)
            str_max2 = ", {:2.2f}".format(np.max(sol_agg_SIR_I)*100)+ '%'

        if if_uncontained:
            t_max_I = t[np.argmax(sol_agg_SIR_I_orig)]

            str_print_I = str_max_I_1
            str_print_R = str_max_R_1
        else:
            t_max_I = t[np.argmax(sol_agg_SIR_I)]
            str_print_I = ", {:2.2f}".format(np.max(sol_agg_SIR_I)*100)+ '%'
            str_print_R = ", {:2.2f}".format(np.max(sol_agg_SIR_R)*100)+ '%'

        print('x0= ', x0_vec)
        print('Max instantaneous Infectious ---> ', str_print_I[1:])
        print('Max Removed Population       ---> ', str_print_R[1:])
        print('TIME to reach max Infectious ---> ', t_max_I, ' days')


        if if_title:
            suptitle = '\nPeak/Maximum of Infectious Ratio in the population: ' + \
                str_max_I_1 + str_max2
        else:
            suptitle = ''
        bplot(t, sol_agg_SIR_I_plot, plot_type=1, filesave=filesave_I,
              suptitle=suptitle, labels=my_labels_I, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Infectious Ratio',
              cmap='Dark2')

        ### Aggregate difference between SIS and SIR outputs
        suptitle = ' Difference between solutions to SIS and SIR models'
        filesave_diff = Path(dir_save_plots, 'diff_SIS_SIR_agg_' + str_policy+'_tf_'+str(int(t_end))+'.png')
        bplot(t, sol_agg_SIS_plot-sol_agg_SIR_I_plot,
              plot_type=1, filesave=filesave_diff,
              suptitle=suptitle, labels=my_labels_I, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Infectious Ratio')

        if if_uncontained:
            sol_agg_SIR_R_plot = sol_agg_SIR_R
            str_max2 = ''
        else:
            sol_agg_SIR_R_plot = np.concatenate((sol_agg_SIR_R_orig,
                                                 sol_agg_SIR_R), axis=1)
            str_max2 = ", {:2.2f}".format(np.max(sol_agg_SIR_R)*100)+ '%'
        if if_title:
            suptitle = '\nMaximum Ratio of Removed Compartment in the population: ' + \
                str_max_R_1 + str_max2
        else:
            suptitle = ''
        bplot(t, sol_agg_SIR_R_plot, plot_type=1, filesave=filesave_R,
              suptitle=suptitle, labels=my_labels_R, list_vl=list_t_switch,
              list_all_policies=list_all_policies, ylabel='Removed Ratio',
              cmap='Dark2')


    return dict_out