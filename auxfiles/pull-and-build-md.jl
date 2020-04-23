include("auxfuns.jl")

repos = JSON.parsefile("auxfiles/subtree-packages.json")
run_all(repos)