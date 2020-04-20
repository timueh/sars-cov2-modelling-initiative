%%
varyEta;


%% Daily Infection 2 Months

  Nsick = [16, 18, 21, 26, 53, 66, 127, 152, 196, 262, 400, 639, 795, 902, 1139, 1296, 1567, 2369, 3062,  3795, 4838, 6012, 7156, 8198, 10999, 13957 ]; % from Robert Koch Institut LAST IS FROM 15/03/20 AT 8pm
DeltaNsick = diff(Nsick);

%% Wunsch Klaus
shift=150;
    figure('name','Vary Eta - one Plot')
    hold on
    plot(Dates(1:length(DeltaNsick)+shift),N_t_Eta25(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
     plot(Dates(1:length(DeltaNsick)+shift),N_t_Eta40(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
     plot(Dates(1:length(DeltaNsick)+shift),N_t_Eta60(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
     plot(Dates(1:length(DeltaNsick)+shift),N_t_Eta75(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)
   % plot(Dates(1:length(DeltaNsick)+shift),N_t_Eta90(1:length(DeltaNsick)+shift,2)*1000,'LineWidth',3)     
    ylabel('$N_2(t)$','Interpreter','Latex')
    %xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    %title('r=1/100','Interpreter','Latex')
    legend({'$\eta=.25$','$\eta=.4$','$\eta=.6$','$\eta=.75$'},'Interpreter','Latex')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyEtaOnePlot.eps
    print -dpng varyEtaOnePlot.png

%%
    x=[.25,.40,.60,.75,.90];
    N2max=[max(N_t_Eta25(:,2)),max(N_t_Eta40(:,2)),max(N_t_Eta60(:,2)),max(N_t_Eta75(:,2)),max(N_t_Eta90(:,2))]*1000;
    xq=.25:.05:.90;
    vq = interp1(x,N2max,xq,'pchip');
    
    figure('name','Vary Eta - N2max interpolation')
    hold on
    plot(xq,vq,'LineWidth',3) 
    ylabel('$N_2^{\max}(\eta)$','Interpreter','Latex')
    xlabel('Share $\eta$ of healthy that are infectuous','Interpreter','Latex')
    %xticks(.25:.05:.9)
    %xticklabels({'1 in 100','1 in 200','1 in 300','1 in 400','1 in 500','1 in 600','1 in 700','1 in 800','1 in 900','1 in 1000'})
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    %title('r=1/100','Interpreter','Latex')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyEtaN2maxInterpolation.eps
    print -dpng varyEtaN2maxInterpolation.png
%%
shift=74;
 figure('name','Vary Eta - Daily Infections 2 month')
    subplot(2,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N2new_Eta25(1:length(DeltaNsick)+shift)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$\eta=.25$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,2)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N2new_Eta40(1:length(DeltaNsick)+shift)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$\eta=.4$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(2,2,3)
     hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N2new_Eta60(1:length(DeltaNsick)+shift)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$\eta=.6$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(2,2,4)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shift),N2new_Eta75(1:length(DeltaNsick)+shift)*1000,'LineWidth',3)
    ylabel('$N_2(t)$','Interpreter','Latex')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('$\eta=.9$','Interpreter','Latex')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyEtaDailyInfections2months.eps
    print -dpng varyEtaDailyInfections2months.png
    
    
%  %% Daily Infection 
%  figure('name','Vary Eta - Daily Infections')
%     subplot(2,2,1)
%     hold on
%     plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
%     plot(Dates,N_t_Eta25(:,2)*1000,'LineWidth',3)
%     ylabel('$N_2(t)$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.25$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,2)
%     hold on
%     plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
%     plot(Dates,N_t_Eta40(:,2)*1000,'LineWidth',3)
%     ylabel('$N_2(t)$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.4$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
% 
%     subplot(2,2,3)
%      hold on
%     plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
%     plot(Dates,N_t_Eta60(:,2)*1000,'LineWidth',3)
%     ylabel('$N_2(t)$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.6$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,4)
%     hold on
%     plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
%     plot(Dates,N_t_Eta90(:,2)*1000,'LineWidth',3)
%     ylabel('$N_2(t)$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.9$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     set(gcf,'position',[0,0,1920 ,1080])
%     
%     print -depsc2 varyEtaDailyInfections.eps
%     print -dpng varyEtaDailyInfections.png
   
%  %% Total Infection 2 Months
%  figure('name','Vary Eta - Total Infections 2 month')
%     subplot(2,2,1)
%     hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates(1:length(Nsick)+shift),N2ever_Eta25(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.25$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,2)
%     hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates(1:length(Nsick)+shift),N2ever_Eta40(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.4$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
% 
%     subplot(2,2,3)
%      hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates(1:length(Nsick)+shift),N2ever_Eta60(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.6$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,4)
%     hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates(1:length(Nsick)+shift),N2ever_Eta90(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.9$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     set(gcf,'position',[0,0,1920 ,1080])
%     
%     print -depsc2 varyEtaTotalInfections2months.eps
%     print -dpng varyEtaTotalInfections2months.png
%     
%  %% Total Infections
%  figure('name','Vary Eta - Total Infections')
%     subplot(2,2,1)
%     hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates,N2ever_Eta25*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.25$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,2)
%     hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates,N2ever_Eta40*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.4$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
% 
%     subplot(2,2,3)
%      hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates,N2ever_Eta60*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.6$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,4)
%     hold on
%     plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
%     plot(Dates,N2ever_Eta90*1000,'LineWidth',3)
%     ylabel('Total Infections $N_2^{ever}$','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.9$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     set(gcf,'position',[0,0,1920 ,1080])
%     
%     print -depsc2 varyEtaTotalInfections.eps
%     print -dpng varyEtaTotalInfections.png   
    
    
%  %%
%  N1_Eta25_LaggedDifference = diff(N_t_Eta25(:,2)*1000);
%  N1_Eta40_LaggedDifference = diff(N_t_Eta40(:,2)*1000);
%  N1_Eta60_LaggedDifference = diff(N_t_Eta60(:,2)*1000);
%  N1_Eta90_LaggedDifference = diff(N_t_Eta90(:,2)*1000);
% 
% % Plot figure (6) here real quick
% figure('name','Change in N2(t)');
%     subplot(2,2,1)
%     hold on
%     plot(Dates(1:length(Nsick)+shift),N1_Eta25_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('$\Delta$sick N2(t)','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.25$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,2)
%     hold on
%     plot(Dates(1:length(Nsick)+shift),N1_Eta40_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('$\Delta$sick N2(t)','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.4$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
% 
%     subplot(2,2,3)
%      hold on
%     plot(Dates(1:length(Nsick)+shift),N1_Eta60_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('$\Delta$sick N2(t)','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.6$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,4)
%     hold on
%     plot(Dates(1:length(Nsick)+shift),N1_Eta90_LaggedDifference(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('$\Delta$sick N2(t)','Interpreter','Latex')
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.9$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     set(gcf,'position',[0,0,1920 ,1080])
% 
%     print -depsc2 varyEtaChangeInTheNumberOfSickIndividualsPerDay2months.eps
%     print  -dpng varyEtaChangeInTheNumberOfSickIndividualsPerDay2months.png
%     
%     
%     %% calculate newly sick equation (8)
% 
%     figure('name','newlySick')
%     subplot(2,2,1)
%     hold on
%     plot(Dates(1:length(Nsick)+shift),N2new_Eta25(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Newly reported sick $N_2^{new}$','Interpreter','Latex','FontSize', 20);
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.25$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,2)
%     hold on
%     plot(Dates(1:length(Nsick)+shift),N2new_Eta40(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Newly reported sick $N_2^{new}$','Interpreter','Latex','FontSize', 20);
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.4$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
% 
%     subplot(2,2,3)
%      hold on
%     plot(Dates(1:length(Nsick)+shift),N2new_Eta60(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Newly reported sick $N_2^{new}$','Interpreter','Latex','FontSize', 20);
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.6$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     subplot(2,2,4)
%     hold on
%     plot(Dates(1:length(Nsick)+shift),N2new_Eta90(1:length(Nsick)+shift)*1000,'LineWidth',3)
%     ylabel('Newly reported sick $N_2^{new}$','Interpreter','Latex','FontSize', 20);
%     xlabel('Date')
%     ax = gca;
%     ax.YRuler.Exponent = 0;
%     ytickformat('%,6.4g')
%     title('$\eta=.9$','Interpreter','Latex')
%     set(gca,'FontSize',20) % Achsenbeschriftung und Legende
%     hold off
%     axis tight
%     
%     set(gcf,'position',[0,0,1920 ,1080])
% 
%     print -depsc2 varyEtaNewlySick.eps
%     print  -dpng varyEtaNewlySick.png
%     
%    
