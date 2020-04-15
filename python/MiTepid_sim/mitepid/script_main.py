#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 23 10:07:11 2020.

@author: vbokharaie

You can use this script as a template to run the simulations of an epidemilogicla model as
explained in:
http://people.tuebingen.mpg.de/vbokharaie/pdf_files/Quantifying_COVID19_Containment_Policies.pdf

"""

if __name__ == '__main__':
    from mitepid.func_main import main
    from mitepid.policies import str_policy_info
    from mitepid.plots import bplot

    from pathlib import Path
    import numpy as np

    #%% print policy info text?
    if_print_policies_info = False
    if if_print_policies_info:
        print(str_policy_info())
    subfolder = Path('sample_outputs')
    dir_save_plots_main = Path(Path(__file__).resolve().parent, subfolder)

    ##############################################################################################
    # UNCONTAINED SCENARIO
    ##############################################################################################
    #%% Uncontained in one country
    # See list of defined countries in get_pop_distr in policies module.
    # any country whose age distribution is defeind can be used in here.
    country = 'Iran'
    t_end = 541
    list_t_switch = [0,]
    all_policies = ['Uncontained',]
    policy_definition = dict(zip(list_t_switch, all_policies))
    policy_name = 'Uncontained'
    x00 = 1e-4  # 0.0001 population in Iran = 8500 people
    x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
    dict_uncontained = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)


    #%% Uncontained scenario, various countries
    t_end = 541
    list_t_switch = [0]
    policy_list = ['Uncontained',
                   ]
    list_countries = ['Germany',
                   'Iran',
                   'Italy',
                   'Spain',
                   'China',
                   'USA',
                   'UK',
                   'France',
                   ]
    dict_I = {}
    dict_R = {}
    for country in list_countries:
        print('**************************************')
        print(country)
        all_policies = ['Uncontained',]
        policy_definition = dict(zip(list_t_switch, all_policies))
        x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
        policy_name = 'Uncontained'
        dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)

        dict_I[country] = dict_current['sol_agg_SIR_I']
        dict_R[country] = dict_current['sol_agg_SIR_R']

    for idx, country in enumerate(dict_I.keys()):

        if idx == 0:
            sol_agg_SIR_R_plot = dict_R[country]
            sol_agg_SIR_I_plot = dict_I[country]
        else:
            sol_agg_SIR_R_plot = np.concatenate((sol_agg_SIR_R_plot,
                                                 dict_R[country]), axis=1)
            sol_agg_SIR_I_plot = np.concatenate((sol_agg_SIR_I_plot,
                                                 dict_I[country]), axis=1)

    dir_save_plots_country = Path(dir_save_plots_main)
    dir_save_plots = Path(dir_save_plots_country, '00_OVERALL_Uncontained')
    dir_save_plots.mkdir(exist_ok=True, parents=True)
    filesave_I = Path(dir_save_plots, 'SIR_I_AGG_ALL_countries.png')
    filesave_R = Path(dir_save_plots, 'SIR_R_AGG_ALL_countries.png')

    t = np.arange(0, t_end+.01, step=0.1)
    list_all_policies = ['Uncontained']
    bplot(t, sol_agg_SIR_R_plot, plot_type=1, filesave=filesave_R,
      suptitle='', labels=list_countries, list_vl=list_t_switch,
      list_all_policies=list_all_policies, ylabel='Recovered Ratio', cmap='Set1')
    bplot(t, sol_agg_SIR_I_plot, plot_type=1, filesave=filesave_I,
      suptitle='', labels=list_countries, list_vl=list_t_switch,
      list_all_policies=list_all_policies, ylabel='Infectious Ratio', cmap='Set1')

    ##############################################################################################
    # SUPPRESSION PLANS
    ##############################################################################################
    #%% Ninety days of unconatined scenario in Iran, then trying various policies.
    country = 'Iran'
    t_end = 541
    list_t_switch = [0, 90]
    policy_list = ['Uncontained',
                   'Schools_closed',
                   'Elderly_self_isolate',
                   'Kids_Elderly_self_isolate',
                   'Schools_Offices_closed',
                   'Adults_Elderly_Self_isolate',
                   'Social_Distancing',
                   'Lockdown',
                   ]
    policy_labels = ['UN',
                   'KI',
                   'EL',
                   'KIEL',
                   'KIOF',
                   'ADEL',
                   'SD',
                   'LD',
                   ]
    dict_I = {}
    dict_R = {}
    for policy in policy_list:
        all_policies = ['Uncontained',]
        all_policies.append(policy)
        policy_definition = dict(zip(list_t_switch, all_policies))
        x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
        policy_name = 'Uncontained_then_' + policy
        print('*********************************************')
        print(policy_name)
        dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)

        dict_I[policy] = dict_current['sol_agg_SIR_I']
        dict_R[policy] = dict_current['sol_agg_SIR_R']

    for idx, policy in enumerate(dict_I.keys()):

        if idx == 0:
            sol_agg_SIR_R_plot = dict_R[policy]
            sol_agg_SIR_I_plot = dict_I[policy]
        else:
            sol_agg_SIR_R_plot = np.concatenate((sol_agg_SIR_R_plot,
                                                 dict_R[policy]), axis=1)
            sol_agg_SIR_I_plot = np.concatenate((sol_agg_SIR_I_plot,
                                                 dict_I[policy]), axis=1)

    dir_save_plots_country = Path(dir_save_plots_main, country)
    dir_save_plots = Path(dir_save_plots_country, '00_OVERALL')
    dir_save_plots.mkdir(exist_ok=True, parents=True)
    filesave_I = Path(dir_save_plots, 'SIR_I_AGG_ALL_policies_IRAN.png')
    filesave_R = Path(dir_save_plots, 'SIR_R_AGG_ALL_policies_IRAN.png')

    # plot aggregate plots to compare all policies.
    from plots import bplot
    t = np.arange(0, t_end+.01, step=0.1)
    list_all_policies = ['Uncontained']
    list_all_policies.extend(['Policy']*(len(policy_list)-1))
    bplot(t, sol_agg_SIR_R_plot, plot_type=1, filesave=filesave_R,
      suptitle='', labels=policy_labels, list_vl=list_t_switch,
      list_all_policies=list_all_policies, ylabel='Recovered Ratio')
    bplot(t, sol_agg_SIR_I_plot, plot_type=1, filesave=filesave_I,
      suptitle='', labels=policy_labels, list_vl=list_t_switch,
      list_all_policies=list_all_policies, ylabel='Infectious Ratio')

    ##############################################################################################
    # LONGTERM PLANS
    ##############################################################################################
    #%% Switching between Uncontained and policy that enforces R0 = 1.0
    country = 'Iran'
    t_end = 541
    list_t_switch = [0, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, ]
    all_policies = ['Uncontained',
                    'R0_is_1',
                    'Uncontained',
                    'R0_is_1',
                    'Uncontained',
                    'R0_is_1',
                    'Uncontained',
                    'R0_is_1',
                    'Uncontained',
                    'R0_is_1',
                    'Uncontained',
                   ]
    policy_definition = dict(zip(list_t_switch, all_policies))
    x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
    policy_name = 'Uncontained_then_switching_R0'
    dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)


    #%% Switching between Uncontained and Lockdown policy
    country = 'Iran'
    t_end = 541
    list_t_switch = [0, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360,]
    all_policies = ['Uncontained',
                    'Lockdown',
                    'Uncontained',
                    'Lockdown',
                    'Uncontained',
                    'Lockdown',
                    'Uncontained',
                    'Lockdown',
                    'Uncontained',
                    'Lockdown',
                    'Uncontained',
                   ]
    policy_definition = dict(zip(list_t_switch, all_policies))
    x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
    policy_name = 'Uncontained_then_switching_Lockdown'
    dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)


    #%% Switching between Uncontained, policy that enforces R0 = 1.0 and Lockdown
    t_end = 541
    list_t_switch = [0, 90, 120, 150, 180, 210, 240, 270, 300, 330,]
    all_policies = ['Uncontained',
                    'Lockdown',
                    'R0_is_1',
                    'Uncontained',
                    'Lockdown',
                    'R0_is_1',
                    'Uncontained',
                    'Lockdown',
                    'R0_is_1',
                    'Uncontained',
                     ]

    policy_definition = dict(zip(list_t_switch, all_policies))
    x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
    policy_name = 'Uncontained_then_switching_Lockdown_R0'
    dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)


    ##############################################################################################
