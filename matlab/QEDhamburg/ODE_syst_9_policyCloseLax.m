function dp = ODE_syst_9_policyCloseLax(t,p,parameters)

% parameters
    nr = parameters.nr; % recovery time in days
    lambda23 = parameters.lambda23; % death rate

    r = parameters.r; % share reported sick in the long run

    eta = parameters.eta;% 0.5; % share of healthy that are infectuous
    rhoBar = parameters.rhoBar; % share of infected in the long run

    alpha_p = parameters.alpha_p; % the effect of p(1) on lambda_12 (alpha_p as alpha is a matlab function)
    beta_p = parameters.beta_p; % effect of infectuous (p(2) + eta p(4)) on lambda_12 (beta is a matlab function)
    gamma_p = parameters.gamma_p; % 0.1; % effect of rhoBar-rho on lambda_12 (gamma is a matlab function)
    N = parameters.N; % population size in 1000

    a = parameters.a*0.8; % TAKE HALF VALUE WHEN SHUT DOWN

% probabilities and infection rate    
    p(4) = N- p(1)-p(2)-p(3);
    p(p<0)=0; % restrict prob. to be positive

    rho = (p(2)+p(4))/(p(1)+p(2)+ p(4)); % infection rate

% sickness rate
    lambda_12 = a*(p(1))^(-alpha_p) * (p(2)+eta*p(4))^beta_p * N^(beta_p-alpha_p) * (rhoBar - rho)^gamma_p;

if rho>rhoBar
    rho = rhoBar;
    lambda_12 = 0;
end

dp = [-lambda_12/r * p(1);... %end of eq 1
      lambda_12   * p(1) - (lambda23 + 1/nr) * p(2);... %end of eq 2
      lambda23    * p(2);
      lambda_12 * p(1)]; % end of eq 3

end