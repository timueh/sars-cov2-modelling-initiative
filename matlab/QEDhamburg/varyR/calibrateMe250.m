function [error] = calibrateMe250(params)

parameters.nr = 14; % recovery time in days
parameters.lambda23 =1/500; % death rate

parameters.r =0.025; % share reported sick in the long run

parameters.eta = 0.4;% 0.5; % share of healthy that are infectuous
parameters.rhoBar = 2/3; % share of infected in the long run

parameters.alpha_p = params(1); % the effect of p(1) on lambda_12 (alpha_p as alpha is a matlab function)
parameters.beta_p = params(2); % effect of infectuous (p(2) + eta p(4)) on lambda_12 (beta is a matlab function)
parameters.gamma_p = params(3); % 0.1; % effect of rhoBar-rho on lambda_12 (gamma is a matlab function)
parameters.N = 83100; % population size in 1000
parameters.a =params(4); % 1/parameters.N^(parameters.beta_p-parameters.alpha_p)/parameters.N; % activity rate of individuals - we divide by N to descale model


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
tMax = 365; % end of solution period for ODE
opts = odeset('RelTol',1e-6,'AbsTol',1e-8,'Refine',1,'NonNegative',[1 1 1]); %% options for the ode solver
sol = ode45(@(t,p) ODE_syst_9(t,p,parameters), [0 tMax], BCS, opts);

tout = linspace(0,tMax,365+1);
pout = deval(sol,tout);

% pout(pout < 0) = 0; % Dirty fix by Rene: Set negative probabilities to zero
p1 = pout(1,:);
p2 = pout(2,:);
p3 = pout(3,:);
p4 = N - p1 - p2 - p3;
N2ever = pout(4,:)';

% Calculate the persons belonging to each group_i, for i=1,2,3,4
    N_t = [p1;p2;p3;p4]';
    rho = (N_t(:,2)+N_t(:,4))./(N_t(:,1)+N_t(:,2)+N_t(:,4));
    lambda_12=parameters.a*N_t(:,1).^(-parameters.alpha_p).*(N_t(:,2)+parameters.eta.*N_t(:,4)).^parameters.beta_p.*(parameters.rhoBar-rho).^parameters.gamma_p;
    
    N2new = diff(N2ever);

     
% Match data -
     Nsick = [16, 18, 21, 26, 53, 66, 127, 152, 196, 262, 400, 639, 795, 902, 1139, 1296, 1567, 2369, 3062,  3795, 4838, 6012, 7156, 8198, 10999, 13957 ]'; % from Robert Koch Institut LAST IS FROM 20/03/20 
     DeltaNsick = diff(Nsick);
     %error = sum(abs((Nsick-(N2ever(1:length(Nsick)))*1000))) + sum(abs((DeltaNsick-(N2new(1:length(DeltaNsick)))*1000))); % Use 1-Norm 
    error = sum(((Nsick-(N2ever(1:length(Nsick)))*1000)).^2) + sum(((DeltaNsick-N2new(1:length(DeltaNsick)))).^2); % Use 2-Norm 
    % error  = max(abs((Nsick-(N2ever(1:length(Nsick)))*1000*parameters.r))) + max(abs((DeltaNsick-(N2new(1:length(DeltaNsick)))*1000*parameters.r))); % Use Sup-Norm 
% if ~isreal(error)
%    error=Inf; 
% end
end

