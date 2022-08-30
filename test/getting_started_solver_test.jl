using HPIPM
using Test

include("getting_started_data.jl")

# Initialize
solver = HPIPM.HPIPMSolver{Float64}(nx, nu, nbx)

# Assign data
HPIPM.set_dynamics!(solver, A, B, b, 1, N)
HPIPM.set_cost!(solver, Q, R, S, q, r, 1, N+1)
HPIPM.set_state_bound!(solver, lbx0, ubx0, 1:2, 1)

# Set Options
HPIPM.set_default_options!(solver, mode)
HPIPM.set_option!(solver, "mu0", mu0)
HPIPM.set_option!(solver, "iter_max", iter_max)
HPIPM.set_option!(solver, "alpha_min", alpha_min)
HPIPM.set_option!(solver, "tol_stat", tol_stat)
HPIPM.set_option!(solver, "tol_eq", tol_eq)
HPIPM.set_option!(solver, "tol_ineq", tol_ineq)
HPIPM.set_option!(solver, "tol_comp", tol_comp)
HPIPM.set_option!(solver, "reg_prim", reg_prim)
HPIPM.set_option!(solver, "warm_start", warm_start)
HPIPM.set_option!(solver, "pred_corr", pred_corr)
HPIPM.set_option!(solver, "ric_alg", ric_alg)
HPIPM.set_option!(solver, "split_step", split_step)

# Solve
HPIPM.solve!(solver)
status = HPIPM.getstatus(solver)
@test status == HPIPM.SUCCESS

# Get solution
X = HPIPM.getstates(solver)
U = HPIPM.getinputs(solver)
@test X[1] ≈ lbx0

# Get stats
HPIPM.getstat(solver, "obj")
@test HPIPM.getstat(solver, "max_res_comp") < tol_comp 
@test HPIPM.getstat(solver, "max_res_eq") < tol_eq
@test HPIPM.getstat(solver, "max_res_ineq") < tol_ineq
@test HPIPM.getstat(solver, "max_res_stat") < tol_stat

## Generate C code for problem
j_filename = joinpath(TMP_DIR, "test_d_ocp_data_solver.c")
HPIPM.codegen(solver, j_filename)