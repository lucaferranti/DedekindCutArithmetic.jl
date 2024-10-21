using DedekindCutArithmetic
using Test

@testset "Universal quantifier" begin
    @test @∀ x ∈ [0, 1]:x > -1
    @test @∀ x ∈ [0, 1]:x > -0.0001
    @test @∀ x ∈ [0, 1]:x < 2
    @test @∀ x ∈ [0, 1]:x < 1.0001

    @test !(@∀ x ∈ [0, 1]:x > 0.0001)
    @test !(@∀ x ∈ [0, 1]:x < 0.9999)
end

@testset "Existential quantifier" begin
    @test @∃ x ∈ [0, 1]:x > -1
    @test @∃ x ∈ [0, 1]:x > 0.9999
    @test @∃ x ∈ [0, 1]:x < 2
    @test @∃ x ∈ [0, 1]:x < 0.0001

    @test !(@∃ x ∈ [0, 1]:x > 1.0001)
    @test !(@∃ x ∈ [0, 1]:x < -0.0001)
end
