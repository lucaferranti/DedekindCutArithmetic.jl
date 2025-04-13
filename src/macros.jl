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
macro exists(ex)
    parse_quantifier_body(ex, :exists)
end
const var"@∃" = var"@exists"

"""
Check whether ``∀ x ∈ dom : prop(x)``
"""
macro forall(ex)
    parse_quantifier_body(ex, :forall)
end
const var"@∀" = var"@forall"

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

function parse_decimal(s::AbstractString)
    num_exp = split(s, ('e', 'E'))
    1 <= length(num_exp) <= 2 || throw(Meta.ParseError("invalid literal $s"))
    n = first(num_exp)
    int_dec = split(n, '.')
    1 <= length(int_dec) <= 2 || throw(Meta.ParseError("invalid literal $s"))
    num, logden = if length(int_dec) == 2
        int, dec = int_dec
        parse(BigInt, int * dec), -length(dec)
    else
        parse(BigInt, first(int_dec)), 0
    end
    if length(num_exp) == 2
        logden += parse(BigInt, last(num_exp))
    end
    if logden < 0
        num // 10^(-logden)
    else
        num * 10^logden
    end
end

"""
Parse a decimal literal into a Rational{BigInt}

```julia
julia> exact"0.1"
1//10
```

This is needed because literals are already parsed before constructing the AST, hence
when writing :(x - 0.1) one would get the floating point approximation of 1//10 instead of the
exact rational.
"""
macro exact_str(s::AbstractString)
    parse_decimal(s)
end
