function parse_quantifier_body(ex, head)
    dom, body = if @capture(ex, x_∈dom_:f_<g_)
        dom, :($x -> $f - $g)
    elseif @capture(ex, x_∈dom_:f_>g_)
        dom, :($x -> $g - $f)
    else
        throw(ArgumentError("Invalid body for quantifier"))
    end
    a, b = parse_domain(dom)
    :($head(DyadicInterval($a, $b), $body))
end

"""
Check whether ``∃ x ∈ dom : prop(x)``
"""
macro ∃(ex)
    parse_quantifier_body(ex, :exists)
end

"""
Check whether ``∀ x ∈ dom : prop(x)``
"""
macro ∀(ex)
    parse_quantifier_body(ex, :forall)
end

"""
Transformations on the expression before being processed by [`@cut`](@ref)
"""
function preprocess_expression(ex)
    MacroTools.postwalk(ex) do s
        s == :∞ && return big(typemax(Int))
        @capture(s, a_∧b_) && return :($a && $b)
        @capture(s, a_∨b_) && return :($a || $b)
        @capture(s, ∃(prop_)) && return parse_quantifier_body(prop, :exists)
        @capture(s, ∀(prop_)) && return parse_quantifier_body(prop, :forall)
        s
    end
end

function parse_domain(dom)
    if dom == :ℝ
        -big(typemax(Int)), big(typemax(Int))
    elseif @capture(dom, [a_, b_])
        a, b
    else
        throw(ArgumentError("Invalid domain $dom"))
    end
end

"""
Macro to construct a [`DedekindCut`](@ref).

A cut is defined using the following syntax

```julia
@cut x ∈ [a, b], low, high
```

This defines a real number ``x`` in the interval ``[a, b]``
which is approximated by the inequality ``φ(x)`` from below and ``ψ(x)`` from above.

``φ`` and ``ψ`` can be any julia expression, also referring to variables in the scope where the macro is called.

Similarly, ``a`` and ``b`` can also be julia expressions, but they cannot depend on ``x``.
"""
macro cut(ex)
    ex2 = preprocess_expression(ex)
    if @capture(ex2, (x_ ∈ dom_, low_, high_))
        a, b = parse_domain(dom)
        esc(:(DedekindCut($x -> $low, $x -> $high, DyadicInterval($a, $b))))
    else
        throw(ArgumentError("Invalid cut expression $ex"))
    end
end
