# DedekindCutArithmetic.jl

[![license: MIT][license-img]][license-url]
[![Stable Documentation][stabledoc-img]][stabledoc-url]
[![In development documentation][devdoc-img]][devdoc-url]
[![Build Status][ci-img]][ci-url]
[![Coverage][cov-img]][cov-url]
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages][colprac-img]][colprac-url]
[![SciML Code Style][style-img]][style-url]

A Julia library for exact real arithmetic using [Dedekind cuts](https://en.wikipedia.org/wiki/Dedekind_cut) and [Abstract Stone Duality](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=02c685856371aac16ce81bf7467ffc4d533d48ff). Heavily inspired by the [Marshall](https://github.com/andrejbauer/marshall) programming language.

## Installation

1. If you haven't already, install Julia. The easiest way is to install [Juliaup](https://github.com/JuliaLang/juliaup#installation). This allows to easily install and manage julia versions.

2. Open the terminal and start a julia session by typing `julia`.

3. Install the library by typing

    ```julia
    using Pkg; Pkg.add("DedekindCutArithmetic")
    ```

4. The package can now be loaded (in the interactive REPL or in a script file) with the command

    ```julia
    using DedekindCutArithmetic
    ```

5. That's it, have fun!

## Quickstart example

The following snippet shows how to define the squareroot of a number and the maximum of a function $f: [0, 1] \rightarrow \mathbb{R}$ using Dedekind cuts. It also shows this definition is actually computable and can be used to give a tight rigorous bound of the value.

```julia
using DedekindCutArithmetic

# Textbook example of dedekind cuts, define square-root
my_sqrt(a) = @cut x ∈ ℝ, (x < 0) ∨ (x * x < a), (x > 0) ∧ (x * x > a)

# lazy computation, however it is automatically evaluated to 53 bits of precision if printed in the REPL.
sqrt2 = my_sqrt(2);

# evaluate to 80 bits precision, this gives an interval with width <2⁻⁸⁰ containing √2
refine!(sqrt2; precision=80)
# [1.4142135623730949, 1.4142135623730951]

# Define maximum of a function f: [0, 1] → ℝ as a Dedekind cut
my_max(f::Function) = @cut a ∈ ℝ, ∃(x ∈ [0, 1] : f(x) > a), ∀(x ∈ [0, 1] : f(x) < a)

f = x -> x * (1 - x)

fmax = my_max(f);

refine!(fmax) # evaluate to 53 bits of precision by default
# [0.24999999999999992, 0.25000000000000006]
```

## Documentation

- [**STABLE**][stabledoc-url]: Documentation of the latest release
- [**DEV**][devdoc-url]: Documentation of the in-development version on main

## Contributing

Contributions are welcome! Here is a small decision tree with useful links. More details in the [contributor's guide](https://lucaferranti.github.io/DedekindCutArithmetic.jl/dev/90-contributing).

- There is a [discussion section](https://github.com/lucaferranti/DedekindCutArithmetic.jl/discussions) on GitHub. You can use the [helpdesk](https://github.com/lucaferranti/DedekindCutArithmetic.jl/discussions/categories/helpdesk) category to ask for help on how to use the software or the [show and tell](https://github.com/lucaferranti/DedekindCutArithmetic.jl/discussions/categories/show-and-tell) category to simply share with the world your work using DedekindCutArithmetic.jl

- If you find a bug or want to suggest a new feature, [open an issue](https://github.com/lucaferranti/DedekindCutArithmetic.jl/issues).

- You are also encouraged to send pull requests (PRs). For small changes, it is ok to open a PR directly. For bigger changes, it is advisable to discuss it in an issue first. Before opening a PR, make sure to check the [contributor's guide](https://lucaferranti.github.io/DedekindCutArithmetic.jl/dev/90-contributing).

## Copyright

- Copyright (c) 2024 [Luca Ferranti](https://github.com/lucaferranti), released under MIT license

[license-img]: https://img.shields.io/badge/license-MIT-yellow.svg
[license-url]: https://github.com/lucaferranti/DedekindCutArithmetic.jl/blob/main/LICENSE

[stabledoc-img]: https://img.shields.io/badge/docs-stable-blue.svg
[stabledoc-url]: https://lucaferranti.github.io/DedekindCutArithmetic.jl/stable/

[devdoc-img]: https://img.shields.io/badge/docs-dev-blue.svg
[devdoc-url]: https://lucaferranti.github.io/DedekindCutArithmetic.jl/dev/

[ci-img]: https://github.com/lucaferranti/DedekindCutArithmetic.jl/actions/workflows/Test.yml/badge.svg?branch=main
[ci-url]: https://github.com/lucaferranti/DedekindCutArithmetic.jl/actions/workflows/Test.yml?query=branch%3Amain

[cov-img]: https://codecov.io/gh/lucaferranti/DedekindCutArithmetic.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/lucaferranti/DedekindCutArithmetic.jl

[colprac-img]: https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet
[colprac-url]: https://github.com/SciML/ColPrac

[style-img]: https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826
[style-url]: https://github.com/SciML/SciMLStyle
