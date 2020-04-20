%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%%%%%%%% SHUT DOWN ONE WEEK LATER %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver

% toutpolicyClose=zeros(tMax,1);
% poutpolicyClose=zeros(tMax,3);
delay=32;
tClose=20+delay;
tOpen=tClose+37;
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
[toutpolicyClose1Late,poutpolicyClose1Late] = ode45(@(t,p) ODE_syst_9(t,p,parameters), 0:tClose, BCS, opts);
BCS=[poutpolicyClose1Late(end-1,1) poutpolicyClose1Late(end-1,2) poutpolicyClose1Late(end-1,3)  poutpolicyClose1Late(end-1,4)]; % Boundary conditions
[toutpolicyClose2Late,poutpolicyClose2Late] = ode45(@(t,p) ODE_syst_9_policyClose(t,p,parameters), tClose:tOpen, BCS, opts);
BCS=[poutpolicyClose2Late(end,1) poutpolicyClose2Late(end,2) poutpolicyClose2Late(end,3) poutpolicyClose2Late(end,4)];
[toutpolicyClose3Late,poutpolicyClose3Late] = ode45(@(t,p) ODE_syst_9(t,p,parameters), tOpen:tMax, BCS, opts);

% bla
toutpolicyCloseLate=[toutpolicyClose1Late(1:end-1);toutpolicyClose2Late(1:end-1);toutpolicyClose3Late];
poutpolicyCloseLate=[poutpolicyClose1Late(1:end-2,:);poutpolicyClose2Late(1:end-1,:);poutpolicyClose3Late];
% toutpolicyClose = linspace(0,tMax,2*365+1);
% poutpolicyClose = deval(solpolicyClose,toutpolicyClose);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1policyCloseLate = poutpolicyCloseLate(:,1);
p2policyCloseLate = poutpolicyCloseLate(:,2);
p3policyCloseLate = poutpolicyCloseLate(:,3);
p4policyCloseLate = N - p1policyCloseLate - p2policyCloseLate - p3policyCloseLate;
N2everPolicyCloseLate =  poutpolicyCloseLate(:,4);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_tpolicyCloseLate = [p1policyCloseLate,p2policyCloseLate,p3policyCloseLate,p4policyCloseLate];
    
    
    figure('name', 'policyExperimentShutDown')
    hold on
    plot(Dates(1:length(DeltaNsick)+shif2),N_t(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyClose(1:length(DeltaNsick)+shif2,2)*1000, 'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(DeltaNsick)+shif2),N_tpolicyCloseLate(1:length(DeltaNsick)+shif2,2)*1000,'Color',[0, 0.5, 0],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    %xline(Dates(tClose-7),'--r',{'Restrictive policy early'},'FontSize',20,'LineWidth', 2);
    %xline(Dates(tClose),'--r',{'Restrictive policy late'},'FontSize',20,'LineWidth', 2);
    
    line([Dates(tClose-delay) Dates(tClose-delay)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose-delay)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy early','Color','red','FontSize',28,'Rotation',90)
    
    line([Dates(tClose) Dates(tClose)],[0 max(N_t(1:length(DeltaNsick)+shif2,2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N_t(1:length(DeltaNsick)+shif2,2))*550,'Restrictive policy late','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('$N_2(t)$','Interpreter','Latex','FontSize',20)
    xlabel('Date','FontSize',20)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Early Down','With Late Shut Down','location','northeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 policyExperimentShutDownLate.eps
    print -dpng policyExperimentShutDownLate.png
    
    
 %% Caluclate everything again
    %% calculate infection rate rho by using equation (1)
    rhopolicyCloseLate = (N_tpolicyCloseLate(:,2)+N_tpolicyCloseLate(:,4))./(N_tpolicyCloseLate(:,1)+N_tpolicyCloseLate(:,2)+N_tpolicyCloseLate(:,4));

% calculate the individual sickness rate lambda_{12}
lambda_12policyCloseLate=zeros(tMax,1);
    for i=1:tClose
        lambda_12policyCloseLate(i)=parameters.a*N_tpolicyCloseLate(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLate(i,2)+parameters.eta.*N_tpolicyCloseLate(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLate(i),0)).^parameters.gamma_p; 
    end
    for i=tClose+1:tOpen
        lambda_12policyCloseLate(i)=0.5*parameters.a*N_tpolicyCloseLate(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLate(i,2)+parameters.eta.*N_tpolicyCloseLate(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLate(i),0)).^parameters.gamma_p; 
    end
    for i=tOpen+1:tMax
        lambda_12policyCloseLate(i)=parameters.a*N_tpolicyCloseLate(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLate(i,2)+parameters.eta.*N_tpolicyCloseLate(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLate(i),0)).^parameters.gamma_p; 
    end
    
    
%N2everPolicyCloseLate = cumsum(lambda_12policyCloseLate.*N_tpolicyCloseLate(:,1));

    figure('name','N2 ever');
    hold on
    %plot(Dates(1:length(Nsick)),Nsick,'o','LineWidth',2)
    plot(Dates(1:length(Nsick)+shif2),N2ever(1:length(Nsick)+shif2)*1000,'Color',[0, 0.4470, 0.7410],'LineStyle','-','LineWidth', 3,'Marker','s','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyClose(1:length(Nsick)+shif2)*1000,'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-','LineWidth', 3,'Marker','o','MarkerSize',5)
    plot(Dates(1:length(Nsick)+shif2),N2everPolicyCloseLate(1:length(Nsick)+shif2)*1000, 'Color',[0, 0.5, 0],'LineStyle','-','LineWidth',3,'Marker','x','MarkerSize',5)
    %xline(Dates(tClose-7),'--r',{'Restrictive policy early'},'FontSize',20,'LineWidth', 2);
    %xline(Dates(tClose),'--r',{'Restrictive policy late'},'FontSize',20,'LineWidth', 2);
    
    line([Dates(tClose-delay) Dates(tClose-delay)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose-delay)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy early','Color','red','FontSize',28,'Rotation',90)
    
    line([Dates(tClose) Dates(tClose)],[0 max(N2ever(1:length(DeltaNsick)+shif2))*1000],'Color','red','LineStyle','--','LineWidth', 3)
    text(Dates(tClose)+3,max(N2ever(1:length(DeltaNsick)+shif2))*550,'Restrictive policy late','Color','red','FontSize',28,'Rotation',90)
    
    ylabel('Total Infections','FontSize',20)
    xlabel('Date','FontSize',20)
    ax = gca;
    ax.YRuler.Exponent = 0;
    ytickformat('%,6.4g')
    set(gca,'FontSize',20) % Achsenbeschriftung und Legende
    legend('Without Shut Down','With Early Down','With Late Shut Down','location','southeast')
    hold off
    axis tight
    
    set(gcf,'position',[0,0,1920 ,1080])
    
    print -depsc2 N2everPolicyExperimentShutDownLate.eps
    print -dpng N2everPolicyExperimentShutDownLate.png
    
    
 %%  
   fprintf('Maximal number of sick people at same time with later Shut Down is %8.2f at %s \n',max(N_tpolicyCloseLate(:,2)*1000),datestr(Dates(N_tpolicyCloseLate(:,2)==max(N_tpolicyCloseLate(:,2)))))
N2newPolicyCloseLate = diff(N2everPolicyCloseLate);

% get index where N_t^2<1000 again
tmax=find(N_tpolicyCloseLate(:,2)==max(N_tpolicyCloseLate(:,2)));
t1000=find(N_tpolicyCloseLate(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2newPolicyCloseLate(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N_tpolicyCloseLate2(t) falls below 1000 on %s and N2newPolicyCloseLate(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))