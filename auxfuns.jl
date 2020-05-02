using JSON, Dates

json_keys = Dict("lang" => "language",
                 "url" => "url",
                 "contact" => "contact",
                 "name" => "name",
                 "branch" => "branch")


function pull_subtrees(repos::Dict)
    for (name, data) in repos
        dir, url, branch = data[json_keys["lang"]] * "/" * name, data[json_keys["url"]], data[json_keys["branch"]]
        cmd, msg = 
        if isdir(dir)
            `git subtree pull --prefix=$dir $url $branch --squash`, "Pulling $dir\n"
        else
            `git subtree add --prefix=$dir $url $branch --squash`, "Adding $dir\n"
        end
        printstyled(msg, color=:green)
        result = run(cmd)
        @assert(result.exitcode == 0, "Something went wrong pulling repo $dir from $url")
    end
    true
end

function unpack(d::Dict)
    d[json_keys["name"]], d[json_keys["url"]], d[json_keys["contact"]]
end

function create_language_dictionary(repos::Dict)
    langs = [ data[json_keys["lang"]] for data in values(repos)]
    d = Dict{String, Vector{Dict}}()
    for data in values(repos)
        d[data[json_keys["lang"]]] = Vector{Dict}()
    end
    d
end

function fill_language_dictionary!(d::Dict, repos::Dict)
    for (name, data) in repos
        language = data[json_keys["lang"]]
        temp = Dict(json_keys["name"] => name,
                    json_keys["url"] => data["url"],
                    json_keys["contact"] => data["contact"])
        push!(d[language], temp)
    end
end

function create_md_file(name::String)
    if isfile(name)
        rm(name)
    end

    open(name, "w") do io
        write(io, "# Included packages\n\n")
        write(io, "The following packages---ordered by language---are included in the repository (last updated $(today())).\n\n")
    end
end

function append_md_file(name::String, lang::String, data)
    mode = isfile(name) ? "a" : "w"
    open(name, mode) do io
        write(io, "## " * uppercasefirst(lang) * "\n")
        write(io, "| Package | Contact |\n")
        write(io, "| --- | --- |\n")

        for d in data
            name, url, contact = unpack(d)
            write(io, "| [$name]($url) | $contact |\n")
        end
        write(io, "\n")
    end
end

function build_md_file(repos)
    langs = create_language_dictionary(repos)
    fill_language_dictionary!(langs, repos)
    file = "list-of-packages.md"
    create_md_file(file)

    for (lang, data) in langs
        append_md_file(file, lang, data)
    end
end

function run_all(repos)
    if pull_subtrees(repos)
        build_md_file(repos)
    end
end

repos = JSON.parsefile("subtree-packages.json")











