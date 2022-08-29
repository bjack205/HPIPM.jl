module HPIPM

const libhpipm_jll = joinpath(@__DIR__, "../deps/build/libhpipm_jll.so") 
const libhpipm = "/home/brian/Code/hpipm/build/libhpipm.so"

include("hpipm_common.jl")
include("ocp_qp_dim.jl")
include("hpipm_jll.jl")
include("ocp_qp.jl")
include("ocp_qp_sol.jl")
include("ocp_qp_ipm.jl")
include("ocp_qp_solve.jl")

end
