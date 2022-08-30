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