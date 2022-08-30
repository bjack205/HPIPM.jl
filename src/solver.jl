raw"""
    HPIPMSolver{T}

A convenient wrapper around the C hpipm solver. Solves linear optimal control problems
of the form:

```math
\begin{align}
\underset{x_{1:N}, u_{1:N}}{\text{minimize}} &&& 
    \sum_{k=1}^N \frac{1}{2} x_k^T Q_k x_k + q_k^T x_k + 
                 \frac{1}{2} u_k^T R_k u_k + r_k^T u_k + 
                 u_k^T S_k x_k \\
    \text{subject to} &&& x_{k+1} = A_k x_k + B_k u_k + b_k \\
    &&& \underbar{x}_k \leq x_k \bar{x}_k \\
    &&& \underbar{u}_k \leq u_k \bar{u}_k \\
    &&& \underbar{g}_k \leq C_k x_k + D_k u_k \bar{g}_k \\
\end{align}
```
The original C interface supports "softened" constraints using slack variables, but these 
currently omitted from this interface.

Currently only supports double-precision floating point numbers.

!!! note
    All indices (usually denoted `k`) in the Julia interface are 1-indexed, keeping 
    with standard Julia. They are converted internally to the 0-based indexing of the 
    C interface.

# Constructor
The solver is constructed using:

```julia
using HPIPM
HPIPMSolver{Float64}(nx, nu, [nbx, nbu, ng])
```
where 
- `nx` is a `(N+1,)` vector of state dimensions.
- `nu` is a `(N+1,)` vector of input dimensions.
- `nbx` is a `(N+1,)` vector specifying the number of (double-sided) state bounds at each 
    time step
- `nbu` is a `(N+1,)` vector specifying the number of (double-sided) input bounds at each 
    time step
- `ng` is a `(N+1,)` vector specifying the number of general constraint at each time step.

## Defining the problem data
Use the following methods to assign the problem data:
- [`set_dynamics!`](@ref)
- [`set_cost!`](@ref)
- [`set_state_bound!`](@ref)
- [`set_input_bound!`](@ref)
- [`set_constraint!`](@ref)

## Setting Solver Options
The solver options can be set using 
- [`set_option!`](@ref)

# Solving
Use the [`solve!`](@ref) method to solve the problem once the data has been specified.

## Getting solve stats
Use the following methods to get solve statistics
- [`getstatus`](@ref)
- [`iterations`](@ref)
- [`getstat`](@ref)

## Retrieving the solution
Once solved, the following methods can be used to query the solution:
- [`getstatus`](@ref)
- [`getstate`](@ref)
- [`getstate!`](@ref)
- [`getinput`](@ref)
- [`getinput!`](@ref)
- [`getstates`](@ref)
- [`getstates!`](@ref)
- [`getinputs`](@ref)
- [`getinputs!`](@ref)

"""
struct HPIPMSolver{T}
    dim::ocp_qp_dim
    qp::ocp_qp{T}
    sol::ocp_qp_sol{T}
    arg::ocp_qp_ipm_arg
    ws::ocp_qp_ipm_ws
    dim_mem::Vector{UInt8}
    qp_mem::Vector{UInt8}
    sol_mem::Vector{UInt8}
    arg_mem::Vector{UInt8}
    ws_mem::Vector{UInt8}
    N::Int
    function HPIPMSolver{T}(
            nx::Vector{<:Integer},
            nu::Vector{<:Integer},
            nbx::Vector{<:Integer}=zero(nx),
            nbu::Vector{<:Integer}=zero(nu),
            ng::Vector{<:Integer}=zero(nx),
        ) where T
        N = length(nx) - 1

        nsbx = zero(nbx)
        nsbu = zero(nbu)
        nsg = zero(ng)

        # QP dim
        dim_size = ocp_qp_dim_memsize(N)
        dim_mem = zeros(UInt8, dim_size)
        dim = ocp_qp_dim()
        ocp_qp_dim_create(N, dim, dim_mem)
        ocp_qp_dim_set_all(nx, nu, nbx, nbu, ng, nsbx, nsbu, nsg, dim)

        # QP
        qp_size = ocp_qp_memsize(dim)
        qp_mem = zeros(UInt8, qp_size)
        qp = ocp_qp(T)
        ocp_qp_create(dim, qp, qp_mem)
        ocp_qp_set_all_zero(qp)

        # QP Sol
        sol_size = ocp_qp_sol_memsize(dim)
        sol_mem = zeros(UInt8, sol_size)
        sol = ocp_qp_sol(T)
        ocp_qp_sol_create(dim, sol, sol_mem)

        # IPM Arg
        ipm_arg_size = ocp_qp_ipm_arg_memsize(dim)
        ipm_arg_mem = zeros(UInt8, ipm_arg_size)
        arg = ocp_qp_ipm_arg()
        ocp_qp_ipm_arg_create(dim, arg, ipm_arg_mem)
        ocp_qp_ipm_arg_set_default(SPEED, arg)

        # IPM workspace
        ipm_size = ocp_qp_ipm_ws_memsize(dim, arg)
        ipm_mem = zeros(UInt8, ipm_size)
        ws = ocp_qp_ipm_ws()
        ocp_qp_ipm_ws_create(dim, arg, ws, ipm_mem)

        new{T}(dim, qp, sol, arg, ws, 
            dim_mem, qp_mem, sol_mem, ipm_arg_mem, ipm_mem, N)
    end
