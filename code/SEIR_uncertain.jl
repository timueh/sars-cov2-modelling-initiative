using DifferentialEquations, SparseArrays, PolyChaos, BenchmarkTools, PyPlot, LaTeXStrings
include("SEIR_uncertain_setup.jl")
## deterministic setup
N, E_0, I_0, R_0 = 80000000, 40000., 10000., 0.
S_0 = N - E_0 - I_0 - R_0
lag_0, IN_0 = 10, 0
x0 = [S_0, E_0, I_0, R_0, lag_0, IN_0]
tspan = (0., 365)
## probabilistic setup
degree, Nrec = 5, 20
op1, op2 = GaussOrthoPoly(degree; Nrec=Nrec), Uniform01OrthoPoly(degree; Nrec=Nrec)
mop = MultiOrthoPoly([op1, op2], degree)
T2, T3, T4 = [ Tensor(i, mop) for i in 2:4 ]
x0_pce = build_initial_condition(x0, dim(mop))

R0_pce = assign2multi(convert2affinePCE(1.5, 0.1, op1), 1, mop.ind)
percentage_pce = assign2multi(convert2affinePCE(0.02, 0.06, op2), 2, mop.ind)

seir_pars, int_care_pars = SEIR(R0_pce, 5.5, 3.), Intensive_care(percentage_pce, 20., 10.)
## solve Galerkin-projected ODE
problem = ODEProblem(seir_model!, x0_pce, tspan, [seir_pars, int_care_pars, mop, T2, T3, T4])
sol = solve(problem, save_at = 0.5)
## post-processing
inds = build_indices(length(x0), dim(mop))
mean_inds = [ ind[1] for ind in inds ]

mean_sols = vcat([ u[mean_inds] for u in sol.u ]'...)
std_sols = vcat([ [std(u[ind], mop) for ind in inds] for u in sol.u ]'...)

plot_results(sol.t, mean_sols, std_sols, save=true)
