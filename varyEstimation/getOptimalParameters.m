function [etaOptimal, alphaOptimal, betaOptimal, gammaOptimal,lambda23Optimal,rOptimal,rhoBarOptimal,aOptimal] = getOptimalParameters()

%% parameters g�esses
eta_p=0.4;
alpha_p=0.581534802625034;
beta_p= 0.857407019175532;
gamma_p=0.640571462644926;

% these are fix 
lambda23=1/500;
rhoBar=2/3;

% initial guess for a
a =  2.946865109372464e-05;
r=0.1;

params0 = [alpha_p, beta_p, gamma_p, a];

% Restrictions
A=[];
b=[];
Aeq=[];
beq=[];
lb=[0 0 0 0];
ub=[1 1 1 1];

options = optimset('Display','off');%,'MaxFunEvals',100000,'MaxIter',10000, 'TolX',1e-3,'TolFun',1e-4);%,'TypicalX',10*[1e-2,1e-3,1e-1,1e-2,1e-1,1,1,1e-1,1e-2,1]);

format long
[params,fval,exitflag] = fmincon(@calibrateMe,params0,A,b,Aeq,beq,lb,ub,[],options);
% rng default % For reproducibility
% gs = GlobalSearch;
% problem = createOptimProblem('fmincon','x0',params0,...
%     'objective',@calibrateMe,'lb',lb,'ub',ub);
% params = run(gs,problem);


% for i=1:3
%    [params,fval,exitflag] = fmincon(@calibrateMe,params,A,b,Aeq,beq,lb,ub,[],options);
% end


alphaOptimal=params(1);
betaOptimal=params(2);
gammaOptimal=params(3);
etaOptimal=eta_p;
lambda23Optimal=lambda23;
rOptimal=r;
rhoBarOptimal=rhoBar;
aOptimal= params(4);
end

