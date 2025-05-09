"""
Check whether ``∃ x ∈ dom : f(x) < 0``
"""
function exists(dom::DyadicInterval, f::Function)::Bool
    f(DyadicInterval(midpoint(dom))) < 0 && return true

    # try to avoid bisection by checking for monotonicity
    d = ForwardDiff.derivative(f, dom)
    low(d) > 0 && f(low(dom)) >= 0 && return false
    high(d) < 0 && f(high(dom)) >= 0 && return false

    high(f(dual(dom))) >= 0 && return false

    i1, i2 = split(dom)
    exists(i1, f) || exists(i2, f)
end

"""
Check whether ``∀ x ∈ dom : f(x) < 0``
"""
function forall(dom::DyadicInterval, f::Function)::Bool
    f(DyadicInterval(midpoint(dom))) >= 0 && return false

    # try to avoid bisection by checking for monotonicity
    d = ForwardDiff.derivative(f, dom)
    low(d) > 0 && f(high(dom)) < 0 && return true
    high(d) < 0 && f(low(dom)) < 0 && return true

    high(f(dom)) < 0 && return true

    i1, i2 = split(dom)
    forall(i1, f) && forall(i2, f)
end
