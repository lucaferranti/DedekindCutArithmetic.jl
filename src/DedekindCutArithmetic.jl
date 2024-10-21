"""
  DedelomdCutArithmetic

Julia library implementing exact real arithmetic using Dedekind cuts and abstract stone duality.
"""
module DedekindCutArithmetic

using MacroTools
using FunctionWrappers: FunctionWrapper
using ForwardDiff

export DyadicReal, DyadicInterval, DedekindCut, RationalCauchyCut, BinaryCompositeCut, @cut,
       refine!, dual,
       width, midpoint, radius, thirds, low,
       exists, forall, @∀, @∃

include("abstract_interface.jl")
include("dyadic.jl")
include("interval.jl")
include("cuts.jl")
include("promotions.jl")
include("quantifiers.jl")
include("macros.jl")

end
