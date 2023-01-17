using SaguaroTrader
using Documenter

DocMeta.setdocmeta!(SaguaroTrader, :DocTestSetup, :(using SaguaroTrader); recursive = true)

makedocs(;
    modules = [SaguaroTrader],
    authors = "Saguaro Capital Management",
    repo = "https://github.com/SaguaroCapital/SaguaroTrader.jl.git",
    sitename = "SaguaroTrader.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://SaguaroCapital.github.io/SaguaroTrader.jl",
        assets = String[],
    ),
    pages = ["Home" => "index.md", "API" => "api.md", "Examples" => "examples.md"],
)

deploydocs(; repo = "github.com/SaguaroCapital/SaguaroTrader.jl.git")
