%%
varyR;


%% Daily Infection 2 Months

Nsick = [16, 18, 21, 26, 53, 66, 127, 152, 196, 262, 400, 639, 795, 902, 1139, 1296, 1567, 2369, 3062,  3795, 4838, 6012, 7156, 8198, 10999, 13957 ]; % from Robert Koch Institut LAST IS FROM 15/03/20 AT 8pm
DeltaNsick = diff(Nsick);
shift=120;
%% Wunsch Klaus
    figure('name','Vary R - one Plot')
    hold on
      plot(Dates(1:length(DeltaNsick)+shift),N_t_R100(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
      plot(Dates(1:length(DeltaNsick)+shift),N_t_R250(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
       plot(Dates(1:length(DeltaNsick)+shift),N_t_R500(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
     plot(Dates(1:length(DeltaNsick)+shift),N_t_R750(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
        plot(Dates(1:length(DeltaNsick)+shift),N_t_R1000(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
          
      
    ylabel('$N_2(t)$','Interpreter','Latex')
    %xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    %title('r=1/100','Interpreter','Latex')
    legend({'$r=.01$','$r=.025$','$r=.05$','$r=.1$','r=.2'},'Interpreter','latex','location','northwest')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyROnePlot.eps
    print -dpng varyROnePlot.png

%     %% 
%     
%     figure('name','Vary R - one Plot')
%     hold on
% 
%            plot(Dates(1:length(DeltaNsick)+shift),N_t_RHubai(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
%               plot(Dates(1:length(DeltaNsick)+shift),N_t_RSK(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
%      
%       
%     ylabel('$N_2(t)$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     %title('r=1/100','Interpreter','Latex')
%     legend({'$r=.001$','$r=3/10000$'},'Interpreter','latex','location','northwest')
%     set(gca,'FontSize',28) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
% 
%     set(gcf,'position',[0,0,1920 ,1080])
%     
%     print -depsc2 varyROnePlot.eps
%     print -dpng varyROnePlot.png
    
    %% Wunsch Klaus
    figure('name','Vary R - one Plot')
    hold on
      plot(Dates(1:length(DeltaNsick)+shift),N2new_R100(1:length(DeltaNsick)+shift),'LineWidth',3)
      plot(Dates(1:length(DeltaNsick)+shift),N2new_R250(1:length(DeltaNsick)+shift),'LineWidth',3)
       plot(Dates(1:length(DeltaNsick)+shift),N2new_R500(1:length(DeltaNsick)+shift),'LineWidth',3)
     plot(Dates(1:length(DeltaNsick)+shift),N2new_R750(1:length(DeltaNsick)+shift),'LineWidth',3)
        plot(Dates(1:length(DeltaNsick)+shift),N2new_R1000(1:length(DeltaNsick)+shift),'LineWidth',3)
     
      
    ylabel('$N_2^{new}(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    %title('r=1/100','Interpreter','Latex')
    legend({'$r=.01$','$r=.025$','$r=.05$','$r=.1$','r=.2'},'Interpreter','Latex','location','northwest')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyROnePlotN2new.eps
    print -dpng varyROnePlotN2new.png
    
    
%%
    x=[0,1,2.5,5,10,20];
    N2max=[0, max(N_t_R100(:,2)),max(N_t_R250(:,2)),max(N_t_R500(:,2)),max(N_t_R750(:,2)),max(N_t_R1000(:,2))]*1000.*x./100;
    xq=3/50:0.01:20;
    vq = interp1(x,N2max,xq,'pchip');
    
    figure('name','Vary R - N2max interpolation')
    hold on
    plot(xq,vq,'LineWidth',3) 
    ylabel('$N_2^{\max}(r)$','Interpreter','Latex')
    xlabel('probability $r$ to get sick after infection','Interpreter','Latex')
    xticks([0.1 1 5 10 15 20])
    xticklabels({'.001','.01','.05','.1','.15','.2'})
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    %title('r=1/100','Interpreter','Latex')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyRN2maxInterpolation.eps
    print -dpng varyRN2maxInterpolation.png
    
    fprintf('For r=1/1000 (Hubai) we obtain N_2^{max} = %f \n',vq(5));
    fprintf('For r=3/5000 (South Korea) we obtain N_2^{max} = %f \n',vq(1));
    
    
%% N2(t) in subplots due to scaling

 figure('name','Vary R - Daily Infections 2 month')
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R100(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$r=.01$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
     plot(Dates(1:length(DeltaNsick)+shift),N_t_R250(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$r=.025$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
     hold on
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R750(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$r=.1$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R1000(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$r=.2$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 Figure8Subplots.eps
    print -dpng Figure8Subplots.png
    

%%

 figure('name','Vary R - Daily Infections 2 month')
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R100(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.01','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R500(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.05','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
     hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R750(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.1','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N_t_R1000(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.2','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyRDailyInfections2months.eps
    print -dpng varyRDailyInfections2months.png
    
    
 %% Daily Infection 
 figure('name','Vary R - Daily Infections')
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t_R100(:,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.01','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t_R500(:,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.05','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
     hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t_R750(:,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.1','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t_R1000(:,2)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.2','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyRDailyInfections.eps
    print -dpng varyRDailyInfections.png
   
 %% Total Infection 2 Months
 figure('name','Vary R - Total Infections 2 month')
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shift),N2ever_R100(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    title('r=.01','Interpreter','Latex')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shift),N2ever_R500(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.05','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
     hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shift),N2ever_R750(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.1','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shift),N2ever_R1000(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.2','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyRTotalInfections2months.eps
    print -dpng varyRTotalInfections2months.png
    
 %% Total Infections
 figure('name','Vary R - Total Infections')
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever_R100*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.01','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever_R500*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.05','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever_R750*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.1','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever_R1000*1000,'LineWidth',3)
    ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.2','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyRTotalInfections.eps
    print -dpng varyRTotalInfections.png   
    
    
 %%
 N1_R100_LaggedDifference = diff(N_t_R100(:,2)*1000);
 N1_R500_LaggedDifference = diff(N_t_R500(:,2)*1000);
 N1_R750_LaggedDifference = diff(N_t_R750(:,2)*1000);
 N1_R1000_LaggedDifference = diff(N_t_R1000(:,2)*1000);

% Plot figure (6) here real quick
figure('name','Change in N2(t)');
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(Nsick)+shift),N1_R100_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('$\Delta$sick $N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.01','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
    plot(Dates(1:length(Nsick)+shift),N1_R500_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('$\Delta$sick $N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.05','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
     hold on
    plot(Dates(1:length(Nsick)+shift),N1_R750_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('$\Delta$sick $N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.1','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(Nsick)+shift),N1_R1000_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
    ylabel('$\Delta$sick $N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('r=.2','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])

    print -depsc2 varyRChangeInTheNumberOfSickIndividualsPerDay2months.eps
    print  -dpng varyRChangeInTheNumberOfSickIndividualsPerDay2months.png
    
    

   
