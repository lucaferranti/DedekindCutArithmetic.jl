using DedekindCutArithmetic
using Test

@testset "simple arithmetic" begin
    a = RationalCauchyCut(1, 10)
    a_ref = 1 // 10
    for op in (+, -, *)
        b = op(a, a)
        i = refine!(b)
        @test width(i) < DyadicReal(1, 53)
        @test Rational(low(i)) < op(a_ref, a_ref) < Rational(high(i))
    end

    b = -a
    i = refine!(b)
    @test width(i) < DyadicReal(1, 53)
    @test Rational(low(i)) < -1 // 10 < Rational(high(i))

    ia2 = refine!(a^2)
    @test width(ia2) < DyadicReal(1, 53)
    @test Rational(low(ia2)) < 1 // 100 < Rational(high(ia2))

    ia3 = refine!(a^3)
    @test width(ia3) < DyadicReal(1, 53)
    @test Rational(low(ia3)) < 1 // 1000 < Rational(high(ia3))

    @test zero(ia2) == zero(typeof(ia2)) == DyadicReal(0, 0)
    @test one(ia2) == one(typeof(ia2)) == DyadicReal(1, 0)
end

@testset "square root" begin
    a = DyadicReal(2)
    sqrt2 = sqrt(a)

    isqrt2 = refine!(sqrt2; precision = 80)
    @test BigFloat(width(isqrt2)) <= 0x1p-80
    @test BigFloat(low(isqrt2)) <= sqrt(big(2)) <= BigFloat(high(isqrt2))

    isqrt2pow2 = refine!(sqrt2^2)
    @test BigFloat(width(isqrt2pow2)) <= 0x1p-53
    @test low(isqrt2pow2) <= 2 <= high(isqrt2pow2)
end

@testset "README example" begin
    my_sqrt(a) = @cut x ∈ ℝ, (x < 0) ∨ (x * x < a), (x > 0) ∧ (x * x > a)

    sqrt2 = my_sqrt(2) # lazy computation, however it is evaluated to 53 bits precision when printing

    isqrt2 = refine!(sqrt2; precision = 80)
    @test BigFloat(width(isqrt2)) <= 0x1p-80
    @test BigFloat(low(isqrt2)) <= sqrt(big(2)) <= BigFloat(high(isqrt2))
    @test isqrt2 == sqrt2.mpa

    my_max(f::Function) = @cut a ∈ ℝ, ∃(x ∈ [0, 1]:f(x) > a), ∀(x ∈ [0, 1]:f(x) < a)
    f = x -> x * (1 - x)
    fmax = my_max(f)
    ifmax = refine!(fmax)
    @test ifmax == fmax.mpa
    @test BigFloat(width(ifmax)) <= 0x1p-53
    @test low(ifmax) < 1 // 4 < high(ifmax)
end

@testset "exact macro" begin
    a = exact"0.1"
    @test a.num == 1
    @test a.den == 10

    # check denominator doesn't overflow
    a = exact"0.09999999999999999167332731531132594682276248931884765625"
    b = 9999999999999999167332731531132594682276248931884765625 // big(10)^56

    @test a.num == numerator(b)
    @test a.den == denominator(b)
end
