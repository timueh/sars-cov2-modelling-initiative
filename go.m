%% Run this file to get all the Results
% for 
% Projecting the Spread of COVID19 for Germany
% Donsimoni, Jean Roch / Glawion, René / Plachter, Bodo / Wälde, Klaus
% available at
% https://www.cesifo.org/en/publikationen/2020/working-paper/projecting-spread-covid19-germany
% 
% (c) René Glawion / rene.glawion@uni-hamburg.de

clear
close all
clc
%% parameters

shift=120; % for plots

parameters.nr = 14; % recovery time in days
parameters.N = 83100; % population size in 1000
[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters();


N = parameters.N;
% Show Results for log
disp('These are the parameters used in the benchmark calibration:')

parameters
% solution of the system
% initial conditions for probabilites/ shares
p2_0 = 16/1000;
p1_0 = N - p2_0;
p3_0 = 0;
%p4_0 = 1 - p1_0 - p2_0 - p3_0;

% solving the ODE system
%tspan = linspace(0,2*365,2*365+1); % we solve for a period of two years
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
tMax = 2*365; % end of solution period for ODE
opts = odeset('RelTol',1e-6,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,2*365+1);
pout = deval(sol,tout);

p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t = [p1;p2;p3;p4]';
     
% calculate infection rate rho by using equation (1)
    rho = (N_t(:,2)+N_t(:,4))./(N_t(:,1)+N_t(:,2)+N_t(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12=parameters.a*N_t(:,1).^(-parameters.alpha_p).*(N_t(:,2)+parameters.eta.*N_t(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho,0)).^parameters.gamma_p; 
    
%% check daily new Sick    
N2new =diff(N2ever);
    
    
%% Match data -
    Nsick = [16, 18, 21, 26, 53, 66, 127, 152, 196, 262, 400, 639, 795, 902, 1139, 1296, 1567, 2369, 3062,  3795, 4838, 6012, 7156, 8198, 10999, 13957 ]; % from Robert Koch Institut LAST IS FROM 20/03/20 
    DeltaNsick = diff(Nsick);
    
    figure('name','check calibration')
    subplot(1,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)),DeltaNsick,'o','LineWidth',3)
    plot(Dates(1:length(DeltaNsick)+90),N2new(1:length(DeltaNsick)+90)*1000,'LineWidth',3)
    ylabel('incidences per day - $N_2^{new}$','Interpreter','Latex')
    %%xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    legend('data RKI','model prediction','location','northwest')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    hold off
    axis tight

    subplot(1,2,2)
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+90),N2ever(1:length(Nsick)+90)*1000,'LineWidth',3)
    ylabel('total incidences - $N_2^{ever}$','Interpreter','Latex')
    %%xlabel('Date')
    ax = gca;
    %ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('data RKI','model prediction','location','northwest')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 checkCalibration.eps
    print -dpng checkCalibration.png    
    
    
    
