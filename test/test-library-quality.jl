using Aqua, DedekindCutArithmetic, JET

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(DedekindCutArithmetic)
end

@testset "Code linting (JET.jl)" begin
    JET.test_package("DedekindCutArithmetic"; target_defined_modules = true)
end

if VERSION >= v"1.11"
    @testset "Public API is documented" begin
        @testset "Symbol $n" for n in names(DedekindCutArithmetic)
            @test Docs.hasdoc(DedekindCutArithmetic, n)
        end
    end
end
