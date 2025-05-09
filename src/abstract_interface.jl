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

"""
Refine the given cut to give an approximation with `precision` bits of accuracy.
If the required accuracy cannot be achieved within `max_iter` iterations, return the current estimate
with a warning.
"""
function refine!(::AbstractDedekindReal; precision = DEFAULT_PRECISION, max_iter = 1000) end

function Base.show(io::IO, ::MIME"text/plain", d::AbstractDedekindReal)
    i = refine!(d; precision = 53)
    print(io, "[", BigFloat(low(i), RoundDown; precision = 53),
        ", ", BigFloat(high(i), RoundUp; precision = 53), "]")
end
