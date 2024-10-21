
Base.promote_rule(::Type{DyadicReal}, ::Type{<:Integer}) = DyadicReal
Base.promote_rule(::Type{DyadicInterval}, ::Type{<:Integer}) = DyadicInterval
Base.promote_rule(::Type{DyadicInterval}, ::Type{DyadicReal}) = DyadicInterval
Base.promote_rule(::Type{RationalCauchyCut}, ::Type{<:AbstractFloat}) = RationalCauchyCut
Base.promote_rule(::Type{RationalCauchyCut}, ::Type{<:Rational}) = RationalCauchyCut
Base.promote_rule(::Type{<:AbstractDedekindReal}, ::Type{<:_Real}) = AbstractDedekindReal

AbstractDedekindReal(x::Integer) = DyadicReal(x)
AbstractDedekindReal(q::Union{Rational, AbstractFloat}) = RationalCauchyCut(q)
