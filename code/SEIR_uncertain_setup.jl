_throw_error_message() = throw(error("Only positive parameter values allowed."))

abstract type Parameters{T} end

mutable struct SEIR{T, V<:AbstractVector{T}} <: Parameters{T}
    R0::V
    t_latent::T
    t_infectious::T
end

mutable struct Intensive_care{T, V<:AbstractVector{T}} <: Parameters{T}
    percentage::V
    t_lay::T
    t_lag::T
end

function seir_model!(dx, x, pars, t)
    seir, int_care, mop, T2, T3, T4 = pars
    L = dim(mop)
    inds = build_indices(length(x) ÷ L, L)

    inds_S = Iterators.product(findnz(seir.R0)[1], 1:L, 1:L)
    inds_LAG = Iterators.product(findnz(int_care.percentage)[1], 1:L)

    S, E, I, R, LAG, IN = [ x[ind] for ind in inds ]

    dx[inds[1]] = dS = [ - 1 / (N * seir.t_infectious) * sum(seir.R0[ind[1]] * S[ind[2]] * I[ind[3]] * T4.get([ind[1]-1, ind[2]-1, ind[3]-1, k-1]) / T2.get([k-1, k-1]) for ind in inds_S ) for k in 1:L]
    dx[inds[2]] = dE = -dx[inds[1]] - 1 / seir.t_latent * E
    dx[inds[3]] = dI = 1 / seir.t_latent * E - 1 / seir.t_infectious * I
    dx[inds[4]] = dR = 1 / seir.t_infectious * I
    dx[inds[5]] = dLAG = 1 / seir.t_latent * [ sum(int_care.percentage[ind[1]] * E[ind[2]] * T3.get([ind[1]-1, ind[2]-1, k-1]) / T2.get([k-1, k-1]) for ind in inds_LAG) for k in 1:L ] - 1 / int_care.t_lag * LAG
    dx[inds[6]] = dIN = 1 / int_care.t_lag * LAG - 1 / int_care.t_lay * IN
end

function build_initial_condition(x0, L)
    e = zeros(L-1)
    pushfirst!(e, 1)
    kron(x0, e)
end

function build_indices(N::Int, L::Int)
    inds = [Vector(1:L)]
    # for i = 2:N
    [ push!(inds, inds[i-1] .+ L) for i = 2:N ]
    # end
    inds
end

function plot_results(t, mean, std; fontsize=8, labelsize=8, fontdict = Dict("color"=>"black","size"=>fontsize,"family"=>"serif"), figsize = (14.0/2.54, 5.0/2.54), save::Bool=false)
    xlab = latexstring("t")
    ylab = latexstring.(["S(t)", "E(t)", "I(t)", "R(t)", "Lag(t)", "IN(t)"])

    for i = 1:6
        figure(num=i, figsize=figsize)
        grid("on")
        fill_between(t, mean[:, i] - std[:, i], mean[:, i] + std[:, i], alpha=0.3)
        plot(sol.t, mean[:, i])

        xlabel(xlab, fontdict=fontdict)
        ylabel(ylab[i], fontdict=fontdict)
        axis("tight")
        tight_layout()
        ax=gca()
        setp(ax[:get_yticklabels](),size=labelsize)
        setp(ax[:get_xticklabels](),size=labelsize)
        if save
            savefig("seir-icu-$i.pgf")
        end
    end
end