%% figures for entire timespan tspan
    figure('name','N over time');
    subplot(2,2,1)
    plot(Dates, N_t(:,1)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of healthy individuals - $N_1(t)$','Interpreter','Latex')
    datetick('x','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
    
    subplot(2,2,2)
    plot(Dates, N_t(:,2)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of infected individuals - $N_2(t)$','Interpreter','Latex')
    datetick('x','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight

    subplot(2,2,3)
    plot(Dates, N_t(:,3)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of dead individuals - $N_3(t)$','Interpreter','Latex')
    datetick('x','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
    
    subplot(2,2,4)
    plot(Dates, N_t(:,4)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of healthy inividuals after infection - $N_4(t)$','Interpreter','Latex')
    datetick('x','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
        
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 NOverTime.eps
    print -dpng NOverTime.png
    
    
%% figures for first 2 months
    figure('name','N over time 2 months');
    subplot(2,2,1)
    plot(Dates(1:shift), N_t(1:shift,1)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of healthy individuals - $N_1(t)$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:15:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
    
    subplot(2,2,2)
    plot(Dates(1:shift), N_t(1:shift,2)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of infected individuals - $N_2(t)$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:15:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
   
    subplot(2,2,3)
    plot(Dates(1:shift), N_t(1:shift,3)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of dead individuals - $N_3(t)$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:15:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
    
    subplot(2,2,4)
    plot(Dates(1:shift), N_t(1:shift,4)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('Number of healthy inividuals after infection - $N_4(t)$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:15:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',16)
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 NOverTime2Months.eps
    print -dpng NOverTime2Months.png

%% computing the number N2ever of individuals that ever turned sick from eq (7) in paper 

    figure('name','N2 ever');
    hold on
    plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+77),N2ever(1:length(Nsick)+77)*1000,'LineWidth',3)
    ylabel('Total Infections')
    %xlabel('Date')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('Data RKI','Model prediction','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])

    print -depsc2 N2ever.eps
    print -dpng N2ever.png


%% Figure 6 in the paper, hence p1(t)-p1(t-1)

p1_LaggedDifference = - diff(p1);
N1_LaggedDifference = - diff(N_t(:,1)*1000);


 figure('name','Change in the number of sick individuals per day');
    subplot(1,2,1);
    plot(Dates(2:end), N1_LaggedDifference,'LineWidth',3)
    %xlabel('Date')
    ylabel('$\Delta$sick (s=2)','Interpreter','Latex')
    datetick('x','keepticks','keeplimits')
    set(gca,'FontSize',28)
    axis tight
    
    subplot(1,2,2);
    plot(Dates(2:shift+1), N1_LaggedDifference(1:shift),'LineWidth',3)
    %xlabel('Date')
    ylabel('$\Delta$sick (s=2)','Interpreter','Latex')
    set(gca,'XTick',Dates(1:23:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    set(gca,'FontSize',28)
    axis tight   
    
    set(gcf,'position',[0,0,1920 ,1080])

    print -depsc2 changeInTheNumberOfSickIndividualsPerDay.eps
    print -dpng changeInTheNumberOfSickIndividualsPerDay.png
    

%% Plot figure (6) N2(t)

 figure('name','N2(t)');

    plot(Dates(1:shift+60), N_t(1:shift+60,2)*1000,'LineWidth',3)
    %xlabel('Date')
    ylabel('$N_2(t)$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:20:shift+60))
    datetick('x','mmm dd','keepticks','keeplimits')
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28)
    axis tight   
    
    set(gcf,'position',[0,0,1920 ,1080])

    print -depsc2 N2t.eps
    print -dpng N2t.png
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n\n',max(N_t(:,2)*1000),datestr(Dates(N_t(:,2)==max(N_t(:,2)))))
    
    
%%  N2(t)-N2(t-1)

N2_LaggedDifference = diff(N_t(:,2)*1000);

 figure('name','Change in N2(t)');
    subplot(1,2,1);
    plot(Dates(2:end), N2_LaggedDifference,'LineWidth',3)
    %xlabel('Date')
    ylabel('$\Delta$sick $N_2(t)$','Interpreter','Latex')
    datetick('x','keepticks','keeplimits')
    set(gca,'FontSize',28)
    axis tight
    
    subplot(1,2,2);
    plot(Dates(2:shift+1), N2_LaggedDifference(1:shift),'LineWidth',3)
    %xlabel('Date')
    ylabel('$\Delta$sick $N_2(t)$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:25:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    set(gca,'FontSize',28)
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])

    print -depsc2 changeInTheNumberOfSickIndividualsPerDay.eps
    print  -dpng changeInTheNumberOfSickIndividualsPerDay.png
    
%% calculate probabilites from equation (6)

p_gs_day = zeros(length(tout)-1,1);
p_gs_week = zeros(length(tout)-7,1);
for i=1:length(tout)-1
    p_gs_day(i) = 1 - exp(-trapz(lambda_12(i:i+1)));
end
for i=1:length(tout)-7
    p_gs_week(i) = 1 - exp(-trapz(lambda_12(i:i+7)));
end

figure('name','The probability per day (dotted) and per week (solid) to get sick');
hold on
plot(Dates(1:shift),p_gs_day(1:shift),'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
plot(Dates(1:shift),p_gs_week(1:shift), 'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
datetick('x','keepticks','keeplimits')

%xlabel('Date','Interpreter','Latex','FontSize', 28);
ylabel('probability of infection over the next day/week','Interpreter','Latex','FontSize', 28);
legend({'day','week'},'Interpreter','Latex','FontSize', 28)
set(gca,'FontSize',28)

axis tight
hold off

set(gcf,'position',[0,0,1920 ,1080])

print -depsc2 probabilityOfInfectionOverTheNextDayWeek.eps
print -dpng probabilityOfInfectionOverTheNextDayWeek.png


%% calculate newly sick equation (8)

figure('name','newlySick');
hold on
plot(Dates(1:shift),N2new(1:shift)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3)
datetick('x','keepticks','keeplimits')

xlabel('Date','Interpreter','Latex','FontSize', 28);
ylabel('Newly reported sick - $N_2^{new}$','Interpreter','Latex','FontSize', 28);
ax = gca;
ax.YRuler.Exponent = 0;
ytickformat('%,6.4g')
set(gca,'FontSize',28)

axis tight
hold off

set(gcf,'position',[0,0,1920 ,1080])

print -depsc2 newlySick.eps
print -dpng newlySick.png

%% Number of deaths equation (9)
N3dead= zeros(length(tout)-1,1);

for i=1:length(tout)-1
    N3dead(i) = trapz(parameters.lambda23*N_t(i:i+1,2));
end


figure('name','numberOfDeaths');
hold on
plot(Dates(1:shift),N3dead(1:shift)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3)
datetick('x','keepticks','keeplimits')

xlabel('Date','Interpreter','Latex','FontSize', 28);
ylabel('Number of deaths - $N_3(t)$','Interpreter','Latex','FontSize', 28);
set(gca,'FontSize',28)

axis tight
hold off

set(gcf,'position',[0,0,1920 ,1080])

print -depsc2 numberOfDeaths.eps
print -dpng numberOfDeaths.png

%% N3 ever 

N3ever=N_t(:,3);

figure('name','numberOfDeaths');
hold on
plot(Dates(1:shift),N3ever(1:shift)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth',3)
datetick('x','keepticks','keeplimits')

xlabel('Date','Interpreter','Latex','FontSize', 28);
ylabel('Total number of deaths','Interpreter','Latex','FontSize', 28);
ax = gca;
ax.YRuler.Exponent = 0;
ytickformat('%,6.4g')
set(gca,'FontSize',28)

axis tight
hold off

set(gcf,'position',[0,0,1920 ,1080])

print -depsc2 N3ever.eps
print -dpng N3ever.png

%% Death rate equation (10)
deathRate= zeros(length(tout)-1,1);

for i=1:length(tout)-1
    deathRate(i) = N_t(i,3)/(trapz(N_t(1:i,2)));
end


figure('name','deathRate');
hold on
plot(Dates(1:shift),deathRate(1:shift),'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3)
datetick('x','keepticks','keeplimits')

xlabel('Date','Interpreter','Latex','FontSize', 28);
ylabel('Death Rate - $\lambda_{23}$','Interpreter','Latex','FontSize', 28);
set(gca,'FontSize',28)

axis tight
hold off

set(gcf,'position',[0,0,1920 ,1080])

print -depsc2 deathRate.eps
print -dpng deathRate.png

%% figures

% infection rate rho (equation (1))
    figure('name','infection rate rho over time');
    plot(Dates(1:shift),rho(1:shift),'LineWidth',3)
    %xlabel('Date')
    ylabel('Infection rate - $\rho$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:15:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    set(gca,'FontSize',28)
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    saveas(gcf,'infectionRateRhoOverTime.png')
    saveas(gcf,'infectionRateRhoOverTime','epsc')
    
%% individual sickness rate lambda_{12} (equation (2))
    figure('name','individual sickness rate lambda_{12} over time');
    plot(Dates(1:shift),lambda_12(1:shift),'LineWidth',3)
    %xlabel('Date')
    ylabel('Individual sickness rate$\lambda_{12}$','Interpreter','Latex')
    set(gca,'XTick',Dates(1:15:shift))
    datetick('x','mmm dd','keepticks','keeplimits')
    set(gca,'FontSize',28)
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
      
    print -depsc2 individualSicknessRateLambda12OverTime.eps
    print -dpng individualSicknessRateLambda12OverTime.png

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shif2=160;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver

tClose=20;
tOpen=tClose+37;
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
[toutpolicyClose1,poutpolicyClose1] = ode45(@(t,p) ODE_syst_9(t,p,parameters), 0:tClose, BCS, opts);
BCS=[poutpolicyClose1(end-1,1) poutpolicyClose1(end-1,2) poutpolicyClose1(end-1,3) poutpolicyClose1(end-1,4)]; % Boundary conditions
[toutpolicyClose2,poutpolicyClose2] = ode45(@(t,p) ODE_syst_9_policyClose(t,p,parameters), tClose:tOpen, BCS, opts);
BCS=[poutpolicyClose2(end,1) poutpolicyClose2(end,2) poutpolicyClose2(end,3) poutpolicyClose2(end,4)];
[toutpolicyClose3,poutpolicyClose3] = ode45(@(t,p) ODE_syst_9(t,p,parameters), tOpen:tMax, BCS, opts);

toutpolicyClose=[toutpolicyClose1(1:end-1);toutpolicyClose2(1:end-1);toutpolicyClose3];
poutpolicyClose=[poutpolicyClose1(1:end-2,:);poutpolicyClose2(1:end-1,:);poutpolicyClose3];
% toutpolicyClose = linspace(0,tMax,2*365+1);
% poutpolicyClose = deval(solpolicyClose,toutpolicyClose);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1policyClose = poutpolicyClose(:,1);
p2policyClose = poutpolicyClose(:,2);
p3policyClose = poutpolicyClose(:,3);
p4policyClose = N - p1policyClose - p2policyClose - p3policyClose;
N2everPolicyClose = poutpolicyClose(:,4);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_tpolicyClose = [p1policyClose,p2policyClose,p3policyClose,p4policyClose];
    
    
    figure('name', 'policyExperimentShutDown')
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    %xline(Dates(tClose),'--r',{'Restrictive policy starts'},'FontSize',28,'LineWidth', 3);
    %xline(Dates(tOpen),'--r',{'Restrictive policy ends'},'FontSize',28,'LineWidth', 3);
    
    line([Dates(tClose) Dates(tClose)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    line([Dates(tOpen) Dates(tOpen)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tOpen)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy ends','Color','red','FontSize',28,'Rotation',90)
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',28)
    xlabel('Date','FontSize',28)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28) 
    legend({'Without Shut Down','With Shut Down'})
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 policyExperimentShutDown.eps
    print -dpng policyExperimentShutDown.png
    
    
%% Caluclate everything again
 
% calculate infection rate rho by using equation (1)
    rhopolicyClose = (N_tpolicyClose(:,2)+N_tpolicyClose(:,4))./(N_tpolicyClose(:,1)+N_tpolicyClose(:,2)+N_tpolicyClose(:,4));

% calculate the individual sickness rate lambda_{12}
lambda_12policyClose=zeros(tMax,1);
    for i=1:tClose
        lambda_12policyClose(i)=parameters.a*N_tpolicyClose(i,1).^(-parameters.alpha_p).*(N_tpolicyClose(i,2)+parameters.eta.*N_tpolicyClose(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyClose(i),0)).^parameters.gamma_p; 
    end
    for i=tClose+1:tOpen
        lambda_12policyClose(i)=0.5*parameters.a*N_tpolicyClose(i,1).^(-parameters.alpha_p).*(N_tpolicyClose(i,2)+parameters.eta.*N_tpolicyClose(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyClose(i),0)).^parameters.gamma_p; 
    end
    for i=tOpen+1:tMax
        lambda_12policyClose(i)=parameters.a*N_tpolicyClose(i,1).^(-parameters.alpha_p).*(N_tpolicyClose(i,2)+parameters.eta.*N_tpolicyClose(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyClose(i),0)).^parameters.gamma_p; 
    end
    
    
%N2everPolicyClose = cumsum(lambda_12policyClose.*N_tpolicyClose(:,1));

    figure('name','N2 ever');
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    
    line([Dates(tClose) Dates(tClose)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('Total sick - $N_2^{ever}$','Interpreter','Latex','FontSize',28)
    xlabel('Date','FontSize',28)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Shut Down','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 N2everPolicyExperimentShutDown.eps
    print -dpng N2everPolicyExperimentShutDown.png
    
%%  
fprintf('Maximal number of sick people at same time with Shut Down is %8.2f at %s \n',max(N_tpolicyClose(:,2)*1000),datestr(Dates(N_tpolicyClose(:,2)==max(N_tpolicyClose(:,2)))))
  
N2newPolicyClose= diff(N2everPolicyClose);

% get index where N_t^2<1000 again
tmax=find(N_tpolicyClose(:,2)==max(N_tpolicyClose(:,2)));
t1000=find(N_tpolicyClose(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2newPolicyClose(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N_tpolicyClose2(t) falls below 1000 on %s and N2newPolicyClose(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))

    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%% SHUT DOWN ONE WEEK LATER %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 policyExperimentShutDownLater
 
 
    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%% SHUT DOWN LONGER %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 policyExperimentShutDownLonger
 
     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%% SHUT DOWN Rigerous %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

policyExperimentShutDownRigorous
policyExperimentShutDownLax
 
    figure('name', 'policyExperimentShutDownRigorous')
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000, 'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseRigorous(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseLax(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0.6350, 0.0780, 0.1840],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    
    line([Dates(tClose-7) Dates(tClose-7)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose-7)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',28)
    xlabel('Date','FontSize',28)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Normal Down','With Rigorous Shut Down','With Lax Shut Down','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 policyExperimentShutDownRigorous.eps
    print -dpng policyExperimentShutDownRigorous.png
    
    
     figure('name','N2 ever Rigorous');
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseRigorous(1:length(Nsick)+shif2)*1000, 'Color',[0, 0.5, 0],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseLax(1:length(Nsick)+shif2)*1000, 'Color',[0.6350, 0.0780, 0.1840],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    
    line([Dates(tClose-7) Dates(tClose-7)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose-7)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    ylabel('Total sick $N_2^{ever}$','Interpreter','Latex','FontSize',28)
    xlabel('Date','FontSize',28)
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Normal Down','With Rigorous Shut Down','With Lax Shut Down','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 N2everPolicyExperimentShutDownRigorous.eps
    print -dpng N2everPolicyExperimentShutDownRigorous.png
  
   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% POLICY EXPERIMENT VERSION FOR PAPER %%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
shif2=180;
    figure('name', 'Version Paper N2')
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000, 'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseLate(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseLonger(1:length(DeltaNsick)+shif2,2)*1000,'Color','k','LineStyle','-','LineWidth',3,'Marker','d','MarkerSize',5)
    
    %xline(Dates(tClose-7),'--r',{'Restrictive policy starts'},'FontSize',28,'LineWidth', 2);
    
    line([Dates(tClose) Dates(tClose)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',28)
    %xlabel('Date','FontSize',28)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('without Shut Down','with Shut Down','with delayed Shut Down','with longer Shut Down','location','northeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 policyExperimentVersionPaper.eps
    print -dpng policyExperimentVersionPaper.png
    
    
     figure('name','N2 ever Version Paper');
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',3)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseLate(1:length(Nsick)+shif2)*1000, 'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseLonger(1:length(Nsick)+shif2)*1000, 'Color','k','LineStyle','-','LineWidth',3,'Marker','d','MarkerSize',5)
    
    %xline(Dates(tClose-7),'--r',{'Restrictive policy starts'},'FontSize',28,'LineWidth', 2);
    line([Dates(tClose) Dates(tClose)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    ylabel('total incidences - $N_2^{ever}$','Interpreter','Latex','FontSize',28)
    %xlabel('Date','FontSize',28)
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend('without Shut Down','with Shut Down','with delayed Shut Down','with longer Shut Down','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 N2everPolicyExperimentVersionPaper.eps
    print -dpng N2everPolicyExperimentVersionPaper.png
    
      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%% SHUT EFFECT RHOBAR %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

 policyExperimentShutDownRho
    
    
    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% DO %%%%%%%%%%%%%%%%%%
%%% ROBUSTNESS CHECKS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run('varyEstimation/makePlot.m');
run('varyR/makePlot.m');
run('varyEta/makePlot.m');

%% Save log
diary('Log.txt');
diary('off');