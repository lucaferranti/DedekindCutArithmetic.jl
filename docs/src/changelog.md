```@meta
EditURL = "https://github.com/lucaferranti/DedekindCutArithmetic.jl/blob/main/CHANGELOG.md"
```

```@meta
EditURL = "https://github.com/lucaferranti/DedekindCutArithmetic.jl/blob/main/CHANGELOG.md"
```

# Release Notes

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.1](https://github.com/lucaferranti/DedekindCutArithmetic.jl/releases/tag/v0.1.1) -- 2025-04-13

### Added

- Support `Base.one` and `Base.zero` for cuts ([#5](https://github.com/lucaferranti/DedekindCutArithmetic.jl/issues/5))
- Support `^` operation with non-negative integer exponent ([#4](https://github.com/lucaferranti/DedekindCutArithmetic.jl/issues/4))
- Support `inv` and division ([#9](https://github.com/lucaferranti/DedekindCutArithmetic.jl/issues/9))
- Add `@exact_str` string macro to correctly parse float literals ([#12](https://github.com/lucaferranti/DedekindCutArithmetic.jl/issues/12))
- Add non-unicode `@forall` and `@exists` aliases ([#12](https://github.com/lucaferranti/DedekindCutArithmetic.jl/issues/12))

## [v0.1.0](https://github.com/lucaferranti/DedekindCutArithmetic.jl/releases/tag/v0.1.0) -- 2024-10-25

Initial release

### Added

- Define basic data structures (`DyadicReal, DyadicInterval, RationalCauchyCut, DedekindCut, UnaryCompositeCut, BinaryCompositeCut`)
- defined addition, subraction and multiplication
- support quantifiers over simple inequality statements
