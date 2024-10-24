"""
Represents a dyadic number in the form ``\\frac{m}{2^{-e}}``, with ``d ∈ ℤ`` and ``e ∈ ℕ``.
"""
struct DyadicReal <: AbstractDyadic
    m::BigInt
    e::Int64
end

get_mantissa(d::DyadicReal) = d.m
get_exp(d::DyadicReal) = -d.e

function Base.show(io::IO, ::MIME"text/plain", d::DyadicReal)
    print(io, float(d))
end

###############
# Conversions #
###############

DyadicReal(n::Integer) = DyadicReal(BigInt(n), 0)
function Base.BigFloat(d::DyadicReal, mode::RoundingMode = RoundNearest; precision = 256)
    BigFloat(d.m // (big(1) << d.e), mode; precision)
end
function (::Type{T})(
        d::DyadicReal, mode::RoundingMode = RoundNearest) where {T <: AbstractFloat}
    T(d.m // (big(1) << d.e), mode)
end

Rational(d::DyadicReal) = d.m // (big(1) << d.e)

############
# Rounding #
############

Base.round(d::DyadicReal, ::RoundingMode{:Down}) = DyadicReal(d.m >> d.e, 0)
Base.round(d::DyadicReal, ::RoundingMode{:Up}) = DyadicReal(((d.m - 1) >> d.e) + 1, 0)
function Base.round(d::DyadicReal, ::RoundingMode{:Nearest})
    DyadicReal((d.m + big(1) << (d.e - 1)) >> d.e, 0)
end

Base.round(::Type{BigInt}, d::DyadicReal) = get_mantissa(round(d, RoundNearest))
Base.floor(::Type{BigInt}, d::DyadicReal) = get_mantissa(round(d, RoundDown))
Base.ceil(::Type{BigInt}, d::DyadicReal) = get_mantissa(round(d, RoundUp))

#################
# Cut interface #
#################

width(c::DyadicReal) = zero(c)
midpoint(c::DyadicReal) = c
radius(c::DyadicReal) = zero(c)
low(c::DyadicReal) = c
high(c::DyadicReal) = c

refine!(x::DyadicReal; kwargs...) = DyadicInterval(x)

##########################
# Arithmetic operations  #
##########################

function Base.:+(d1::DyadicReal, d2::DyadicReal)
    m1, e1, m2, e2 = if d1.e <= d2.e
        d1.m, d1.e, d2.m, d2.e
    else
        d2.m, d2.e, d1.m, d1.e
    end
    DyadicReal(m1 << (e2 - e1) + m2, e2)
end

Base.:-(d::DyadicReal) = DyadicReal(-d.m, d.e)

function Base.:-(d1::DyadicReal, d2::DyadicReal)
    m1, e1, m2, e2 = if d1.e <= d2.e
        d1.m, d1.e, -d2.m, d2.e
    else
        -d2.m, d2.e, d1.m, d1.e
    end
    DyadicReal(m1 << (e2 - e1) + m2, e2)
end

function Base.:*(d1::DyadicReal, d2::DyadicReal)
    DyadicReal(d1.m * d2.m, d1.e + d2.e)
end

Base.:>>(d::DyadicReal, n::Int64) = DyadicReal(d.m, d.e + n)

function Base.:<<(d::DyadicReal, n::Int64)
    return n >= d.e ? DyadicReal(d.m << (n - d.e), 0) : DyadicReal(d.m, d.e - n)
end

Base.abs(d::DyadicReal) = DyadicReal(abs(d.m), d.e)

Base.:(==)(d1::DyadicReal, d2::DyadicReal) = (d1.m << d2.e) == (d2.m << d1.e)

for op in (:<, :>, :<=, :>=)
    @eval function Base.$op(d1::DyadicReal, d2::DyadicReal)
        $op((d1.m << d2.e), (d2.m << d1.e))
    end
end
