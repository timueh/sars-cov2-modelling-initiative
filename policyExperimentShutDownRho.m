%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%%%%%%%% SHUT DOWN Rho %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
shif2=150;
% toutpolicyClose=zeros(tMax,1);
% poutpolicyClose=zeros(tMax,3);
tClose=20;
tOpen=tClose+37;
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
[toutpolicyClose1Rho,poutpolicyClose1Rho] = ode45(@(t,p) ODE_syst_9(t,p,parameters), 0:tClose, BCS, opts);
BCS=[poutpolicyClose1Rho(end-1,1) poutpolicyClose1Rho(end-1,2) poutpolicyClose1Rho(end-1,3) poutpolicyClose1Rho(end-1,4)]; % Boundary conditions
[toutpolicyClose2Rho,poutpolicyClose2Rho] = ode45(@(t,p) ODE_syst_9_policyCloseRho(t,p,parameters), tClose:tOpen, BCS, opts);
BCS=[poutpolicyClose2Rho(end,1) poutpolicyClose2Rho(end,2) poutpolicyClose2Rho(end,3) poutpolicyClose2Rho(end,4)];
[toutpolicyClose3Rho,poutpolicyClose3Rho] = ode45(@(t,p) ODE_syst_9_policyCloseRhoNew(t,p,parameters), tOpen:tMax, BCS, opts);

% bla
toutpolicyCloseRho=[toutpolicyClose1Rho(1:end-1);toutpolicyClose2Rho(1:end-1);toutpolicyClose3Rho];
poutpolicyCloseRho=[poutpolicyClose1Rho(1:end-2,:);poutpolicyClose2Rho(1:end-1,:);poutpolicyClose3Rho];
% toutpolicyClose = linspace(0,tMax,2*365+1);
% poutpolicyClose = deval(solpolicyClose,toutpolicyClose);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1policyCloseRho = poutpolicyCloseRho(:,1);
p2policyCloseRho = poutpolicyCloseRho(:,2);
p3policyCloseRho = poutpolicyCloseRho(:,3);
p4policyCloseRho = N - p1policyCloseRho - p2policyCloseRho - p3policyCloseRho;
N2everPolicyCloseRho = poutpolicyCloseRho(:,4);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_tpolicyCloseRho = [p1policyCloseRho,p2policyCloseRho,p3policyCloseRho,p4policyCloseRho];
    
    
    figure('name', 'policyExperimentShutDown')
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000, 'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseRho(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    
    line([Dates(tClose) Dates(tClose)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',28)
    %xlabel('Date','FontSize',20)
    ax = gca;
    %ax.YRuler.Exponent = 0;
   % ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend({'Without Shut Down','With Shut Down','With adjustment $\bar{\rho}$'},'Interpreter','Latex','location','northeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
      
    print -depsc2 policyExperimentShutDownRho.eps
    print -dpng policyExperimentShutDownRho.png
    
 %% Caluclate everything again
    %% calculate infection rate rho by using equation (1)
    rhopolicyCloseRho = (N_tpolicyCloseRho(:,2)+N_tpolicyCloseRho(:,4))./(N_tpolicyCloseRho(:,1)+N_tpolicyCloseRho(:,2)+N_tpolicyCloseRho(:,4));

% calculate the individual sickness rate lambda_{12}
lambda_12policyCloseRho=zeros(tMax,1);
    for i=1:tClose
        lambda_12policyCloseRho(i)=parameters.a*N_tpolicyCloseRho(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseRho(i,2)+parameters.eta.*N_tpolicyCloseRho(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseRho(i),0)).^parameters.gamma_p; 
    end
    for i=tClose+1:tOpen
        lambda_12policyCloseRho(i)=0.5*parameters.a*N_tpolicyCloseRho(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseRho(i,2)+parameters.eta.*N_tpolicyCloseRho(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseRho(i),0)).^parameters.gamma_p; 
    end
    for i=tOpen+1:tMax
        lambda_12policyCloseRho(i)=parameters.a*N_tpolicyCloseRho(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseRho(i,2)+parameters.eta.*N_tpolicyCloseRho(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseRho(i),0)).^parameters.gamma_p; 
    end
    
    
%N2everPolicyCloseRho = cumsum(lambda_12policyCloseRho.*N_tpolicyCloseRho(:,1));

    figure('name','N2 ever');
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',2)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseRho(1:length(Nsick)+shif2)*1000, 'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
   
    line([Dates(tClose) Dates(tClose)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('total incidences - $N_2^{ever}$','Interpreter','Latex','FontSize',20)
    %xlabel('Date','FontSize',20)
    ax = gca;
    %ax.YRuler.Exponent = 0;
   % ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    legend({'without Shut Down','with Shut Down','with adjustment $\bar{\rho}$'},'Interpreter','Latex','location','southeast')
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 N2everPolicyExperimentShutDownRho.eps
    print -dpng N2everPolicyExperimentShutDownRho.png
    
    %%
%%%%% In One Subplot

figure('name','Policy rhoBar Subplot');
subplot(1,2,1)
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000, 'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseRho(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    
    line([Dates(tClose) Dates(tClose)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',28)
    %xlabel('Date','FontSize',20)
    ax = gca;
    %ax.YRuler.Exponent = 0;
   % ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    %legend({'without Shut Down','with Shut Down','with adjustment $\bar{\rho}$'},'Interpreter','Latex','location','northeast')
    hold off
    axis tight
    
    
subplot(1,2,2)
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',2)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseRho(1:length(Nsick)+shif2)*1000, 'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
   
    line([Dates(tClose) Dates(tClose)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('total incidences - $N_2^{ever}$','Interpreter','Latex','FontSize',20)
    %xlabel('Date','FontSize',20)
    ax = gca;
    %ax.YRuler.Exponent = 0;
   % ytickformat('%,6.4g')
    set(gca,'FontSize',28) % Achsenbeschriftung und Legende
    %legend({'without Shut Down','with Shut Down','with adjustment $\bar{\rho}$'},'Interpreter','Latex','location','southeast')
    hold off
    axis tight
    
 set(gcf,'position',[0,0,1920 ,1080])
      
    print -depsc2 policyExperimentShutDownRhoSubplot.eps
    print -dpng policyExperimentShutDownRhoSubplot.png
    
    
  %%  
fprintf('Maximal number of sick people at same time with lower rhoBar after Shut Down is %8.2f at %s \n',max(N_tpolicyCloseRho(:,2)*1000),datestr(Dates(N_tpolicyCloseRho(:,2)==max(N_tpolicyCloseRho(:,2)))))
N2newPolicyCloseRho = diff(N2everPolicyCloseRho);

% get index where N_t^2<1000 again
tmax=find(N_tpolicyCloseRho(:,2)==max(N_tpolicyCloseRho(:,2)));
t1000=find(N_tpolicyCloseRho(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2newPolicyCloseRho(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N_tpolicyCloseRho2(t) falls below 1000 on %s and N2newPolicyCloseRho(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
