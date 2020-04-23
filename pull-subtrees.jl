using JSON

include("auxfuns.jl")

repos = JSON.parsefile("subtree-packages.json")
pull_subtrees(repos)