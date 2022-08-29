using HPIPM
using Test

N = Cint(5)
nu = Cint[1,1,1,1,1,0]
nx = Cint[2,2,2,2,2,2]
nbu = zeros(Cint,N+1)
nbx = pushfirst!(zeros(Cint,N), 2)
ng = zeros(Cint,N+1)
nsbx = zeros(Cint,N+1)
nsbu = zeros(Cint,N+1)
nsg = zeros(Cint,N+1)
nbue = zeros(Cint,N+1)
nbxe = zeros(Cint,N+1)
nge = zeros(Cint,N+1)

A = Float64[1,0,1,1]
B = Float64[0,1]
b = Float64[0,0]
Q = Float64[1,0,0,1]
R = Float64[1]
S = Float64[0,0]
q = Float64[1,1]
r = Float64[0]

lbx0 = Float64[1,1]
ubx0 = Float64[1,1]
idxbx0 = Cint[0,1]

u_guess = Float64[0]
x_guess = Float64[0,0]
sl_guess = Float64[]
su_guess = Float64[]

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

# Args
mode = 1
iter_max = 30;
alpha_min = 1e-8;
mu0 = 1e4;
tol_stat = 1e-4;
tol_eq = 1e-5;
tol_ineq = 1e-5;
tol_comp = 1e-5;
reg_prim = 1e-12;
warm_start = 0;
pred_corr = 1;
ric_alg = 0;
split_step = 1;

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
qp.dim

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

# ## Codegen
# HPIPM.ocp_qp_dim_codegen("test_d_ocp_data_jl.c", "w", dim)
# HPIPM.ocp_qp_codegen("test_d_ocp_data_jl.c", "a", dim, qp)
# HPIPM.ocp_qp_ipm_arg_codegen("test_d_ocp_data_jl.c", "a", dim, arg)

## Solve
HPIPM.ocp_qp_ipm_solve(qp, qp_sol, arg, workspace)
status = HPIPM.ocp_qp_ipm_get_status(workspace)
println("Status = ", status)
workspace.iter
iters = HPIPM.ocp_qp_ipm_get_iter(workspace)
obj = HPIPM.ocp_qp_ipm_get_obj(workspace)
res = HPIPM.ocp_qp_ipm_get_max_res_stat(workspace)
HPIPM.ocp_qp_ipm_get_obj(workspace)
println("Got $iters iters in Julia")
println("Got $obj objective value")
println("Stat res = $res")

# ##
# u = zeros(1)
# HPIPM.ocp_qp_sol_get_u(0, qp_sol, u)
# u
# HPIPM.ocp_qp_ipm_get_max_res_stat(workspace)
# HPIPM.ocp_qp_ipm_get_max_res_eq(workspace)
# HPIPM.ocp_qp_ipm_get_max_res_ineq(workspace)
# HPIPM.ocp_qp_ipm_get_max_res_comp(workspace)
# HPIPM.ocp_qp_ipm_get_obj(workspace)