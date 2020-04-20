%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%%%%%%%% SHUT DOWN Longer %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver

% toutpolicyClose=zeros(tMax,1);
% poutpolicyClose=zeros(tMax,3);
tClose=20;
tOpen=tClose+94;
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
[toutpolicyClose1Longer,poutpolicyClose1Longer] = ode45(@(t,p) ODE_syst_9(t,p,parameters), 0:tClose, BCS, opts);
BCS=[poutpolicyClose1Longer(end-1,1) poutpolicyClose1Longer(end-1,2) poutpolicyClose1Longer(end-1,3) poutpolicyClose1Longer(end-1,4)]; % Boundary conditions
[toutpolicyClose2Longer,poutpolicyClose2Longer] = ode45(@(t,p) ODE_syst_9_policyClose(t,p,parameters), tClose:tOpen, BCS, opts);
BCS=[poutpolicyClose2Longer(end,1) poutpolicyClose2Longer(end,2) poutpolicyClose2Longer(end,3) poutpolicyClose2Longer(end,4)];
[toutpolicyClose3Longer,poutpolicyClose3Longer] = ode45(@(t,p) ODE_syst_9(t,p,parameters), tOpen:tMax, BCS, opts);

% bla
toutpolicyCloseLonger=[toutpolicyClose1Longer(1:end-1);toutpolicyClose2Longer(1:end-1);toutpolicyClose3Longer];
poutpolicyCloseLonger=[poutpolicyClose1Longer(1:end-2,:);poutpolicyClose2Longer(1:end-1,:);poutpolicyClose3Longer];
% toutpolicyClose = linspace(0,tMax,2*365+1);
% poutpolicyClose = deval(solpolicyClose,toutpolicyClose);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1policyCloseLonger = poutpolicyCloseLonger(:,1);
p2policyCloseLonger = poutpolicyCloseLonger(:,2);
p3policyCloseLonger = poutpolicyCloseLonger(:,3);
p4policyCloseLonger = N - p1policyCloseLonger - p2policyCloseLonger - p3policyCloseLonger;
N2everPolicyCloseLonger = poutpolicyCloseLonger(:,4);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_tpolicyCloseLonger = [p1policyCloseLonger,p2policyCloseLonger,p3policyCloseLonger,p4policyCloseLonger];
    
    
    figure('name', 'policyExperimentShutDown')
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000, 'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseLonger(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    
    line([Dates(tClose) Dates(tClose)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',20)
    xlabel('Date','FontSize',20)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Short Shut Down','With Longer Shut Down','location','northeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
      
    print -depsc2 policyExperimentShutDownLonger.eps
    print -dpng policyExperimentShutDownLonger.png
    
 %% Caluclate everything again
    %% calculate infection rate rho by using equation (1)
    rhopolicyCloseLonger = (N_tpolicyCloseLonger(:,2)+N_tpolicyCloseLonger(:,4))./(N_tpolicyCloseLonger(:,1)+N_tpolicyCloseLonger(:,2)+N_tpolicyCloseLonger(:,4));

% calculate the individual sickness rate lambda_{12}
lambda_12policyCloseLonger=zeros(tMax,1);
    for i=1:tClose
        lambda_12policyCloseLonger(i)=parameters.a*N_tpolicyCloseLonger(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLonger(i,2)+parameters.eta.*N_tpolicyCloseLonger(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLonger(i),0)).^parameters.gamma_p; 
    end
    for i=tClose+1:tOpen
        lambda_12policyCloseLonger(i)=0.5*parameters.a*N_tpolicyCloseLonger(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLonger(i,2)+parameters.eta.*N_tpolicyCloseLonger(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLonger(i),0)).^parameters.gamma_p; 
    end
    for i=tOpen+1:tMax
        lambda_12policyCloseLonger(i)=parameters.a*N_tpolicyCloseLonger(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLonger(i,2)+parameters.eta.*N_tpolicyCloseLonger(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLonger(i),0)).^parameters.gamma_p; 
    end
    
    
%N2everPolicyCloseLonger = cumsum(lambda_12policyCloseLonger.*N_tpolicyCloseLonger(:,1));

    figure('name','N2 ever');
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',2)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseLonger(1:length(Nsick)+shif2)*1000, 'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
   
    line([Dates(tClose) Dates(tClose)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy starts','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('Total Infections','FontSize',20)
    xlabel('Date','FontSize',20)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Short Down','With Longer Shut Down','location','southeast')
    hold off
    axis tight

    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 N2everPolicyExperimentShutDownLonger.eps
    print -dpng N2everPolicyExperimentShutDownLonger.png
  
 %%
fprintf('Maximal number of sick people at same time with longer Shut Down is %8.2f at %s \n',max(N_tpolicyCloseLonger(:,2)*1000),datestr(Dates(N_tpolicyCloseLonger(:,2)==max(N_tpolicyCloseLonger(:,2)))))
N2newPolicyCloseLonger = diff(N2everPolicyCloseLonger);

% get index where N_t^2<1000 again
tmax=find(N_tpolicyCloseLonger(:,2)==max(N_tpolicyCloseLonger(:,2)));
t1000=find(N_tpolicyCloseLonger(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2newPolicyCloseLonger(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N_tpolicyCloseLonger2(t) falls below 1000 on %s and N2newPolicyCloseLonger(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))