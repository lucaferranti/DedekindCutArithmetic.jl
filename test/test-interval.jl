using DedekindCutArithmetic
using Test

@testset "Basic interval construction" begin
    i1 = DyadicInterval(1, 2)
    @test i1 == DyadicInterval(DyadicReal(1, 0), DyadicReal(2, 0))

    @test isforward(i1)
    @test dual(i1) == DyadicInterval(DyadicReal(2, 0), DyadicReal(1, 0))
    @test isbackward(dual(i1))
    @test dual(dual(i1)) == i1
    @test zero(DyadicInterval) == DyadicInterval(zero(DyadicReal), zero(DyadicReal))

    @test refine!(i1; precision = 12345) == i1
end

@testset "Basic set operations" begin
    @test overlaps(DyadicInterval(0, 1), DyadicInterval(DyadicReal(1, 1), 1))
    @test split(DyadicInterval(0, 2)) == (DyadicInterval(0, 1), DyadicInterval(1, 2))
    @test thirds(DyadicInterval(0, 2)) == (DyadicReal(1, 1), DyadicReal(3, 1))

    i = DyadicInterval(0, 1)
    @test low(i) == 0
    @test high(i) == 1
    @test midpoint(i) == DyadicReal(1, 1)
    @test width(i) == 1
    @test radius(i) == DyadicReal(1, 1)
end

@testset "Arithmetic operations" begin
    i1 = DyadicInterval(0, 1)
    i2 = DyadicInterval(2, 3)

    @test +i1 == i1
    @test -i2 == DyadicInterval(-3, -2)

    @test i1 + i2 == DyadicInterval(2, 4)
    @test i1 - i2 == DyadicInterval(-3, -1)

    @test i1 + DyadicReal(1) == i1 + 1 == DyadicInterval(1, 2)

    # TODO: more cases for multiplication
    @test i1 * i2 == DyadicInterval(0, 3)

    @test DyadicInterval(0, 1) < DyadicInterval(2, 3)
    @test DyadicInterval(0, 1) <= DyadicInterval(2, 3)
    @test DyadicInterval(2, 3) > DyadicInterval(0, 1)
    @test DyadicInterval(2, 3) >= DyadicInterval(0, 1)

    @test !(DyadicInterval(0, 2) < DyadicInterval(1, 3))
    @test !(DyadicInterval(1, 3) > DyadicInterval(0, 2))

    @test DyadicInterval(1, 2)^2 == DyadicInterval(1, 4)
    @test DyadicInterval(3, 2)^2 == DyadicInterval(9, 4)
    @test DyadicInterval(-3, 2)^2 == DyadicInterval(0, 9)
    @test DyadicInterval(2, -3)^2 == DyadicInterval(9, 0)
    @test DyadicInterval(-3, -2)^2 == DyadicInterval(4, 9)

    @test DyadicInterval(-2, 2)^3 == DyadicInterval(-8, 8)
    @test DyadicInterval(2, -2)^3 == DyadicInterval(8, -8)
end

@testset "inexact arithmetic operations" begin
    i1 = DyadicInterval(1, 3)
    inv_i1 = inv(i1)
    @test 1 // 3 - 1 // (big(1) << 52) < low(inv_i1) < 1 // 3
    @test 1 < high(inv_i1) < 1 + 1 // (big(1) << 52)

    inv_i2 = inv(i1; precision = 80)
    @test 1 // 3 - 1 // (big(1) << 79) < low(inv_i2) < 1 // 3
    @test 1 < high(inv_i2) < 1 + 1 // (big(1) << 79)

    i2 = DyadicInterval(-1, 1)
    @test_throws DomainError inv(i2)
    @test_throws DomainError i1/i2

    div_int1 = DyadicInterval(1, 1) / DyadicInterval(1, 3)
    @test 1 // 3 - 1 // (big(1) << 52) < low(div_int1) < 1 // 3
    @test 1 < high(div_int1) < 1 + 1 // (big(1) << 52)

    div_int2 = /(DyadicInterval(1, 1), DyadicInterval(1, 3); precision = 80)
    @test 1 // 3 - 1 // (big(1) << 79) < low(div_int2) < 1 // 3
    @test 1 < high(div_int2) < 1 + 1 // (big(1) << 79)
end
