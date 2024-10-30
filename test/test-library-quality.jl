using Aqua, DedekindCutArithmetic

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(DedekindCutArithmetic)
end

if VERSION >= v"1.11"
    @testset "Public API is documented" begin
        @testset "Symbol $n" for n in names(DedekindCutArithmetic)
            @test Docs.hasdoc(DedekindCutArithmetic, n)
        end
    end
end
