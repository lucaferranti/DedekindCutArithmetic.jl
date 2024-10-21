abstract type AbstractQuantifier end

"""
Check whether ``∃ x ∈ dom : prop(x)``
"""
function exists(dom::DyadicInterval, prop::Function)::Bool
    high(prop(midpoint(dom))) < 0 && return true

    # try to avoid bisection by checking for monotonicity
    d = ForwardDiff.derivative(prop, dom)
    low(d) > 0 && high(prop(high(dom))) >= 0 && return false
    high(d) < 0 && high(prop(low(dom))) >= 0 && return false

    low(prop(dual(dom))) >= 0 && return false

    i1, i2 = split(dom)
    exists(i1, prop) || exists(i2, prop)
end

"""
Check whether ``∀ x ∈ dom : prop(x)``
"""
function forall(dom::DyadicInterval, prop::Function)::Bool
    low(prop(midpoint(dom))) >= 0 && return false

    # try to avoid bisection by checking for monotonicity
    d = ForwardDiff.derivative(prop, dom)
    low(d) > 0 && high(prop(high(dom))) < 0 && return true
    high(d) < 0 && high(prop(low(dom))) < 0 && return true

    high(prop(dom)) < 0 && return true

    i1, i2 = split(dom)
    forall(i1, prop) && forall(i2, prop)
end
