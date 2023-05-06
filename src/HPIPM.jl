module HPIPM

# using HPIPM_jll

# const libhpipm = HPIPM_jll.hpipm
# const libhpipm = "/home/brian/Code/hpipm/build/install/lib/libhpipm.so"
include(joinpath(@__DIR__, "..", "deps", "deps.jl"))
@assert isfile(libhpipm)

# hpipm wrapper files
include("hpipm_common.jl")
include("ocp_qp_dim.jl")
include("hpipm_jll.jl")
include("ocp_qp.jl")
include("ocp_qp_sol.jl")
include("ocp_qp_ipm.jl")
include("ocp_qp_solve.jl")

# convenience API
include("solver.jl")

export 
    HPIPMSolver,
    set_dynamics!,
    set_cost!,
    set_state_bound!,
    set_input_bound!,
    set_constraint!,
    set_option!,
    set_default_options!,
    solve!,
    getstatus,
    getstate,
    getstate!,
    getinput,
    getinput!,
    getstates,
    getstates!,
    getinputs,
    getinputs!,
    getstat


end
