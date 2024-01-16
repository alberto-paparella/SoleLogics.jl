using SoleLogics
using Documenter

DocMeta.setdocmeta!(SoleLogics, :DocTestSetup, :(using SoleLogics); recursive = true)

makedocs(;
    modules = [SoleLogics],
    authors = "Mauro Milella, Giovanni Pagliarini, Eduard I. Stan",
    repo=Documenter.Remotes.GitHub("aclai-lab", "SoleLogics.jl"),
    sitename = "SoleLogics.jl",
    format = Documenter.HTML(;
        size_threshold = 4000000,
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://aclai-lab.github.io/SoleLogics.jl",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Getting started" => "getting-started.md",
        "Introduction to Logics and Propositional Logic" => "base-logic.md",
        "Modal Logic" => "modal-logic.md",
        "Fuzzy" => "fuzzy.md",
        "More on Formulas" => "more-on-formulas.md",
        "Hands On" => "hands-on.md"
    ],
    # NOTE: warning
    warnonly = :true,
)

@info "`makedocs` has finished running. "

deploydocs(;
    repo = "github.com/aclai-lab/SoleLogics.jl",
    target = "build",
    branch = "gh-pages",
    versions = ["main" => "main", "stable" => "v^", "v#.#", "dev" => "dev"],
)
