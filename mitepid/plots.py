#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  9 13:49:51 2020.

@author: vbokharaie
"""

def bplot(t,
          sol,
          plot_type=1,
          ylim=None,
          if_show=False,
          if_save=True,
          filesave='test.png',
          labels=[''],
          suptitle='',
          list_vl=[],
          list_all_policies=None,
          ylabel='',
          if_plot_in_pc=True,
          cmap='Dark2',
          Ng=None,
          policy_name_pos=0.75,):
    """
    Line plots of the solutions to the epidemilogical model.

    Parameters
    ----------
    t : numpy array, (N_time,)
        time array
    sol : ND numpy array, (N_time x N_groups)
        solution of an SIS or SIR model, or solution of any ODE.
    plot_type : int, optional
        1: concurrent plots of all age groups, 2: each in a separate subplot. The default is 1.
    ylim : list of floats, optional
        y-axis limits. The default is (0,1).
    if_show : bool, optional
        Should plots be closed or not. The default is False.
    if_save : bool, optional
        save the plots to disk or not. The default is True.
    filesave : pathlib Path, optional
        filename for plots. The default is 'test.png'.
    labels : list of str, optional
        labels for plot legends. The default is [''].
    suptitle : str, optional
        main plot title. The default is ''.
    list_vl : list float, optional
        list of swithing times between policies, marked by red vertical lines. The default is [].
    list_all_policies : list of str, optional
        list of policies to implement at each switching time. The default is [].
    ylabel : str, optional
        y-axis label. The default is ''.
    if_plot_in_pc : bool
        y axis in percents or just the ratio.
    cmap : matplotlib colormap
        cmap used in plot
    Ng : int
        number of groups in the oringal model
    policy_name_pos : float
        in [0,1] range. Where in y axis should the text for each policy be insterted.

    Returns
    -------
    None.

    """
    import matplotlib
    # Force matplotlib to not use any Xwindows backend.
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.pylab as pl
    import matplotlib as mpl
    import numpy as np

    plt.style.use('seaborn-whitegrid')
    # plt.style.use('seaborn-darkgrid')
    # plt.style.use('bmh')
    # plt.style.use('ggplot')
    # mpl.rcParams['lines.linewidth'] = 3.0
    # mpl.rcParams['font.weight'] = 'bold'
    if plot_type == 1:
        font_size = 30
    else:
        font_size = 24
    font = {'family' : 'DejaVu Sans',
                'sans-serif' : 'Tahoma',
                'weight' : 'regular',
                'size'   : font_size}
    mpl.rc('grid', color='#316931', linewidth=1, linestyle='dotted')
    mpl.rc('font', **font)
    mpl.rc('lines', lw=3,)
    mpl.rc('xtick', labelsize=font_size)
    mpl.rc('ytick', labelsize=font_size)

    if not Ng:
        if len(sol.shape)==2:
            Ng = sol.shape[1]
        else:
            Ng = 1
            sol = sol.reshape(sol.size, 1)
    if cmap == 'viridis_r':
        colors = pl.cm.viridis_r(np.linspace(0,1,Ng))
    elif cmap == 'viridis':
        colors = pl.cm.viridis_r(np.linspace(0,1,Ng))
    elif cmap == 'Dark2':
        colors = pl.cm.Dark2.colors
    elif cmap == 'Set1':
        colors = pl.cm.Set1.colors
    if if_plot_in_pc:
        if ylabel:
            ylabel = ylabel + ' (values in %)'

        y_ax_scale = 100
    else:
        y_ax_scale = 1

    if plot_type == 1:
        fig, ax = plt.subplots(1, 1, figsize=(24,18))
        ax.set_facecolor('0.95')
        fig.subplots_adjust(bottom=0.15, top=0.92, left=0.1, right = 0.85)
        for cc in np.arange(Ng):
            # my_label = 'x'+str(cc+1).zfill(2)

            if not labels==['']:
                ax.plot(t, sol[:, cc] * y_ax_scale, label=labels[cc], color = colors[cc], alpha=0.98)
                ax.legend(bbox_to_anchor=(1.2, 1.0), prop={'size': 24})
            else:
                ax.plot(t, sol[:, cc] * y_ax_scale, color = colors[cc], alpha=0.98)

            if ylim:
                ax.set_ylim(ylim)
            ax.set_xlabel('\nTime (days)')
            ax.set_xticks(np.arange(0, t[-1], step=30))
            plt.xticks(rotation=90)
            ax.set_ylabel(ylabel)
            ylim_max = ax.get_ylim()[1]
        for idx1, xc in enumerate(list_vl):
            ax.axvline(x=xc, color='r', linestyle='--', linewidth=1)
            bbox = {'fc': '0.9', 'pad': 4, 'alpha': 0.3}
            props = {'ha': 'center', 'va': 'center', 'bbox': bbox,}
            if not list_all_policies is None:
                my_text = list_all_policies[idx1]
                # make sure policy label does not cover main plot
                idx_xc_in_t = [idx for idx, x in enumerate(t) if x>xc][0]
                if sol[idx_xc_in_t, 0] < 0.9*ylim_max and sol[idx_xc_in_t, 0] < 0.7*ylim_max:
                    policy_label_loc = policy_name_pos*ylim_max
                else:
                    policy_label_loc = 0.3*ylim_max
                xc_plot = xc+10*t[-1]/500
                ax.text(xc_plot, policy_label_loc, my_text, props, rotation=90, color='k', alpha=0.7)
        fig.suptitle(suptitle, fontsize=16, fontweight='bold')
    elif plot_type == 2:
        fig, ax_all = plt.subplots(Ng, 1, figsize=(18,18))
        fig.tight_layout()
        fig.subplots_adjust(bottom=0.1, top=0.95, left = 0.1)
        # colors = pl.cm.viridis_r(np.linspace(0,1,2))
        # fig.subplots_adjust(bottom=0.15, top=0.92, left=0.1, right = 0.88)
        for cc in np.arange(Ng):
            # my_label = 'x'+str(cc+1).zfill(2)
            ax = ax_all[cc]
            ax.plot(t, sol[:, cc] * y_ax_scale, color = colors[1], alpha=0.98)  # policy
            ax.plot(t, sol[:, cc + Ng] * y_ax_scale, color = colors[0], alpha=0.98)  # uncontained
            if ylim:
                ax.set_ylim(ylim)
            if cc == Ng-1:
                ax.set_xlabel('\nTime (days)')
                plt.xticks(rotation=90)
            else:
                ax.xaxis.set_ticklabels([])
            ax.set_xticks(np.arange(0, t[-1], step=30))
            if not labels==['']:
                ax.set_ylabel(labels[cc], rotation=90)
            ylim_max = ax.get_ylim()[1]
            for idx1, xc in enumerate(list_vl):
                ax.axvline(x=xc, color='r', linestyle='--', linewidth=1)

    if not if_show:
        plt.close('all')
    if if_save:
        dir_save = filesave.parent
        dir_save.mkdir(exist_ok=True, parents=True)
        fig.savefig(filesave, dpi=100)
        filesave_pdf = filesave.with_suffix(".pdf")
        fig.savefig(filesave_pdf, dpi=300, filetype='pdf', quality=100)
