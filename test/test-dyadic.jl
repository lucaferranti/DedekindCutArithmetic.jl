using DedekindCutArithmetic
using Test

@testset "Dyadic numbers construction" begin
    @test DyadicReal(1) == DyadicReal(big(1), 0)
    @test zero(DyadicReal) == zero(DyadicReal(1)) == DyadicReal(0, 0)
    @test iszero(zero(DyadicReal))

    d = DyadicReal(1, 2)
    @test low(d) == high(d) == midpoint(d) == d
    @test radius(d) == width(d) == zero(DyadicReal)

    @test repr("text/plain", d) == "0.25"

    x1 = Float64(DyadicReal(1, 1))
    x2 = BigFloat(DyadicReal(1, 1))
    x3 = Rational(DyadicReal(1, 1))
    @test x1 == x2 == x3 == 0.5
    @test x1 isa Float64
    @test x2 isa BigFloat
    @test x3 isa Rational{BigInt}

    @test refine!(d) == DyadicInterval(d, d)
    @test d == d
end

@testset "Arithmetic operations" begin
    d1 = DyadicReal(1, 3)
    d2 = DyadicReal(1, 2)

    @test +d1 == d1
    @test -d1 == DyadicReal(-1, 3)

    @test d1 + d2 == DyadicReal(3, 3)
    @test d2 + d1 == DyadicReal(3, 3)

    @test d1 - d2 == DyadicReal(-1, 3)
    @test d2 - d1 == DyadicReal(1, 3)

    @test d1 * d2 == DyadicReal(1, 5)
    @test DyadicReal(-typemax(Int), 2) * DyadicReal(-typemax(Int), 3) ==
          DyadicReal(big(typemax(Int))^2, 5)

    @test d1 < d2
    @test d1 <= d2
    @test d2 > d1
    @test d2 >= d1
    @test DyadicReal(1, 0) > DyadicReal(-1, 0)

    @test d1 == d1
    @test d1 != d2
    @test d1 == DyadicReal(2, 4)

    @test d1 + 1 == DyadicReal(9, 3)
    @test iszero(d1 * 0)
    @test iszero(0 * d1)
    @test d1 * 1 == d1
    @test d1 * 3 == DyadicReal(3, 3)
    @test d1 - 0 == d1

    @test (d1 << 1) == DyadicReal(1, 2) == d1 * 2
    @test (d1 << 4) == DyadicReal(2, 0) == d1 * 16
    @test (d1 >> 3) == DyadicReal(1, 6)

    @test abs(d1) == abs(-d1) == d1
    @test round(d1) == DyadicReal(0, 0)
    @test floor(d1) == DyadicReal(0, 0)
    @test ceil(d1) == DyadicReal(1, 0)

    d2 = DyadicReal(123, 5)
    @test round(d2) == ceil(d2)
    @test round(BigInt, d2) == ceil(BigInt, d2) == big(4)
    @test floor(BigInt, d2) == big(3)
end

@testset "inexact arithmetic operations" begin
    d1 = DyadicReal(1, 2)
    inv_d1 = inv(d1)
    @test inv_d1.num == 4
    @test inv_d1.den == 1

    d2 = DyadicReal(1, 0)
    d3 = DyadicReal(3, 0)

    rat1 = d1 / d2
    @test rat1.num == 1
    @test rat1.den == 4

    rat2 = d1 / d3
    @test rat2.num == 1
    @test rat2.den == 12
end
