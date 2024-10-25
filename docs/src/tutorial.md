# Basic Tutorial

This tutorial will guide you through the basic functionalities of `DedekindCutArithmetic.jl`. These examples assume you have loaded the library with

```@repl tutorial1
using DedekindCutArithmetic
```

## Motivation: What is exact real arithmetic?

Whenever doing computations, we need to face the problem of rounding errors. Standard techniques to cope with it are

- *floating point arithmetic*: use 64 bits or 32 bits to approximate real numbers. This is what happens by default when you type `0.1` in the julia REPL. It is the fastest of the options, but also loses accuracy the fastest.
- *arbitrary precision floating point arithmetic*: Set an arbitrary (within machine memory limits) precision *a priori* and do all computations using that precision. In Julia, this is achieved using `BigFloat`, which uses the C library MPFR under the hood. By default, it uses 256 bits of precision. This allows more accurate computations, but rounding error will still accumulate and for big enough inputs or long enough computations a significant loss of accuracy may still occur.
- *interval arithmetic*: Use intervals instead of numbers and perform all operations so that the resulting interval contains the true result. This will give a rigorous bound of the error. However, for several factors (directed rounding, dependency problem, wrapping effect) the width of the interval may grow too big and give an uninformative result.

An alternative approach is *exact real arithmetic*, which sets a target precision and outputs the final result with that precision. The main difference from e.g. MPFR, is that here the precision is dynamic and is increased during computation. Everything has a tradeoff of course, and exact real arithmetic can be slower than MPFR or interval arithmetic, especially for long complex computations.

The following snippets gives a motivation example for exact real arithmetic. Obviously, ``(1 + a) - a`` should alwyas be ``1``. However, we get a complete wrong answer both with 64 and 256 bits of precision. With interval arithmetic, we get an interval containing the correct answer, but too wide to be informative. With exact real arithmetic we get a sharp bound on the correct value.

```@repl tutorial1
a_float = sqrt(2.0^520/3)
res_float = (1 + a_float) - a_float

a_mpfr = sqrt(big(2)^520/3)
res_mpfr = (1 + a_mpfr) - a_mpfr

using IntervalArithmetic

a_interval = sqrt(interval(big(2)^520//3))
res_interval = (interval(1) + a_interval) - a_interval

a_era = sqrt(RationalCauchyCut(big(2)^520//3))
res_era = (1 + a_era) - a_era
```

There are different approaches to exact real arithmetic. This library builds on the theoretical framework based on Dedekind cuts and Abstract stone duality, proposed in [bauer2008efficient, bauer2009dedekind](@cite) and first implemented in [marshall](@cite). Next, the basic functionalities of this library are presented.

## Dyadic numbers

The fundamental building block of our arithmetic is *dyadic numbers*, that is, a number in the form ``\frac{m}{e^{-k}}`` with ``m\in\mathbb{Z},e\in\mathbb{N}``. We will denote the set of dyadic reals as ``\mathbb{D}``.

These can be built in the libary using [`DyadicReal`](@ref)

Dyadic reals are closed under addition, subtraction and multiplication.

```@repl tutorial1
d1 = DyadicReal(1, 2) # represents 1 ⋅ 2⁻²
d2 = DyadicReal(2)
d1 + d2
d1 - d2
d1 * d2
```

!!! warning "Warning"
    Division is currently not supported

## Dyadic interval

There is plenty of real numbers which are not dyadic, for example ``0.1, \sqrt{2},\pi`` and so on so forth. What we will want to do, we will want a [`DyadicInterval`](@ref) ``[a, b]`` with ``a,b`` dyadic reals, which bounds the value we want to approximate. These intervals can be manipulated using interval arithmetic.

```@repl tutorial1
i1 = DyadicInterval(1, 2)
i2 = DyadicInterval(DyadicReal(1, 1), DyadicReal(1, 2))

i1 + i2
i1 - i2
i1 * i2
```

An important thing to notice is that our library relies on *Kaucher interval arithmetic*, which allows generalized intervals ``[a, b]`` with ``a > b``.

```@repl tutorial1
i = DyadicInterval(3, 1)
```

!!! warning "Warning"
    Division is currently not supported

## Defining cuts

We finally get to the main data structure of the library: [`DedekindCut`](@ref). The intuitive idea of a dedekind cut to define a real number ``x`` is the following

1. Find a set ``L\subset \mathbb{D}`` so that each element in ``L`` is strictly smaller than ``x``
2. Find a set ``U \subset \mathbb{D}`` so that each element in ``U`` is strictly bigger than ``x``.
3. To get better and better approximations of ``x``, keep increasing the upper bound of ``L`` and decreasing the lower bound of ``U``, this will give a dyadic interval that shrinks around ``x``.

### Baby example

