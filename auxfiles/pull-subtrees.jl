using JSON
repos = JSON.parsefile("auxfiles/subtree-packages.json")

for (name, data) in repos
    dir, url = data["language"] * "/" * name, data["url"]
    display((dir, url))
    cmd = 
    if isdir(dir)
        `git subtree pull --prefix=$dir $url master --squash`
    else
        mkdir(dir)
        `git subtree add --prefix=$dir $url master --squash`
    end
    printstyled("Pulling $dir\n", color=:green)
    result = run(cmd)
    @assert(result.exitcode == 0, "Something went wrong pulling repo $dir from $url")
end