%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%% POLICY EXPERIMENT %%%%%%%%%%%%%%%%%%
%%%%%%%%% SHUT DOWN RIGOROUSLY %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver

% toutpolicyClose=zeros(tMax,1);
% poutpolicyClose=zeros(tMax,3);
tClose=20;
tOpen=tClose+60;
BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
[toutpolicyClose1Rigorous,poutpolicyClose1Rigorous] = ode45(@(t,p) ODE_syst_9(t,p,parameters), 0:tClose, BCS, opts);
BCS=[poutpolicyClose1Rigorous(end-1,1) poutpolicyClose1Rigorous(end-1,2) poutpolicyClose1Rigorous(end-1,3) poutpolicyClose1Rigorous(end-1,4)]; % Boundary conditions
[toutpolicyClose2Rigorous,poutpolicyClose2Rigorous] = ode45(@(t,p) ODE_syst_9_policyCloseRigorous(t,p,parameters), tClose:tOpen, BCS, opts);
BCS=[poutpolicyClose2Rigorous(end,1) poutpolicyClose2Rigorous(end,2) poutpolicyClose2Rigorous(end,3) poutpolicyClose2Rigorous(end,4)];
[toutpolicyClose3Rigorous,poutpolicyClose3Rigorous] = ode45(@(t,p) ODE_syst_9(t,p,parameters), tOpen:tMax, BCS, opts);

% bla
toutpolicyCloseRigorous=[toutpolicyClose1Rigorous(1:end-1);toutpolicyClose2Rigorous(1:end-1);toutpolicyClose3Rigorous];
poutpolicyCloseRigorous=[poutpolicyClose1Rigorous(1:end-2,:);poutpolicyClose2Rigorous(1:end-1,:);poutpolicyClose3Rigorous];
% toutpolicyClose = linspace(0,tMax,2*365+1);
% poutpolicyClose = deval(solpolicyClose,toutpolicyClose);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1policyCloseRigorous = poutpolicyCloseRigorous(:,1);
p2policyCloseRigorous = poutpolicyCloseRigorous(:,2);
p3policyCloseRigorous = poutpolicyCloseRigorous(:,3);
p4policyCloseRigorous = N - p1policyCloseRigorous - p2policyCloseRigorous - p3policyCloseRigorous;
N2everPolicyCloseRigorous = poutpolicyCloseRigorous(:,4);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% CalcuRigorous the persons belonging to each group_i, for i=1,2,3,4
    N_tpolicyCloseRigorous = [p1policyCloseRigorous,p2policyCloseRigorous,p3policyCloseRigorous,p4policyCloseRigorous];
    
    

    
    
 %% CalucRigorous everything again
    %% calcuRigorous infection rate rho by using equation (1)
    rhopolicyCloseRigorous = (N_tpolicyCloseRigorous(:,2)+N_tpolicyCloseRigorous(:,4))./(N_tpolicyCloseRigorous(:,1)+N_tpolicyCloseRigorous(:,2)+N_tpolicyCloseRigorous(:,4));

% calcuRigorous the individual sickness rate lambda_{12}
lambda_12policyCloseRigorous=zeros(tMax,1);
    for i=1:tClose
        lambda_12policyCloseRigorous(i)=parameters.a*N_tpolicyCloseRigorous(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseRigorous(i,2)+parameters.eta.*N_tpolicyCloseRigorous(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseRigorous(i),0)).^parameters.gamma_p; 
    end
    for i=tClose+1:tOpen
        lambda_12policyCloseRigorous(i)=0.5*parameters.a*N_tpolicyCloseRigorous(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseRigorous(i,2)+parameters.eta.*N_tpolicyCloseRigorous(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseRigorous(i),0)).^parameters.gamma_p; 
    end
    for i=tOpen+1:tMax
        lambda_12policyCloseRigorous(i)=parameters.a*N_tpolicyCloseRigorous(i,1).^(-parameters.alpha_p).*(N_tpolicyCloseRigorous(i,2)+parameters.eta.*N_tpolicyCloseRigorous(i,4)).^parameters.beta_p.*(max(parameters.rhoBar-rhopolicyCloseRigorous(i),0)).^parameters.gamma_p; 
    end
    
    
%N2everPolicyCloseRigorous = cumsum(lambda_12policyCloseRigorous.*N_tpolicyCloseRigorous(:,1));

   