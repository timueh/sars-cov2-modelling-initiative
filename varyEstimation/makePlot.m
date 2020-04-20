getCalibrations;

%%
Nsick = [16, 18, 21, 26, 53, 66, 127, 152, 196, 262, 400, 639, 795, 902, 1139, 1296, 1567, 2369, 3062,  3795, 4838, 6012, 7156, 8198, 10999, 13957 ]; % from Robert Koch Institut LAST IS FROM 15/03/20 AT 8pm
DeltaNsick = diff(Nsick);

%%
shifter=90;
 figure('name','Diffent Calibrations 2 months')
    subplot(3,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shifter),N2new_Daily(1:length(DeltaNsick)+shifter)*1000,'LineWidth',3)
    ylabel('Daily new Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,2)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),N2ever_Daily(1:length(Nsick)+shifter)*1000,'LineWidth',3)
    ylabel('Total Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(3,2,3)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shifter),N2new_Total(1:length(DeltaNsick)+shifter)*1000,'LineWidth',3)
    ylabel('Daily new Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,4)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),N2ever_Total(1:length(Nsick)+shifter)*1000,'LineWidth',3)
    ylabel('Total Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,5)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+shifter),N2new(1:length(DeltaNsick)+shifter)*1000,'LineWidth',3)
    ylabel('Daily new Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily and Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,6)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),N2ever(1:length(Nsick)+shifter)*1000,'LineWidth',3)
    ylabel('Total Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily and Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyCalibration2months.eps
    print -dpng varyCalibration2months.png
    
%%
 figure('name','Diffent Calibrations')
    subplot(3,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t_Daily(:,2)*1000,'LineWidth',3)
    ylabel('Daily new Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,2)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever_Daily*1000,'LineWidth',3)
    ylabel('Total Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(3,2,3)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t_Total(:,2)*1000,'LineWidth',3)
    ylabel('Daily new Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,4)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever_Total*1000,'LineWidth',3)
    ylabel('Total Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,5)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates,N_t(:,2)*1000,'LineWidth',3)
    ylabel('Daily new Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily and Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    subplot(3,2,6)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates,N2ever*1000,'LineWidth',3)
    ylabel('Total Infections')
    xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    title('Optimize Daily and Total Infections')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyCalibration.eps
    print -dpng varyCalibration.png

%% Lambda12
 figure('name','Diffent Calibrations - lambda12')
    hold on
    plot(Dates(1:length(Nsick)+shifter),lambda_12(1:length(Nsick)+shifter),'LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),lambda_12_Daily(1:length(Nsick)+shifter),'LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),lambda_12_Total(1:length(Nsick)+shifter),'LineWidth',3)
    ylabel('$\lambda_{12}$','Interpreter','Latex')
    xlabel('Date')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('Optimize Daily and Total Infections','Optimize Daily Infections','Optimize Total Infections')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyCalibrationLambda.eps
    print -dpng varyCalibrationLambda.png
    
%% rho
figure('name','Diffent Calibrations - rho')
    hold on
    plot(Dates(1:length(Nsick)+shifter),rho(1:length(Nsick)+shifter),'LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),rho_Daily(1:length(Nsick)+shifter),'LineWidth',3)
    plot(Dates(1:length(Nsick)+shifter),rho_Total(1:length(Nsick)+shifter),'LineWidth',3)
    ylabel('$\rho$','Interpreter','Latex')
    xlabel('Date')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('Optimize Daily and Total Infections','Optimize Daily Infections','Optimize Total Infections','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 varyCalibrationRho.eps
    print -dpng varyCalibrationRho.png
    saveas(gcf,'varyCalibrationRho.png')