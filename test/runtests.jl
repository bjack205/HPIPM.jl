using HPIPM
using Test

const TMP_DIR = mktempdir(@__DIR__)

@testset "C API" begin
    include("getting_started_test.jl")
end
@testset "Julia API" begin
    include("getting_started_solver_test.jl")
end
@testset "Codegen" begin
    capi = readlines(c_filename)
    japi = readlines(j_filename)
    @test capi == japi
end