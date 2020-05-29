MiTepid_sim
===========

.. image:: https://img.shields.io/pypi/v/mitepid.svg
    :target: https://pypi.python.org/pypi/mitepid
    :alt: Latest PyPI version
.. image:: https://img.shields.io/badge/License-GPLv3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0


MiTepid_sim: A repository to simulate the spread of COVID-19 or any other disease. Made in Tübingen. 

This code simulates a set of nonlinear ODEs which can simulate the spread of a virus in any stratified population, using different compartmental models. So far, SIS, SIR and SEIR models are defined in the code, but the user can easily add any other model. 

The `epid_sim` library also allows the user to define containment policies in different instances of time, and then simulate the trajectory of the population of each compartment in each group. And then plot them. 

It can be used to simulate any of the defined compartmental models with user-specified parameters. But the library comes with a set of contact rates which are calculated from the available data on the spread of COVID-19. The details of how these contact rates are estimated are explained in `this manuscript <http://people.tuebingen.mpg.de/vbokharaie/pdf_files/Quantifying_COVID19_Containment_Policies.pdf>`_. 

The `epid_sim` library is accompanied by a script called `script_main.py` which includes examples of how to use the library. A minimal sample code is given below. 

Updates on the model and how it can be used to predict the spread of COVID-19 can be found in:
https://people.tuebingen.mpg.de/vbokharaie/ 

Installation
------------
In your command prompt or bash, simply type:

 .. code-block:: bash

    pip install mitepid

Or you can install it from repo if you want to have the latest (untested) updates. 

Basic Usage
-----------
The code should work well under Python 3.x. There is a script coming with the code called ``script_main.py`` which can be used as an example on how to run the code. 

The following code snippet simulates the spread of COVID-19 in Germany. It assumed initially, 1 in 100,000 in all age groups in Germany are infective. Two scenarios are studied. One is an uncontained case, which is then used as a reference scenario for the next case study. In the second one, it is assumed COVID-19 spreads uncontained for 60 days, then the country goes under lockdown for 60 days, and then switches between uncontained and lockdown every month. The resulting plots for each case saved under ``sample_outputs`` subfolder in the current working directory. 

To see a list of defined policies and countries, look into ``policy.py`` module. Or you can run `mitepid.str_policy_info()`.

The optimized contact rates are calculated for nine age groups 0-10, 10-20, 20-30, ..., 70-80, and 80+. The advantage of this approach is that we can use the optimized contact rates in any population with a known age-structure. Hence, in order to simulate the model for any country, its age distribution in the above-mentioned age-groups should be defined in the code, more specifically in mit_epid.get_pop_distr() function. A few are already defined. 

 .. code-block:: bash

    #%% general variables
    country = 'Germany'
    t_end = 541
    x00 = 1e-5
    x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]


    dir_source_mat = Path(Path(__file__).resolve().parent)
    file_data_opt_SIR = Path(dir_source_mat, 'Optimised_B', 'SIR_B_opt_normalised.mat')
    dir_save_plots_main = Path(Path(__file__).resolve().parent, 'sample_output')

    # loading optimised contact rates
    file_data_opt_SIS = Path(dir_source_mat, 'Optimised_B', 'SIS_B_opt_normalised.mat')
    file_data_opt_SIR = Path(dir_source_mat, 'Optimised_B', 'SIR_B_opt_normalised.mat')
    B_opt_SIS = get_B_policy(file_data_opt_SIS, country, 'Uncontained', )
    B_opt_SIR = get_B_policy(file_data_opt_SIR, country, 'Uncontained', )

    # age groups, used as legends in plots
    age_groups = ['[0-10]',  '[10-20]', '[20-30]', '[30-40]',
                  '[40-50]', '[50-60]', '[60-70]', '[70-80]', '80+',]
    Ng = len(age_groups)
    
    # recovery rate (if on average, an individual is infectious for 20 days, then alpha = 1/20 = 0.05)
    alpha = load_mat(file_data_opt_SIR, 'alpha')
    alpha_vec = np.ones((Ng, 1)) * alpha
    # inhibition rate (if on average, an individual is in Latent (E) compartment for 2 days, then alpha = 1/2 = 0.5)
    # used in SEIR and not SIR/SIS models
    Gamma = np.zeros((Ng,Ng))
    np.fill_diagonal(Gamma, alpha_vec)
    #
    Sigma = Gamma *10

    
    model_type = 'SIR'
    #%% reference policy: uncontained
    # the uncontained policy is used as the reference model for all epid_sim object defined later on. 
    # that means in the plots of epid_obj, uncontained policy solution is also plotted as a reference. 
    policy_name = 'Uncontained'
    list_t_switch = [0,]
    all_containment_list = ['Uncontained',]
    ref_obj = epid_sim(model_type=model_type,
                        B=B_opt_SIR,
                        Gamma=Gamma,
                        Sigma=Sigma,
                        dir_save_plots_main=dir_save_plots_main,
                        country='Germany',
                        policy_list=all_containment_list,
                        policy_switch_times=list_t_switch,
                        x0=x0_vec,
                        t_end=t_end,
                        str_policy=policy_name,
                        group_labels=age_groups,)
    ref_obj.plot_agg()
    ref_obj.plot_strat()
    ref_obj.plot_strat_multiax()
    
    #%% Uncontained_then_switching_R0
    list_t_switch = [0, 60, 120, 150, 180, 210, 240, 270, 300, 330,]
    all_containment_list = ['Uncontained',
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
    policy_name = 'Uncontained_then_switching_Lockdown_R0'
    
    epid_obj = epid_sim(model_type=model_type,
                        B=B_opt_SIR,
                        Gamma=Gamma,
                        Sigma=Sigma,
                        dir_save_plots_main=dir_save_plots_main,
                        country=country,
                        policy_list=all_containment_list,
                        policy_switch_times=list_t_switch,
                        x0=x0_vec,
                        t_end=t_end,
                        str_policy=policy_name,
                        group_labels=age_groups,
                        ref_class=ref_obj)

    epid_obj.plot_agg()
    epid_obj.plot_strat()
    epid_obj.plot_strat_multiax()
    #%% Uncontained_then_switching_Lockdown
    # this policy inluceds siwtching etween uncontained and lockdown scenarios. 
    
    list_t_switch = [0, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, ]
    all_containment_list  = ['Uncontained',
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

    policy_name = 'Uncontained_then_switching_Lockdown'
    epid_obj = epid_sim(model_type=model_type,
                        B=B_opt_SIR,
                        Gamma=Gamma,
                        Sigma=Sigma,
                        dir_save_plots_main=dir_save_plots_main,
                        country=country,
                        policy_list=all_containment_list,
                        policy_switch_times=list_t_switch,
                        x0=x0_vec,
                        t_end=t_end,
                        str_policy=policy_name,
                        group_labels=age_groups,
                        ref_class=ref_obj)
    epid_obj.plot_agg()
    epid_obj.plot_strat()
    epid_obj.plot_strat_multiax()
    

Requirements
^^^^^^^^^^^^

 .. code-block:: python

    numpy
    scipy
    matplotlib
    pathlib


Compatibility
-------------

This code is tested under Python 3.8, and should work well for all current versions of Python 3.

Licence
-------
GNU General Public License (Version 3).


Author
-------

`MiTepid` is maintained by `Vahid Samadi Bokharaie <vahid.bokharaie@tuebingen.mpg.de>`_.
