%% parameters

parameters.nr = 14; % recovery time in days
parameters.N = 83100; % population size in 1000

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters();

N = parameters.N;

%solution of the system
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
    lambda_12=parameters.a*N_t(:,1).^(-parameters.alpha_p).*(N_t(:,2)+parameters.eta.*N_t(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)

% computing the number N2ever of individuals that ever turned sick from eq (7) in paper 

    disp('These are the parameters for daily+total calibration:')
    parameters

    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t(:,2)*1000),datestr(Dates(N_t(:,2)==max(N_t(:,2)))))
% calculate newly sick equation (8)
N2new = diff(N2ever);

% get index where N_t^2<1000 again
tmax=find(N_t(:,2)==max(N_t(:,2)));
t1000=find(N_t(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new(tmax:end)<100*1000,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
%% Only focus on daily new infections

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParametersDaily();

N = parameters.N;

%solution of the system
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
N2ever_Daily = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Daily = [p1;p2;p3;p4]';
    
% calculate infection rate rho by using equation (1)
    rho_Daily = (N_t_Daily(:,2)+N_t_Daily(:,4))./(N_t_Daily(:,1)+N_t_Daily(:,2)+N_t_Daily(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Daily=parameters.a*N_t_Daily(:,1).^(-parameters.alpha_p).*(N_t_Daily(:,2)+parameters.eta.*N_t_Daily(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Daily,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)

% computing the number N2ever of individuals that ever turned sick from eq (7) in paper 
%

    disp('These are the parameters for daily calibration:')
    parameters

 fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Daily(:,2)*1000),datestr(Dates(N_t_Daily(:,2)==max(N_t_Daily(:,2)))))
% calculate newly sick equation (8)
N2new_Daily = diff(N2ever_Daily);

% get index where N_t^2<1000 again
tmax=find(N_t_Daily(:,2)==max(N_t_Daily(:,2)));
t1000=find(N_t_Daily(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Daily(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))

%% ONLY FOCUS ON TOTAL INFECTIONS

parameters.nr = 14; % recovery time in days
parameters.N = 83100; % population size in 1000

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParametersTotal();

N = parameters.N;

%solution of the system
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
N2ever_Total = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Total = [p1;p2;p3;p4]';
    
% calculate infection rate rho by using equation (1)
    rho_Total = (N_t_Total(:,2)+N_t_Total(:,4))./(N_t_Total(:,1)+N_t_Total(:,2)+N_t_Total(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Total=parameters.a*N_t_Total(:,1).^(-parameters.alpha_p).*(N_t_Total(:,2)+parameters.eta.*N_t_Total(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Total,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)

% computing the number N2ever of individuals that ever turned sick from eq (7) in paper 


    disp('These are the parameters for total calibration:')
    parameters

     fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Total(:,2)*1000),datestr(Dates(N_t_Total(:,2)==max(N_t_Total(:,2)))))
% calculate newly sick equation (8)
N2new_Total = diff(N2ever_Total);


% get index where N_t^2<1000 again
tmax=find(N_t_Total(:,2)==max(N_t_Total(:,2)));
t1000=find(N_t_Total(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Total(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))