"""
This represents a dyadic interval [(m-1)/2^e, (m+1)/2^e] approximating a non-dyadic rational number.

This is a special-case of Dedekind cut representing a rational number for which we do not need iterative refinement
"""
struct RationalCauchyCut <: AbstractCut
    num::BigInt
    den::BigInt
end

RationalCauchyCut(x::Rational) = RationalCauchyCut(numerator(x), denominator(x))
RationalCauchyCut(x::AbstractFloat) = RationalCauchyCut(rationalize(x))

DyadicInterval(d::RationalCauchyCut) = refine!(d)

"""
Evaluate the Cauchy sequence representing a rational number with `n` bits of precision.
"""
function refine!(d::RationalCauchyCut; precision = 53, max_iter = 1000)
    num = (d.num << precision) ÷ d.den
    DyadicInterval(DyadicReal(num - 1, precision), DyadicReal(num + 1, precision))
end

"""
Representation of a real number ``x`` as a dedekind cut.

### Fields

- `low` : function approximating the number from below. Evaluates to true for every number ``< x``.
- `high` : function approximating the number from above. Evaluates to true for every number ``> x``.
- `mpa` : Cached most precise approximation computed so far. This is a dyadic interval bound ``x`` which is updated every time the cut is refined to a higher precision.
"""
mutable struct DedekindCut <: AbstractCut
    const low::FunctionWrapper{Bool, Tuple{AbstractDedekindReal}}
    const high::FunctionWrapper{Bool, Tuple{AbstractDedekindReal}}
    mpa::DyadicInterval
end

DyadicInterval(d::DedekindCut) = d.mpa

function refine!(d::DedekindCut; precision = 53, max_iter = 1000)
    for i in 0:max_iter
        width(d) < DyadicReal(1, precision) && return d.mpa
        a1, b1 = thirds(d.mpa)
        low_pred = d.low(a1)
        high_pred = d.high(b1)
        if !low_pred && !high_pred
            # TODO: do something smarter here
            @warn "cannot refine cut any further, final precision might be lower than desired"
            return d.mpa
        end
        new_low = low_pred ? a1 : d.mpa.lo
        new_hi = high_pred ? b1 : d.mpa.hi
        d.mpa = DyadicInterval(new_low, new_hi)
    end
    @warn "Could not reach desired precision within maximum number of iterations, final result may be less accurate than requested"
    return d.mpa
end

"""
Composite cut lazily representing the result of applying  an arithmetic unary operation `f` to `child`.
"""
struct UnaryCompositeCut{F} <: AbstractCut
    f::F
    child::AbstractCut
end

DyadicInterval(d::UnaryCompositeCut) = d.f(DyadicInterval(d.child))

function refine!(d::UnaryCompositeCut; precision = 53, max_iter = 1000)
    (; f, child) = d
    i = DyadicInterval(child)
    res = f(i)
    for _ in 0:max_iter
        width(res) < DyadicReal(1, precision) && return res
        p = make_prec(precision + 3, i)
        i = refine!(child, precision = p)
        res = f(i)
    end
    @warn "Could not reach desired precision within maximum number of iterations, final result may be less accurate than requested"
    return res
end

"""
Composite cut lazily representing the result of applying  an arithmetic binary operation `f` to `child1` and `child2`.
"""
struct BinaryCompositeCut{F} <: AbstractCut
    f::F
    child1::AbstractDedekindReal
    child2::AbstractDedekindReal
end
function DyadicInterval(d::BinaryCompositeCut)
    d.f(DyadicInterval(d.child1), DyadicInterval(d.child2))
end

function refine!(d::BinaryCompositeCut; precision = 53, max_iter = 1000)
    (; f, child1, child2) = d
    i1, i2 = DyadicInterval(child1), DyadicInterval(child2)
    res = f(i1, i2)
    for i in 0:max_iter
        width(res) < DyadicReal(1, precision) && return res
        p1 = make_prec(precision + 3, i1)
        p2 = make_prec(precision + 3, i2)
        i1 = refine!(child1, precision = p1)
        i2 = refine!(child2, precision = p2)
        res = f(i1, i2)
    end
    @warn "Could not reach desired precision within maximum number of iterations, final result may be less accurate than requested"
    return res
end

#########################
# Arithmetic operations #
#########################

Base.:-(d::AbstractDedekindReal) = UnaryCompositeCut(-, d)

Base.:+(d1::AbstractDedekindReal, d2::AbstractDedekindReal) = BinaryCompositeCut(+, d1, d2)
Base.:-(d1::AbstractDedekindReal, d2::AbstractDedekindReal) = BinaryCompositeCut(-, d1, d2)
Base.:*(d1::AbstractDedekindReal, d2::AbstractDedekindReal) = BinaryCompositeCut(*, d1, d2)

for op in (:<, :>, :<=, :>=)
    @eval function Base.$op(d1::AbstractDedekindReal, d2::AbstractDedekindReal)
        p = 53
        i1, i2 = DyadicInterval(d1), DyadicInterval(d2)
        while overlaps(i1, i2)
            i1 = refine!(d1; precision = p)
            i2 = refine!(d2; precision = p)
            p *= 2
        end
        return $op(i1, i2)
    end
end

function Base.sqrt(a::AbstractDedekindReal)
    fsqrt = isqrt(low(a).m >> low(a).e)
    upsqrt = isqrt((high(a).m >> high(a).e) + 1) + 1
    i = DyadicInterval(fsqrt, upsqrt)
    DedekindCut(x -> x < 0 || x * x < a, x -> x > 0 && x * x > a, i)
end

function Base.:^(x::AbstractCut, p::Integer)
    UnaryCompositeCut(Base.Fix2(^, p), x)
end
