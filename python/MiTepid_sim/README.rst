MiTepid_sim
===========

.. image:: https://img.shields.io/pypi/v/mitepid.svg
    :target: https://pypi.python.org/pypi/mitepid
    :alt: Latest PyPI version
.. image:: https://img.shields.io/badge/License-GPLv3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0


MiTepid_sim: A repository to simulate the spread of COVID19. 

This code simulates a set of nonlinear ODEs which can simulate the spread of a virus in any population with a known age structure, using both SIR and SIS models. The parameters of this model are estimated based on the available data on the spread of COVID-19. The details of that method, which relies on an optimisation scheme, are explained in `this manuscript <http://people.tuebingen.mpg.de/vbokharaie/pdf_files/Quantifying_COVID19_Containment_Policies.pdf>`_. The optimisation itself is done using the GLobal Optimisation Toolbox in Matlab. But the optimised values of the model parameters are uploaded with this code. 

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
Code should work well under Python 3.x. There is a script coming with the code called ``script_main.py`` which can be used as a template for how to run the code and demonstrates its capabilities. 

The following code snippet simulates the spread of COVID-19 in Germany. It assumed initially, 1 in 10,000 in all age groups in Germany are infective. The disease spread uncontained for 60 days and then various containment policies are imposed. The resulting plots for each case saved under ``sample_outputs`` subfolder in the current working directory. 

To see a list of defined policies and countries, look into ``policy.py`` module. To add a country, you should simply add its age distribution in age groups 0-10, 10-20, 20-30, ..., 70-80, and 80+. And to add a new policy, you just need to define coefficients for each of the age-groups, in [0,1] range, which shows how the policy would affect the contacts of that age-group. 

 .. code-block:: bash

    from mitepid.func_main import main

    from pathlib import Path
    subfolder = Path('sample_outputs')
    dir_save_plots_main = Path(Path.cwd(), subfolder)
    country = 'Germany'
    t_end = 541
    list_t_switch = [0, 60]
    policy_list = ['Uncontained',
                   'Schools_closed',
                   'Elderly_self_isolate',
                   'Kids_Elderly_self_isolate',
                   'Schools_Offices_closed',
                   'Adults_Elderly_Self_isolate',
                   'Social_Distancing',
                   'Lockdown',
                   ]

    for policy in policy_list:
        all_policies = ['Uncontained',]
        all_policies.append(policy)
        policy_definition = dict(zip(list_t_switch, all_policies))
        x00 = 1e-4  # initial condition
        x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,]
        policy_name = 'Uncontained_then_' + policy
        print('*********************************************')
        print(policy_name)
        dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)

Usage for long-term plans
-------------------------
You can also use the code to plan for long-term policies. Something that seems to be more relevant for all countries in the world. We can impose a total lockdown for a limited period of time. But COVID-19 is here to stay until a vaccine is available. So, we should try smarter solutions. The below-mentioned code snippet shows what happens if we switch between uncontained, total lock-down and another policy which will enforce the basic reproduction number to be 1.0. More details can be found in `this manuscript <http://people.tuebingen.mpg.de/vbokharaie/pdf_files/Quantifying_COVID19_Containment_Policies.pdf>`_. 

For a list of defined policies or how to define new ones, check the ``policies.py`` module. 

 .. code-block:: bash

    #%% Switching between Uncontained, policy that enforces R0 = 1.0 and total Lockdown
    from mitepid.func_main import main

    from pathlib import Path
    subfolder = Path('sample_outputs')
    dir_save_plots_main = Path(Path.cwd(), subfolder)
    
    country = 'Germany'
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
    # Starting with 1 in 10,000 of population being infected in all age-groups. 
    # Change x0_vec for any initial conditions you like. 
    x00 = 1e-4  
    x0_vec=[x00, x00, x00, x00, x00, x00, x00, x00, x00,] 
    policy_name = 'Uncontained_then_switching_Lockdown_R0'
    dict_current = main(country, policy_name, policy_definition,
                            dir_save_plots_main, t_end=t_end, x0_vec=x0_vec)

Requirements
^^^^^^^^^^^^

 .. code-block:: python

    numpy
    scipy
    matplotlib


Compatibility
-------------

This code is tested under Python 3.8, and should work well for all current versions of Python 3.

Licence
-------
GNU General Public License (Version 3).


Author
-------

`MiTepid` is maintained by `Vahid Samadi Bokharaie <vahid.bokharaie@tuebingen.mpg.de>`_.
