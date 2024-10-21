ENV["GKSwstype"] = "100"

const IS_CI = get(ENV, "CI", "false") == "true"

import Pkg
Pkg.activate(@__DIR__)

using Documenter
using DedekindCutArithmetic

###############
# CREATE HTML #
###############

makedocs(;
    modules = [DedekindCutArithmetic], authors = "Luca Ferranti",
    sitename = "DedekindCutArithmetic.jl",
    doctest = false, checkdocs = :exports,
    format = Documenter.HTML(;
        prettyurls = IS_CI, collapselevel = 1,
        canonical = "https://lucaferranti.github.io/DedekindCutArithmetic.jl"),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "Contributing" => ["90-contributing.md", "91-developer.md"]
    ])

##########
# DEPLOY #
##########

IS_CI && deploydocs(;
    repo = "github.com/lucaferranti/DedekindCutArithmetic.jl", push_preview = true)
