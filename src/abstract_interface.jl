#######################################
# Abstract types and fallback methods #
#######################################

"""
Abstract type representing a generic real number.
"""
abstract type AbstractDedekindReal <: Real end

"""
Represents a dyadic number or a dyadic interval.
"""
abstract type AbstractDyadic <: AbstractDedekindReal end

"""
Abstract type for a generic cut.
"""
abstract type AbstractCut <: AbstractDedekindReal end

Base.isfinite(::AbstractDedekindReal) = true
Base.isnan(::AbstractDedekindReal) = false

"Width of the current precise appoximation of t mosthe cut"
width(c::AbstractDedekindReal) = width(DyadicInterval(c))

"Midpoint of the current most precise approximation of the cut"
midpoint(c::AbstractDedekindReal) = midpoint(DyadicInterval(c))

"Width of the current precise appoximation of t mosthe cut"
radius(c::AbstractDedekindReal) = radius(DyadicInterval(c))

"Lower bound of the real number approximated by the cut"
low(c::AbstractDedekindReal) = low(DyadicInterval(c))

"Lower bound of the real number approximated by the cut"
high(c::AbstractDedekindReal) = high(DyadicInterval(c))

"Whether or not two cuts are overlapping in the current precision"
function overlaps(c1::AbstractDedekindReal, c2::AbstractDedekindReal)
    overlaps(DyadicInterval(c1), DyadicInterval(c2))
end

"""
Refine the given cut to give an approximation with `precision` bits of accuracy.
If the required accuracy cannot be achieved within `max_iter` iterations, return the current estimate
with a warning.
"""
function refine!(::AbstractDedekindReal; precision = 53, max_iter = 1000) end

function Base.show(io::IO, ::MIME"text/plain", d::AbstractDedekindReal)
    i = refine!(d; precision = 53)
    print(io, "[", BigFloat(low(i), RoundDown; precision = 53),
        ", ", BigFloat(high(i), RoundUp; precision = 53), "]")
end
