parameters.nr = 14; % recovery time in days
parameters.N = 83100; % population size in 1000

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters25();

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
opts = odeset('RelTol',1e-9,'AbsTol',1e-9,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,2*365+1);
pout = deval(sol,tout);

p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever_Eta25 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Eta25 = [p1;p2;p3;p4]';
    
    rho_Eta25 = (N_t_Eta25(:,2)+N_t_Eta25(:,4))./(N_t_Eta25(:,1)+N_t_Eta25(:,2)+N_t_Eta25(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Eta25=parameters.a*N_t_Eta25(:,1).^(-parameters.alpha_p).*(N_t_Eta25(:,2)+parameters.eta.*N_t_Eta25(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Eta25,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    
    disp('These are the parameters for eta=.25 calibration:')
    parameters
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Eta25(:,2)*1000),datestr(Dates(N_t_Eta25(:,2)==max(N_t_Eta25(:,2)))))
% calculate newly sick equation (8)
N2new_Eta25 = diff(N2ever_Eta25);


% get index where N_t^2<1000 again
tmax=find(N_t_Eta25(:,2)==max(N_t_Eta25(:,2)));
t1000=find(N_t_Eta25(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Eta25(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))
        
    
%% DO 40

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters40();

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
N2ever_Eta40 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Eta40 = [p1;p2;p3;p4]';
    
    rho_Eta40 = (N_t_Eta40(:,2)+N_t_Eta40(:,4))./(N_t_Eta40(:,1)+N_t_Eta40(:,2)+N_t_Eta40(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Eta40=parameters.a*N_t_Eta40(:,1).^(-parameters.alpha_p).*(N_t_Eta40(:,2)+parameters.eta.*N_t_Eta40(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Eta40,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    
    disp('These are the parameters for eta=.4 calibration:')
    parameters
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Eta40(:,2)*1000),datestr(Dates(N_t_Eta40(:,2)==max(N_t_Eta40(:,2)))))
% calculate newly sick equation (8)
N2new_Eta40 = diff(N2ever_Eta40);

% get index where N_t^2<1000 again
tmax=find(N_t_Eta40(:,2)==max(N_t_Eta40(:,2)));
t1000=find(N_t_Eta40(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Eta40(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))    
    
%% DO 60

[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters60();

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
N2ever_Eta60 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Eta60 = [p1;p2;p3;p4]';
    
    rho_Eta60 = (N_t_Eta60(:,2)+N_t_Eta60(:,4))./(N_t_Eta60(:,1)+N_t_Eta60(:,2)+N_t_Eta60(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Eta60=parameters.a*N_t_Eta60(:,1).^(-parameters.alpha_p).*(N_t_Eta60(:,2)+parameters.eta.*N_t_Eta60(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Eta60,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    disp('These are the parameters for eta=.6 calibration:')
    parameters
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Eta60(:,2)*1000),datestr(Dates(N_t_Eta60(:,2)==max(N_t_Eta60(:,2)))))
  % calculate newly sick equation (8)
N2new_Eta60 = diff(N2ever_Eta60);


% get index where N_t^2<1000 again
tmax=find(N_t_Eta60(:,2)==max(N_t_Eta60(:,2)));
t1000=find(N_t_Eta60(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Eta60(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))      
    
%%  DO 75


[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters75();

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
N2ever_Eta75 = pout(4,:);


% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Eta75 = [p1;p2;p3;p4]';
    
    rho_Eta75 = (N_t_Eta75(:,2)+N_t_Eta75(:,4))./(N_t_Eta75(:,1)+N_t_Eta75(:,2)+N_t_Eta75(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Eta75=parameters.a*N_t_Eta75(:,1).^(-parameters.alpha_p).*(N_t_Eta75(:,2)+parameters.eta.*N_t_Eta75(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Eta75,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
    
    disp('These are the parameters for eta=.75 calibration:')
    parameters
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Eta75(:,2)*1000),datestr(Dates(N_t_Eta75(:,2)==max(N_t_Eta75(:,2)))))
 
    % calculate newly sick equation (8)
N2new_Eta75 = diff(N2ever_Eta75);


% get index where N_t^2<1000 again
tmax=find(N_t_Eta75(:,2)==max(N_t_Eta75(:,2)));
t1000=find(N_t_Eta75(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Eta75(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))    
%%  DO 90


[parameters.eta, parameters.alpha_p, parameters.beta_p, parameters.gamma_p,parameters.lambda23,parameters.r,parameters.rhoBar,parameters.a] = getOptimalParameters90();

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
N2ever_Eta90 = pout(4,:);

% Generate Dates for plotting - all from start as of 24 Feb 2020
    dateStart = datetime(2020,02,24);
    dateEnd = dateStart + tMax;
    Dates = linspace(dateStart,dateEnd,length(tout));

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t_Eta90 = [p1;p2;p3;p4]';
    
    rho_Eta90 = (N_t_Eta90(:,2)+N_t_Eta90(:,4))./(N_t_Eta90(:,1)+N_t_Eta90(:,2)+N_t_Eta90(:,4));

% calculate the individual sickness rate lambda_{12}
    lambda_12_Eta90=parameters.a*N_t_Eta90(:,1).^(-parameters.alpha_p).*(N_t_Eta90(:,2)+parameters.eta.*N_t_Eta90(:,4)).^parameters.beta_p.*(max(parameters.rhoBar-rho_Eta90,0)).^parameters.gamma_p; % Quickfix by rene to avoid complex numers: max(rhoBar-rho,0)
      
    disp('These are the parameters for eta=.9 calibration:')
    parameters
    
    fprintf('Maximal number of sick people at same time is %8.2f at %s \n',max(N_t_Eta90(:,2)*1000),datestr(Dates(N_t_Eta90(:,2)==max(N_t_Eta90(:,2)))))

    % calculate newly sick equation (8)
N2new_Eta90 = diff(N2ever_Eta90);


% get index where N_t^2<1000 again
tmax=find(N_t_Eta90(:,2)==max(N_t_Eta90(:,2)));
t1000=find(N_t_Eta90(tmax:end,2)*1000<1000, 1, 'first')+tmax-1;
% get index where Nnew<1000 again
tnew100=find(N2new_Eta90(tmax:end)*1000<100,1, 'first')+tmax-1;

fprintf('N2(t) falls below 1000 on %s and N2new(t) falls below 100 on %s. \n\n',datestr(Dates(t1000)),datestr(Dates(tnew100)))    