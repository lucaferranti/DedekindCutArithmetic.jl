"""
Represents an interval with lower and uppper bound expressed as dyadic numbers.
Note this is a generalized interval, that is, the lower bound can be greater than the upper bound.
"""
struct DyadicInterval <: AbstractDyadic
    lo::DyadicReal
    hi::DyadicReal
end

DyadicInterval(n1::Integer, n2::Integer) = DyadicInterval(DyadicReal(n1), DyadicReal(n2))
function DyadicInterval(n::Integer)
    x = DyadicReal(n)
    DyadicInterval(x, x)
end
DyadicInterval(d::DyadicReal) = DyadicInterval(d, d)

"Returns true if the lower bound is smaller or equal of the upper bound."
isforward(d::DyadicInterval) = d.lo <= d.hi

"Returns true if the lower bound is strictly bigger than the upper bound."
isbackward(d::DyadicInterval) = d.hi < d.lo

"Given the interval ``[a, b]``, return its dual ``[b, a]``."
dual(d::DyadicInterval) = DyadicInterval(d.hi, d.lo)

Base.in(x::Number, i::DyadicInterval) = min(i.lo, i.hi) <= x <= max(i.lo, i.hi)

"Whether or not the given dyadic intervals overlap."
overlaps(i1::DyadicInterval, i2::DyadicInterval) = max(i1.lo, i2.lo) <= min(i1.hi, i2.hi)

"Left endpoint of the dyadic interval."
low(i::DyadicInterval) = i.lo

"Right endpoint of the dyadic interval."
high(i::DyadicInterval) = i.hi

"""
  Width of the dyadic interval.

Note this is always positive, also for improper intervals.
"""
width(i::DyadicInterval) = abs(i.hi - i.lo)

"Half the width of the given interval."
radius(i::DyadicInterval) = width(i) >> 1

"Midpoint of the dyadic interval"
midpoint(i::DyadicInterval) = (i.lo + i.hi) >> 1

refine!(i::DyadicInterval; precision = DEFAULT_PRECISION, max_iter = 1000) = i

"Split the interval in two halves."
function Base.split(i::DyadicInterval)
    m = midpoint(i)
    DyadicInterval(i.lo, m), DyadicInterval(m, i.hi)
end

"""
Return two points that divide the interval in three parts with ratio 1/4, 1/2, 1/2
"""
function thirds(i::DyadicInterval)
    i1, i2 = split(i)
    midpoint(i1), midpoint(i2)
end

function Base.show(io::IO, ::MIME"text/plain", d::DyadicInterval)
    print(io, "[", BigFloat(low(d), RoundDown; precision = 53),
        ", ", BigFloat(high(d), RoundUp; precision = 53), "]")
end

Base.:+(d::DyadicInterval; precision = DEFAULT_PRECISION) = d
Base.:-(d::DyadicInterval; precision = DEFAULT_PRECISION) = DyadicInterval(-d.hi, -d.lo)

function Base.:+(d1::AbstractDyadic, d2::AbstractDyadic; precision = DEFAULT_PRECISION)
    DyadicInterval(low(d1) + low(d2), high(d1) + high(d2))
end
function Base.:-(d1::AbstractDyadic, d2::AbstractDyadic; precision = DEFAULT_PRECISION)
    DyadicInterval(low(d1) - high(d2), high(d1) - low(d2))
end

function Base.:*(d1::DyadicInterval, d2::DyadicInterval; precision = DEFAULT_PRECISION)
    a, b = low(d1), high(d1)
    c, d = low(d2), high(d2)
    if a <= 0 && b <= 0
        if 0 <= c && 0 <= d
            DyadicInterval(a * d, b * c)
        elseif d <= 0 <= c
            DyadicInterval(b * d, b * c)
        elseif c <= 0 <= d
            DyadicInterval(a * d, a * c)
        else # c, d ≤ 0
            DyadicInterval(b * d, a * c)
        end
    elseif a <= 0 <= b
        if 0 <= c && 0 <= d
            DyadicInterval(a * d, b * d)
        elseif d <= 0 <= c
            zero(DyadicInterval)
        elseif c <= 0 <= d
            DyadicInterval(min(a * d, b * c), max(a * c, b * d))
        else # c, d ≤ 0
            DyadicInterval(b * c, a * c)
        end
    elseif b <= 0 <= a
        if 0 <= c && 0 <= d
            DyadicInterval(a * c, b * c)
        elseif d <= 0 <= c
            DyadicInterval(max(a * c, b * d), min(a * d, b * c))
        elseif c <= 0 <= d
            zero(DyadicInterval)
        else # c, d ≤ 0
            DyadicInterval(b * d, a * d)
        end
    else # 0 ≤ a, b
        if 0 <= c && 0 <= d
            DyadicInterval(a * c, b * d)
        elseif d <= 0 <= c
            DyadicInterval(a * c, a * d)
        elseif c <= 0 <= d
            DyadicInterval(b * c, b * d)
        else # c, d ≤ 0
            DyadicInterval(b * c, a * d)
        end
    end
end

function Base.:^(i::DyadicInterval, p::Int64; precision = 53)
    p < 0 && throw(ArgumentError("Negative exponents not supported yet"))
    lo, hi = low(i), high(i)
    isodd(p) && return DyadicInterval(lo^p, hi^p)
    lop, hip = if lo >= 0
        hi >= 0 ? (lo^p, hi^p) : (max(hi^p, lo^p), zero(DyadicReal))
    else
        hi >= 0 ? (zero(DyadicReal), max(hi^p, lo^p)) : (hi^p, lo^p)
    end
    DyadicInterval(lop, hip)
end

function Base.inv(i::DyadicInterval; precision = DEFAULT_PRECISION)
    0 ∈ i && throw(DomainError(i, "Interval contains 0"))
    lo, hi = low(i), high(i)
    DyadicInterval(_inv(hi, RoundDown; precision), _inv(lo, RoundUp; precision))
end

function Base.:/(i1::DyadicInterval, i2::DyadicInterval; precision = DEFAULT_PRECISION)
    # TODO: could maybe be faster?
    i1 * inv(i2; precision)
end

###############
# Comparisons #
###############

function Base.:(==)(i1::DyadicInterval, i2::DyadicInterval)
    return low(i1) == low(i2) && high(i1) == high(i2)
end

Base.:<(i1::AbstractDyadic, i2::AbstractDyadic) = high(i1) < low(i2)
Base.:<=(i1::AbstractDyadic, i2::AbstractDyadic) = high(i1) <= low(i2)

Base.:>(i1::AbstractDyadic, i2::AbstractDyadic) = low(i1) > high(i2)
Base.:>=(i1::AbstractDyadic, i2::AbstractDyadic) = low(i1) >= high(i2)

#########
# Utils #
#########

"""
Given precision `p` and interval `i`, compute a precision which is better than `p` and
is suitable for working with intervals of width `i`.

Taken from: https://github.com/andrejbauer/marshall/blob/c9f1f6466e879e8db11a12b9bc030e62b07d8bd2/src/eval.ml#L22-L26
"""
function make_prec(p::Int64, i::DyadicInterval)
    w = width(i)
    e1 = get_exp(w)
    e2 = max(get_exp(low(i)), get_exp(high(i)))
    max(2, p, (-5 * (e1 - e2)) >> 2)
end
