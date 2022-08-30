using HPIPM
using Test

include("getting_started_data.jl")

AA = [pointer(A) for i = 1:N]
BB = [pointer(B) for i = 1:N]
bb = [pointer(b) for i = 1:N]
QQ = [pointer(Q) for i = 1:N+1]
RR = [pointer(R) for i = 1:N+1]
SS = [pointer(S) for i = 1:N+1]
qq = [pointer(q) for i = 1:N+1]
rr = [pointer(r) for i = 1:N+1]

iidxbx = [pointer(idxbx0); fill(Ptr{Cint}(C_NULL), N)]
llbx = [pointer(lbx0); fill(Ptr{Cdouble}(C_NULL), N)]
uubx = [pointer(ubx0); fill(Ptr{Cdouble}(C_NULL), N)]
iidxbu = fill(Ptr{Cint}(C_NULL), N+1)
llbu = fill(Ptr{Cdouble}(C_NULL), N+1)
uubu = fill(Ptr{Cdouble}(C_NULL), N+1)
CC = fill(Ptr{Cdouble}(C_NULL), N+1)
DD = fill(Ptr{Cdouble}(C_NULL), N+1)
llg = fill(Ptr{Cdouble}(C_NULL), N+1)
uug = fill(Ptr{Cdouble}(C_NULL), N+1)
ZZl = fill(Ptr{Cdouble}(C_NULL), N+1)
ZZu = fill(Ptr{Cdouble}(C_NULL), N+1)
zzl = fill(Ptr{Cdouble}(C_NULL), N+1)
zzu = fill(Ptr{Cdouble}(C_NULL), N+1)
iidxs = fill(Ptr{Cint}(C_NULL), N+1)
llls = fill(Ptr{Cdouble}(C_NULL), N+1)
llus = fill(Ptr{Cdouble}(C_NULL), N+1)
iidxe = fill(Ptr{Cdouble}(C_NULL), N+1)


## OCP QP Dim
str_size = HPIPM.ocp_qp_dim_strsize()
dim_size = HPIPM.ocp_qp_dim_memsize(N)
memory = zeros(UInt8, dim_size) 
dim = HPIPM.ocp_qp_dim()
@test sizeof(dim) == str_size
@test sizeof(memory) == dim_size 
HPIPM.ocp_qp_dim_create(N, dim, memory);
@test dim.N == N
@test dim.memsize == dim_size

HPIPM.ocp_qp_dim_set_all(nx, nu, nbx, nbu, ng, nsbx, nsbu, nsg, dim)
@test unsafe_wrap(Array, dim.nx, (N+1,)) == nx
@test unsafe_wrap(Array, dim.nu, (N+1,)) == nu
@test unsafe_wrap(Array, dim.nbx, (N+1,)) == nbx
@test unsafe_wrap(Array, dim.nbu, (N+1,)) == nbu
@test unsafe_wrap(Array, dim.nsbx, (N+1,)) == nsbx
@test unsafe_wrap(Array, dim.nsbu, (N+1,)) == nsbu
@test unsafe_wrap(Array, dim.nsg, (N+1,)) == nsg

## OCP QP
qp = HPIPM.ocp_qp()
dim_size = HPIPM.ocp_qp_memsize(dim)
qp_mem = zeros(UInt8, dim_size)
HPIPM.ocp_qp_create(dim, qp, qp_mem)
HPIPM.ocp_qp_set_all(AA, BB, bb, QQ, SS, RR, qq, rr, iidxbx, llbx, uubx, iidxbu, llbu, uubu, 
  CC, DD, llg, uug, ZZl, ZZu, zzl, zzu, iidxs, llls, llus, qp
)

## QP sol 
qp_sol_size = HPIPM.ocp_qp_sol_memsize(dim)
qp_sol_mem = zeros(UInt8, qp_sol_size)
qp_sol = HPIPM.ocp_qp_sol()
HPIPM.ocp_qp_sol_create(dim, qp_sol, qp_sol_mem)

## IPM Arg
ipm_arg_size = HPIPM.ocp_qp_ipm_arg_memsize(dim)
ipm_arg_mem = zeros(UInt8, ipm_arg_size)
arg = HPIPM.ocp_qp_ipm_arg()
HPIPM.ocp_qp_ipm_arg_create(dim, arg, ipm_arg_mem)
HPIPM.ocp_qp_ipm_arg_set_default(HPIPM.SPEED, arg)
HPIPM.ocp_qp_ipm_arg_set_mu0(mu0, arg)
HPIPM.ocp_qp_ipm_arg_set_iter_max(iter_max, arg)
HPIPM.ocp_qp_ipm_arg_set_alpha_min(alpha_min, arg)
HPIPM.ocp_qp_ipm_arg_set_tol_stat(tol_stat, arg)
HPIPM.ocp_qp_ipm_arg_set_tol_eq(tol_eq, arg)
HPIPM.ocp_qp_ipm_arg_set_tol_ineq(tol_ineq, arg)
HPIPM.ocp_qp_ipm_arg_set_tol_comp(tol_comp, arg)
HPIPM.ocp_qp_ipm_arg_set_reg_prim(reg_prim, arg)
HPIPM.ocp_qp_ipm_arg_set_warm_start(warm_start, arg)
HPIPM.ocp_qp_ipm_arg_set_pred_corr(pred_corr, arg)
HPIPM.ocp_qp_ipm_arg_set_ric_alg(ric_alg, arg)
HPIPM.ocp_qp_ipm_arg_set_split_step(split_step, arg)

## IPM workspace
ipm_strsize = Int(HPIPM.ocp_qp_ipm_ws_strsize())
ipm_size = HPIPM.ocp_qp_ipm_ws_memsize(dim, arg)
ipm_mem = zeros(UInt8, ipm_size)
workspace = HPIPM.ocp_qp_ipm_ws()
HPIPM.ocp_qp_ipm_ws_create(dim, arg, workspace, ipm_mem)

## Solve
HPIPM.ocp_qp_ipm_solve(qp, qp_sol, arg, workspace)
status = HPIPM.ocp_qp_ipm_get_status(workspace)
@test status == HPIPM.SUCCESS
@test iters = HPIPM.ocp_qp_ipm_get_iter(workspace) == 3
obj = HPIPM.ocp_qp_ipm_get_obj(workspace)
@test res = HPIPM.ocp_qp_ipm_get_max_res_stat(workspace) < tol_stat

## Codegen
c_filename = joinpath(TMP_DIR, "test_d_ocp_data_jl.c")
HPIPM.ocp_qp_dim_codegen(c_filename, "w", dim)
HPIPM.ocp_qp_codegen(c_filename, "a", dim, qp)
HPIPM.ocp_qp_ipm_arg_codegen(c_filename, "a", dim, arg)
