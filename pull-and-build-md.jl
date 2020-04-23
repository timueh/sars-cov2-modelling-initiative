using JSON, Dates

include("auxfuns.jl")

repos = JSON.parsefile("subtree-packages.json")
run_all(repos)