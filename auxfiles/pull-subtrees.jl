include("auxfuns.jl")

repos = JSON.parsefile("auxfiles/subtree-packages.json")
pull_subtrees(repos)