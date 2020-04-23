using JSON
repos = JSON.parsefile("auxfiles/subtree-packages.json")

for (name, data) in repos
    dir, url = data["language"] * "/" * name, data["url"]
    cmd, msg = 
    if isdir(dir)
        `git subtree pull --prefix=$dir $url master --squash`, "Pulling $dir\n"
    else
        mkdir(dir)
        `git subtree add --prefix=$dir $url master --squash`, "Adding $dir\n"
    end
    printstyled(msg, color=:green)
    result = run(cmd)
    @assert(result.exitcode == 0, "Something went wrong pulling repo $dir from $url")
end