end

#############################################
## Setters
#############################################

"""
    set_dynamics!(solver, A, B, b, kstart, [kstop])

Sets the dynamics from stage `kstart` to `kstop` to the same data. 
Assumes the data is consistent with the specified sizes (checks for this not 
currently implemented).

If unspecified, `kstop` is equal to `kstart`.

`A` is of size `(nx[k+1] * nx[k],)`, `B` is of size `(nx[k+1] * nu[k],)`, and 
`b` is of size `(nx[k+1],)`

`A` and `B` can be specified as either vectors or column-major matrices.
"""
function set_dynamics!(solver::HPIPMSolver, A, B, b, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_A!(k-1, A, solver.qp)
        ocp_qp_set_B!(k-1, B, solver.qp)
        ocp_qp_set_b!(k-1, b, solver.qp)
    end
end

"""
    set_cost!(solver, Q, R, S, q, r, kstart, [kstop])

Sets the cost from stage `kstart` to `kstop` to the same data. 
Assumes the data is consistent with the specified sizes (checks for this not 
currently implemented).

If unspecified, `kstop` is equal to `kstart`.

`Q` is of size `(nx[k] * nx[k],)`, 
`R` is of size `(nu[k] * nu[k],)`, 
`S` is of size `(nu[k] * nx[k],)`, 
`q` is of size `(nx[k],)`,  and
`r` is of size `(nu[k],)`. 
"""
function set_cost!(solver::HPIPMSolver, Q, R, S, q, r, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_Q!(k-1, Q, solver.qp)
        ocp_qp_set_R!(k-1, R, solver.qp)
        ocp_qp_set_S!(k-1, S, solver.qp)
        ocp_qp_set_q!(k-1, q, solver.qp)
        ocp_qp_set_r!(k-1, r, solver.qp)
    end
end

"""
    set_state_bound!(solver, lb, ub, idx, kstart, [kstop])

Sets the two-sided state bound from stage `kstart` to `kstop` to the same data,
with lower bound `lb` and upper bound `ub`. The `idx` argument gives the state indices 
of the bounds, typicall `1:nx[k]`.

All arguments `lb`, `ub`, and `idx` should have the same size.

If unspecified, `kstop` is equal to `kstart`.
"""
function set_state_bound!(solver::HPIPMSolver, lb, ub, idx, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_lbx!(k-1, lb, solver.qp)
        ocp_qp_set_ubx!(k-1, ub, solver.qp)
        ocp_qp_set_idxbx!(k-1, Cint.(idx) .- one(Cint), solver.qp)
    end
end

"""
    set_input_bound!(solver, lb, ub, idx, kstart, [kstop])

Sets the two-sided input bound from stage `kstart` to `kstop` to the same data,
with lower bound `lb` and upper bound `ub`. The `idx` argument gives the input indices 
of the bounds, typicall `1:nx[k]`.

All arguments `lb`, `ub`, and `idx` should have the same size.

If unspecified, `kstop` is equal to `kstart`.
"""
function set_input_bound!(solver::HPIPMSolver, lb, ub, idx, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_lbu!(k-1, lb, solver.qp)
        ocp_qp_set_ubu!(k-1, ub, solver.qp)
        ocp_qp_set_idxbu!(k-1, Cint.(idx) .- one(Cint), solver.qp)
    end
end

raw"""
    set_constraint!(solver, C, D, lb, ub, kstart, [kstop])

Sets the two-sided general bound from stage `kstart` to `kstop` to the same data.
These constraints have the form:

```julia
    lb ≤ C * x[k] + D * u[k] ≤ ub
```

If unspecified, `kstop` is equal to `kstart`.
"""
function set_constraint!(solver::HPIPMSolver, C, D, lb, ub, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_C!(k-1, C, solver.qp)
        ocp_qp_set_D!(k-1, D, solver.qp)
        ocp_qp_set_lg!(k-1, lb, solver.qp)
        ocp_qp_set_ug!(k-1, ub, solver.qp)
    end
end

"""
    set_option!(solver, option, val)

Set one of the hpipm solver options. Options are listed in `HPIPM.OPTIONS_INT` and 
`HPIPM.OPTIONS_FLOAT`.`
"""
function set_option!(solver::HPIPMSolver{T}, option::AbstractString, val) where T
    found = false
    for (i,arg) in enumerate(OPTIONS_FLOAT)
        if string(arg) == option
            OPTIONS_FLOAT_METHODS[i](T(val), solver.arg) 
            found = true
            break
        end
    end
    for (i,arg) in enumerate(OPTIONS_INT)
        if string(arg) == option
            OPTIONS_INT_METHODS[i](Cint(val), solver.arg) 
            found = true
            break
        end
    end
    if !found
        @warn "$option isn't a recognized option."
    end
end

"""
    set_default_options!(solver, mode)

Sets the default options for one of the modes given by `HPIPM.hpipm_mode`.
"""
function set_default_options!(solver::HPIPMSolver, mode::Integer)
    set_default_options!(solver, hpipm_mode(mode))
end

function set_default_options!(solver::HPIPMSolver, mode::hpipm_mode)
    ocp_qp_ipm_arg_set_default(mode, solver.arg)
end

#############################################
## Solve 
#############################################

"""
    solve!(solver)

Solves the OCP QP. Doesn't return anything. The solution must queried using 
e.g. [`getstate`](@ref), [`getinputs!`](@ref), etc..
"""
function solve!(solver::HPIPMSolver)
    ocp_qp_ipm_solve(solver.qp, solver.sol, solver.arg, solver.ws)
end

"""
    getstatus(solver)

Get the return status of the solver after a solve.
"""
function getstatus(solver::HPIPMSolver)
    ocp_qp_ipm_get_status(solver.ws)
end

"""
    iterations(solver)

Number of solver iterations
"""
iterations(solver::HPIPMSolver) = getstat(solver, "iter")

#############################################
## Getters 
#############################################

"""
    getstate(solver, k)

Return the state at time step `k`.
"""
function getstate(solver::HPIPMSolver{T}, k) where T
    nx = ocp_qp_dim_get_nx(solver.dim, k - 1)
    x = zeros(T, nx)
    getstate!(solver, k, x)
    return x
end

"""
    getstate!(solver, k, x)

Copy the state at time step `k` in to `x`.
"""
getstate!(solver::HPIPMSolver, k, x) = ocp_qp_sol_get_x(k - 1, solver.sol, x)

"""
    getinput(solver, k)

Return the input at time step `k`.
"""
function getinput(solver::HPIPMSolver{T}, k) where T
    nu = ocp_qp_dim_get_nu(solver.dim, k - 1)
    u = zeros(T, nu)
    getinput!(solver, k, u)
    return u
end

"""
    getinput!(solver, k, u)

Copy the input at time step `k` in to `u`.
"""
getinput!(solver::HPIPMSolver, k, u) = ocp_qp_sol_get_u(k - 1, solver.sol, u)

"""
    getstates!(solver, X)

Copy the state trajectory to the vector of vectors `X`.
"""
function getstates!(solver::HPIPMSolver, X)
    N = solver.dim.N
    length(X) >= N + 1 || throw(DimensionMismatch("X must have at least $(N+1) vectors."))
    for k = 1:N+1
        getstate!(solver, k, X[k])
    end
    X
end

"""
    getinputs!(solver, U)

Copy the input trajectory to the vector of vectors `U`.
"""
function getinputs!(solver::HPIPMSolver, U)
    N = solver.dim.N
    length(U) >= N || throw(DimensionMismatch("U must have at least $(N) vectors."))
    for k = 1:N+1
        getinput!(solver, k, U[k])
    end
    U
end

"""
    getstates(solver)

Return the state trajectory as a vector of vectors.
"""
function getstates(solver::HPIPMSolver{T}) where T
    X = map(k->zeros(T,ocp_qp_dim_get_nx(solver.dim, k-1)), 1:solver.dim.N+1)
    getstates!(solver, X)
end

"""
    getinputs(solver)

Return the input trajectory as a vector of vectors.
"""
function getinputs(solver::HPIPMSolver{T}) where T
    U = map(k->zeros(T,ocp_qp_dim_get_nu(solver.dim, k-1)), 1:solver.dim.N+1) 
    getinputs!(solver, U)
end

getdynamicsdual!(solver::HPIPMSolver, k, y) = ocp_qp_sol_get_pi(k-1, solver.sol, y)

function getdynamicsdual(solver::HPIPMSolver{T}, k) where T
    nx = ocp_qp_dim_get_nx(solver.dim, k)  # next stage
    y = zeros(T, nx)
    getdynamicsdual!(solver, k, y)
    y
end

function getdynamicsduals!(solver::HPIPMSolver, Y) where T 
    for k = 1:solver.dim.N
        getdynamicsdual!(solver, k, Y[k])
    end
    Y
end

function getdynamicsduals(solver::HPIPMSolver{T}) where T 
    Y = map(k->zeros(T,ocp_qp_dim_get_nx(solver.dim, k)), 1:solver.dim.N) 
    getdynamicsduals!(solver, Y)
end

"""
    getstat(solver, stat)

Get one of the stats recorded by the hpipm solver. Valid stats are listed in 
`HPIPM.STATS_INT` and `HPIPM.STATS_FLOAT`.
"""
function getstat(solver::HPIPMSolver, stat::AbstractString)
    found = false
    for (i,stat0) in enumerate(STATS_INT)
        if stat == string(stat0)
            return STATS_INT_METHODS[i](solver.ws)
        end
    end
    for (i,stat0) in enumerate(STATS_FLOAT)
        if stat == string(stat0)
            return STATS_FLOAT_METHODS[i](solver.ws)
        end
    end
    if !found
        @warn "$stat not a recognized stat name."
    end
end

#############################################
## Misc
#############################################

"""
    codegen(solver, filename)

Write the problem data and solver options to a .c file.
"""
function codegen(solver::HPIPMSolver, filename)
    HPIPM.ocp_qp_dim_codegen(filename, "w", solver.dim)
    HPIPM.ocp_qp_codegen(filename, "a", solver.dim, solver.qp)
    HPIPM.ocp_qp_ipm_arg_codegen(filename, "a", solver.dim, solver.arg)
end

