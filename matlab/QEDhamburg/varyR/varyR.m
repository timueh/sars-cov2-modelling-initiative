parameters.nr = 14; % recovery time in days
parameters.N = 83100; % population size in 1000

%%
[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters1000();

N = parameters.N;

Nsick = [16, 18, 21, 26, 53, 66, 127, 152, 196, 262, 400, 639, 795, 902, 1139, 1296, 1567, 2369, 3062,  3795, 4838, 6012, 7156, 8198, 10999, 13957 ];
DeltaNsick = diff(Nsick);

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
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,2*365+1);
pout = deval(sol,tout);

p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever_R1000 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_R1000 = [p1;p2;p3;p4]';
    
    rho_R1000 = (N_t_R1000(:,2)+N_t_R1000(:,4))./(N_t_R1000(:,1)+N_t_R1000(:,2)+N_t_R1000(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_R1000=parameters.a*N_t_R1000(:,1).^(-parameters.alpha_p).*(N_t_R1000(:,2)+parameters.eta.*N_t_R1000(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_R1000,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    
    disp('These are the parameters for r=.2 calibration:')
    parameters
    
    %error = sqrt(sum(((Nsick-(N2ever_R1000(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R1000(1:length(DeltaNsick),2))*1000)).^2));
    %fprintf('Error in last iteration: %f \n', error)
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_R1000(:,2)*1000),datestr(Dates(N_t_R1000(:,2)==max(N_t_R1000(:,2)))))
    
%% calculate newly sick equation (8)
N2new_R1000 = diff(N2ever_R1000);

% get index where N_t^2<1000 again
tmax=find(N_t_R1000(:,2)==max(N_t_R1000(:,2)));
t1000=find(N_t_R1000(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_R1000(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
    
%% DO r=0.01

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters100();
%
N = parameters.N;

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
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,2*365+1);
pout = deval(sol,tout);

p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever_R100 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_R100 = [p1;p2;p3;p4]';
    
    rho_R100 = (N_t_R100(:,2)+N_t_R100(:,4))./(N_t_R100(:,1)+N_t_R100(:,2)+N_t_R100(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_R100=parameters.a*N_t_R100(:,1).^(-parameters.alpha_p).*(N_t_R100(:,2)+parameters.eta.*N_t_R100(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_R100,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    disp('These are the parameters for r=.01 calibration:')
    parameters
    
    %error = sqrt(sum(((Nsick-(N2ever_R100(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R100(1:length(DeltaNsick),2))*1000)).^2));
    %fprintf('Error in last iteration: %f \n', error)
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_R100(:,2)*1000),datestr(Dates(N_t_R100(:,2)==max(N_t_R100(:,2)))))
    
 % calculate newly sick equation (8)
N2new_R100 = diff(N2ever_R100);

% get index where N_t^2<1000 again
tmax=find(N_t_R100(:,2)==max(N_t_R100(:,2)));
t1000=find(N_t_R100(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_R100(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))

%% DO .025

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters250();

N = parameters.N;

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
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,2*365+1);
pout = deval(sol,tout);

p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever_R250 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_R250 = [p1;p2;p3;p4]';
    
    rho_R250 = (N_t_R250(:,2)+N_t_R250(:,4))./(N_t_R250(:,1)+N_t_R250(:,2)+N_t_R250(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_R250=parameters.a*N_t_R250(:,1).^(-parameters.alpha_p).*(N_t_R250(:,2)+parameters.eta.*N_t_R250(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_R250,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)

    disp('These are the parameters for r=.025 calibration:')
    parameters
    
%     error = sqrt(sum(((Nsick-(N2ever_R250(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R250(1:length(DeltaNsick),2))*1000)).^2));
%     fprintf('Error in last iteration: %f \n', error)
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_R250(:,2)*1000),datestr(Dates(N_t_R250(:,2)==max(N_t_R250(:,2)))))
    
 % calculate newly sick equation (8)
N2new_R250 = diff(N2ever_R250);


% get index where N_t^2<1000 again
tmax=find(N_t_R250(:,2)==max(N_t_R250(:,2)));
t1000=find(N_t_R250(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_R250(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
    
%%  DO .05

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters500();

N = parameters.N;

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
N2ever_R500 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_R500 = [p1;p2;p3;p4]';
    
    rho_500 = (N_t_R500(:,2)+N_t_R500(:,4))./(N_t_R500(:,1)+N_t_R500(:,2)+N_t_R500(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_R500=parameters.a*N_t_R500(:,1).^(-parameters.alpha_p).*(N_t_R500(:,2)+parameters.eta.*N_t_R500(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_500,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
   
    disp('These are the parameters for r=.05 calibration:')
    parameters
    
%     error = sqrt(sum(((Nsick-(N2ever_R500(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R500(1:length(DeltaNsick),2))*1000)).^2));
%     fprintf('Error in last iteration: %f \n', error)
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_R500(:,2)*1000),datestr(Dates(N_t_R500(:,2)==max(N_t_R500(:,2)))))
    
% calculate newly sick equation (8)
N2new_R500 = diff(N2ever_R500);

% get index where N_t^2<1000 again
tmax=find(N_t_R500(:,2)==max(N_t_R500(:,2)));
t1000=find(N_t_R500(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_R500(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
    
%%  DO .1

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters750();

N = parameters.N;

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
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,2*365+1);
pout = deval(sol,tout);

p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever_R750 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_R750 = [p1;p2;p3;p4]';
    
    rho_R750 = (N_t_R750(:,2)+N_t_R750(:,4))./(N_t_R750(:,1)+N_t_R750(:,2)+N_t_R750(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_R750=parameters.a*N_t_R750(:,1).^(-parameters.alpha_p).*(N_t_R750(:,2)+parameters.eta.*N_t_R750(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_R750,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    
    disp('These are the parameters for r=.1 calibration:')
    parameters
    
%     error = sqrt(sum(((Nsick-(N2ever_R750(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R750(1:length(DeltaNsick),2))*1000)).^2));
%     fprintf('Error in last iteration: %f \n', error)
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_R750(:,2)*1000),datestr(Dates(N_t_R750(:,2)==max(N_t_R750(:,2)))))
    
% calculate newly sick equation (8)
N2new_R750 = diff(N2ever_R750);


% get index where N_t^2<1000 again
tmax=find(N_t_R750(:,2)==max(N_t_R750(:,2)));
t1000=find(N_t_R750(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_R750(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))

% %%  DO Hubai numbers
% 
% [parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParametersHubai();
% 
% N = parameters.N;
% 
% % solution of the system
% % initial conditions for probabilites/ shares
% p2_0 = 16/1000;
% p1_0 = N - p2_0;
% p3_0 = 0;
% %p4_0 = 1 - p1_0 - p2_0 - p3_0;
% 
% % solving the ODE system
% %tspan = linspace(0,2*365,2*365+1); % we solve for a period of two years
% BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
% tMax = 2*365; % end of solution period for ODE
% opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
% sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);
% 
% tout = linspace(0,tMax,2*365+1);
% pout = deval(sol,tout);
% 
% p1 = pout(1,:);
% p2 = pout(2,:);
% p3 = pout(3,:);
% p4 = N - p1 - p2 - p3;
% N2ever_RHubai = pout(4,:);
% 
% % Generate Dates for plotting - all from start as of 24 Feb 2020
%     dateStart = datetime(2020,02,24);
%     dateEnd = dateStart + tMax;
%     Dates = linspace(dateStart,dateEnd,length(tout));
% 
% % Calculate the persons belonging to each group_i, for i=1,2,3,4
%     N_t_RHubai = [p1;p2;p3;p4]';
%     
%     rho_RHubai = (N_t_RHubai(:,2)+N_t_RHubai(:,4))./(N_t_RHubai(:,1)+N_t_RHubai(:,2)+N_t_RHubai(:,4));
% 
% % calculate the individual sickness rate lambda_{12}
%     lambda_12_Rubai=parameters.a*N_t_RHubai(:,1).^(-parameters.alpha_p).*(N_t_RHubai(:,2)+parameters.eta.*N_t_RHubai(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_RHubai,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
%     
%     
%     disp('These are the parameters for r=Hubai calibration:')
%     parameters
%     
% %     error = sqrt(sum(((Nsick-(N2ever_R750(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R750(1:length(DeltaNsick),2))*1000)).^2));
% %     fprintf('Error in last iteration: %f \n', error)
%     
%     fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_RHubai(:,2)*1000),datestr(Dates(N_t_RHubai(:,2)==max(N_t_RHubai(:,2)))))
%     
% % calculate newly sick equation (8)
% N2new_RHubai = diff(N2ever_RHubai);
% 
% 
% % get index where N_t^2<1000 again
% tmax=find(N_t_RHubai(:,2)==max(N_t_RHubai(:,2)));
% t1000=find(N_t_RHubai(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% % get index where Nnew<1000 again
% tnew100=find(N2new_RHubai(tmax:end)*1000<100,1, 'first')+tmax-1;
% 
% fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
% 
% %% Do SK numbers
% [parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParametersSK();
% 
% N = parameters.N;
% 
% % solution of the system
% % initial conditions for probabilites/ shares
% p2_0 = 16/1000;
% p1_0 = N - p2_0;
% p3_0 = 0;
% %p4_0 = 1 - p1_0 - p2_0 - p3_0;
% 
% % solving the ODE system
% %tspan = linspace(0,2*365,2*365+1); % we solve for a period of two years
% BCS=[p1_0 p2_0 p3_0 p2_0]; % Boundary conditions
% tMax = 2*365; % end of solution period for ODE
% opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
% sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);
% 
% tout = linspace(0,tMax,2*365+1);
% pout = deval(sol,tout);
% 
% p1 = pout(1,:);
% p2 = pout(2,:);
% p3 = pout(3,:);
% p4 = N - p1 - p2 - p3;
% N2ever_RSK = pout(4,:);
% 
% % Generate Dates for plotting - all from start as of 24 Feb 2020
%     dateStart = datetime(2020,02,24);
%     dateEnd = dateStart + tMax;
%     Dates = linspace(dateStart,dateEnd,length(tout));
% 
% % Calculate the persons belonging to each group_i, for i=1,2,3,4
%     N_t_RSK = [p1;p2;p3;p4]';
%     
%     rho_RSK = (N_t_RSK(:,2)+N_t_RSK(:,4))./(N_t_RSK(:,1)+N_t_RSK(:,2)+N_t_RSK(:,4));
% 
% % calculate the individual sickness rate lambda_{12}
%     lambda_12_Rubai=parameters.a*N_t_RSK(:,1).^(-parameters.alpha_p).*(N_t_RSK(:,2)+parameters.eta.*N_t_RSK(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_RSK,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
%     
%     
%     disp('These are the parameters for r=South Korea calibration:')
%     parameters
%     
% %     error = sqrt(sum(((Nsick-(N2ever_R750(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-(N_t_R750(1:length(DeltaNsick),2))*1000)).^2));
% %     fprintf('Error in last iteration: %f \n', error)
%     
%     fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_RSK(:,2)*1000),datestr(Dates(N_t_RSK(:,2)==max(N_t_RSK(:,2)))))
%     
% % calculate newly sick equation (8)
% N2new_RSK = diff(N2ever_RSK);
% 
% 
% % get index where N_t^2<1000 again
% tmax=find(N_t_RSK(:,2)==max(N_t_RSK(:,2)));
% t1000=find(N_t_RSK(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% % get index where Nnew<1000 again
% tnew100=find(N2new_RSK(tmax:end)*1000<100,1, 'first')+tmax-1;
% 
% fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))