Let us first see a very trivial example, to get a taste of how to build dedekind cuts in practice in the library. Suppose we want to define the number ``2`` as a Dedekind cut. This is of course dummy, since that is a dyadic number and we could simply do `DyadicReal(2)` to get the exact value.

To define a cut, we need to find an expression for the lower set and upper set. In this case, we simply have

- **Lower set**: ``\{x \in \mathbb{D}: x < 2\}``
- **Upper set**: ``\{x \in \mathbb{D}: x > 2\}``

Dedekind cuts can be built with the [`@cut`](@ref) macro and the syntax is the

```julia
@cut var_name ∈ domain, lower_set_expression, upper_set_expression
```

If we have no idea where the the number we are defining lies on the real line, we can use ``\mathbb{R}`` for the domain. Alternatively, if we know that it lies in an interval ``[a, b]``, we can restrict the domain to that interval. This will often lead to faster approximations. Let's see this in practice

```@repl tutorial1
my2 = @cut x ∈ ℝ, x < 2, x > 2;
```

By default, this performs a *lazy* computation, that is, nothing has actually been computed so far. We can now get an arbitrary good approximation of ``\sqrt{2}`` using [`refine!`](@ref) function.

```@repl tutorial1
refine!(my2) # uses 53 bits of precision by default
```

The number can be queried at different precisions using the `precision` keyword. Refining to a precision `k` will produce a dyadic interval with width smaller than ``2^{-k}``.

```@repl tutorial1
refine!(my2; precision=80)
```

It is worth mentioning that for printing, the expression is evaluated to 53 bits of precision (that is, same of a 64-bits float), hence the following in the REPL is not entirely lazy. To have a lazy computation in the REPL, suppress the output with `;`

```@repl tutorial1
@cut x ∈ [0, 3], x < 2, x > 2
```

!!! warning "Warning"
    Unbounded intervals are not really supported, infinity is replaced by `big(typemax(Int))` during macro expansion.

### Square root as Dedekind cut

Let's see an example, suppose we want to define ``\sqrt{a}`` for arbitrary dyadic ``a``. We need to find a suitable expression for ``L`` and ``U``.

- **Lower set**: Since ``\sqrt{a}`` is positive, then all negative ``x`` will be smaller than ``\sqrt{a}`` and hence belong to ``L``. For positive ``x``, we have ``x < \sqrt{a} \leftrightarrow x \cdot x < a``. This gives an expression for the lower set

```math
L = \{x \in \mathbb{D} : x < 0 \lor x \cdot x < 0\}
```

- **Upper set**: Similarly, for a number to possibly be greater than ``sqrt{a}``, it will need to be positive. Furthermore for positive ``x`` we have ``x > \sqrt{a} \leftrightarrow x \cdot x > a``, giving the expression

```math
L = \{x \in \mathbb{D} : x > 0 \land x \cdot x > 0\}
```

In the library, this can be implemented using the [`@cut`](@ref) macro. We can now define a function that computes the square root of a number using dedekind cuts.

```@repl tutorial1
my_sqrt(a) = @cut x ∈ ℝ, (x < 0) ∨ (x * x < a), (x > 0) ∧ (x * x > a)
```

We can now use it to compute the ``\sqrt{2}`` to an arbitrary precision

```@repl tutorial1
sqrt2 = my_sqrt(2);
isqrt2 = refine!(sqrt2; precision=80)
```

and verify that the desired accuracy is achieved

```@repl tutorial1
width(isqrt2)
width(isqrt2) < DyadicReal(1, 80)
```

## Cuts with quantifiers

So far we have seen how to define numbers whose cuts can be expressed using propositional logic. We can however do better. Namely, we can use first-order logic, i.e. quantifiers like ``\forall`` and ``\exists`` to define more elaborated cuts.

Let us now see how to define the maximum of a function with domain ``[0, 1]``. Again, we need to define the lower and upper set.

**Lower set**: if ``a \in L``, it is smaller than the maximum, i.e. there will be an element in the domain of the function for which ``f(x) > a``, this gives us the expression

```math
L = \{a \in \mathbb{D} : \exists x \in [0, 1] : f(x) > a\}
```

**Upper set**: if ``a \in U``, it is greater than the maximum, which means it is also greater than ``f(x)`` for every ``x`` in the domain, this gives us

```math
U = \{a \in \mathbb{D} : \forall x \in [0, 1] : f(x) < a\}
```

The `@cut` macro supports parsing quantifiers with a very similar syntax

```@repl tutorial1
my_max(f::Function) = @cut a ∈ ℝ, ∃(x ∈ [0, 1] : f(x) > a), ∀(x ∈ [0, 1] : f(x) < a)
```

we can now use that to compute the maximum of ``f(x) = x(1 - x)``, which should be ``\frac{1}{4}``

```@repl tutorial1
my_max(x -> x * (1 - x))
```
