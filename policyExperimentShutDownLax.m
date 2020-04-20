%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%%%%%%%% SHUT DOWN LaxLY %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver

% toutpolicyClose=zeros(tMax,1);
% poutpolicyClose=zeros(tMax,3);
tClose=20;
tOpen=tClose+60;
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
[toutpolicyClose1Lax,poutpolicyClose1Lax] = ode45(@(t,p) ODE_syst_9(t,p,parameters), 0:tClose, BCS, opts);
BCS=[poutpolicyClose1Lax(end-1,1) poutpolicyClose1Lax(end-1,2) poutpolicyClose1Lax(end-1,3) poutpolicyClose1Lax(end-1,4)]; % Boundary conditions
[toutpolicyClose2Lax,poutpolicyClose2Lax] = ode45(@(t,p) ODE_syst_9_policyCloseLax(t,p,parameters), tClose:tOpen, BCS, opts);
BCS=[poutpolicyClose2Lax(end,1) poutpolicyClose2Lax(end,2) poutpolicyClose2Lax(end,3) poutpolicyClose2Lax(end,4)];
[toutpolicyClose3Lax,poutpolicyClose3Lax] = ode45(@(t,p) ODE_syst_9(t,p,parameters), tOpen:tMax, BCS, opts);

% bla
toutpolicyCloseLax=[toutpolicyClose1Lax(1:end-1);toutpolicyClose2Lax(1:end-1);toutpolicyClose3Lax];
poutpolicyCloseLax=[poutpolicyClose1Lax(1:end-2,:);poutpolicyClose2Lax(1:end-1,:);poutpolicyClose3Lax];
% toutpolicyClose = linspace(0,tMax,2*365+1);
% poutpolicyClose = deval(solpolicyClose,toutpolicyClose);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1policyCloseLax = poutpolicyCloseLax(:,1);
p2policyCloseLax = poutpolicyCloseLax(:,2);
p3policyCloseLax = poutpolicyCloseLax(:,3);
p4policyCloseLax = N - p1policyCloseLax - p2policyCloseLax - p3policyCloseLax;
N2everPolicyCloseLax = poutpolicyCloseLax(:,4);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% CalcuLax the persons belonging to each group_i, for i=1,2,3,4
    N_tpolicyCloseLax = [p1policyCloseLax,p2policyCloseLax,p3policyCloseLax,p4policyCloseLax];
    
    

    
    
 %% CalucLax everything again
    %% calcuLax infection rate rho by using equation (1)
    rhopolicyCloseLax = (N_tpolicyCloseLax(:,2)+N_tpolicyCloseLax(:,4))./(N_tpolicyCloseLax(:,1)+N_tpolicyCloseLax(:,2)+N_tpolicyCloseLax(:,4));

% calcuLax the individual sickness rate lambda_{12}
lambda_12policyCloseLax=zeros(tMax,1);
    for i=1:tClose
        lambda_12policyCloseLax(i)=parameters.a*N_tpolicyCloseLax(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLax(i,2)+parameters.eta.*N_tpolicyCloseLax(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLax(i),0)).^parameters.gamma_p; 
    end
    for i=tClose+1:tOpen
        lambda_12policyCloseLax(i)=0.5*parameters.a*N_tpolicyCloseLax(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLax(i,2)+parameters.eta.*N_tpolicyCloseLax(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLax(i),0)).^parameters.gamma_p; 
    end
    for i=tOpen+1:tMax
        lambda_12policyCloseLax(i)=parameters.a*N_tpolicyCloseLax(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseLax(i,2)+parameters.eta.*N_tpolicyCloseLax(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseLax(i),0)).^parameters.gamma_p; 
    end
    

   