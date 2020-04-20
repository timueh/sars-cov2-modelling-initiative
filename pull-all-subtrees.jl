timueh_seir = Dict("git-subtree-dir"=> "julia/SEIR-with-uncertainties", "git-subtree-split"=> "8a5cdeaa616f675514ae2394544de0f25bbd0d83", "url"=> "https://github.com/timueh/PandemicModeling")

qed_hamburg = Dict("git-subtree-dir"=> "matlab/QEDhamburg", "git-subtree-split"=> "f539f28df31dfa2f810de7a50a331b38b60d0ebf", "url"=> "https://github.com/QEDHamburg/covid19")

mitepid_sim = Dict("git-subtree-dir"=> "python/MiTepid_sim", "git-subtree-split"=> "c5e90bb33b0d90f1ad1ef358fec19147bee05b7a", "url"=> "https://github.com/vahid-sb/MiTepid_sim.git")

repos = [timueh_seir, qed_hamburg, mitepid_sim]

for repo in repos
    dir, url = repo["git-subtree-dir"], repo["url"]
    cmd = `git subtree pull --prefix=$dir $url master --squash`

    printstyled("Pulling $dir\n", color=:green)
    result = run(cmd)
    @assert(result.exitcode == 0, "Something went wrong pulling repo $dir from $url")
end