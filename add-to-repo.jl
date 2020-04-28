using ArgParse, JSON

include("auxfuns.jl")

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "name"
            help = "Name of the directory"
            required = true
            arg_type = String
        "language"
            help = "programming language"
            arg_type = String
            required = true
        "url"
            help = "url of repo"
            required = true
            arg_type = String
        "contact"
            help = "contact information"
            required = true
            arg_type = String
        "json-file"
            help = "json file that stores repo information (only change if you know what you're doing)"
            required = false
            arg_type = String
            default = "subtree-packages.json"
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("$arg  =>  $val")
    end

    repo = Dict(json_keys["lang"] => parsed_args["language"],
                json_keys["url"] => parsed_args["url"],
                json_keys["contact"] => parsed_args["contact"])

    #TODO: check uniqueness of passed arguments
    repo_name, json_file = parsed_args["name"], parsed_args["json-file"]
    repos = JSON.parsefile(json_file)
    repos[repo_name] =  repo

    run(`git checkout -b $repo_name`)

    open(json_file, "w") do io
        JSON.print(io, repos, 4)
    end
    run(`git commit $json_file -m "added $repo_name to json"`)

    pull_subtrees(repos)
    run_all(repos)
    run(`git commit list-of-packages.md -m "added $repo_name to md"`)
    run(`git checkout master`)
    # - `git merge --squash $name-of-repo`
end

main()