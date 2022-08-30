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
            nbu::Vector{<:Integer}=similar(nu),
            nbx::Vector{<:Integer}=similar(nx),
            ng::Vector{<:Integer}=similar(nx),
        ) where T
        N = length(nx) - 1

        # QP dim
        dim_size = ocp_qp_dim_memsize(N)
        dim_mem = zeros(UInt8, dim_size)
        dim = ocp_qp_dim()
        ocp_qp_create(N, dim, dim_mem)
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
        ocp_qp_sol_create(dim, qp, sol_mem)

        # IPM Arg
        ipm_arg_size = ocp_qp_ipm_arg_memsize(dim)
        ipm_arg_mem = zeros(UInt8, ipm_arg_size)
        arg = ocp_qp_ipm()
        ocp_qp_ipm_arg_create(dim, arg, ipm_arg_mem)
        ocp_qp_ipm_arg_set_default(SPEED, arg)

        # IPM workspace
        ipm_size = ocp_qp_ipm_ws_memsize(dim, arg)
        ipm_mem = zeros(UInt8, ipm_size)
        workspace = ocp_qp_ipm_ws()
        ocp_qp_ipm_ws_create(dim, arg, workspace, ipm_mem)

        new{T}(dim, qp, sol, arg, ws, 
            dim_mem, qp_mem, sol_mem, arg_mem, ws_mem, N)
    end
end

function set_dynamics!(solver::HPIPMSolver, A, B, b, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_A!(k, solver.qp, A)
        ocp_qp_set_B!(k, solver.qp, B)
        ocp_qp_set_b!(k, solver.qp, b)
    end
end

function set_cost!(solver::HPIPMSolver, Q, R, S, q, r, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_A!(k, solver.qp, Q)
        ocp_qp_set_B!(k, solver.qp, R)
        ocp_qp_set_b!(k, solver.qp, S)
        ocp_qp_set_b!(k, solver.qp, q)
        ocp_qp_set_b!(k, solver.qp, r)
    end
end

function set_state_bound!(solver::HPIPMSolver, lb, ub, idx, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_lbx!(k, solver.qp, lb)
        ocp_qp_set_ubx!(k, solver.qp, ub)
        ocp_qp_set_idxbx!(k, solver.qp, idx)
    end
end

function set_input_bound!(solver::HPIPMSolver, lb, ub, idx, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_lbu!(k, solver.qp, lb)
        ocp_qp_set_ubu!(k, solver.qp, ub)
        ocp_qp_set_idxbu!(k, solver.qp, idx)
    end
end

function set_constraint!(solver::HPIPMSolver, C, D, lb, ub, kstart, kstop=kstart)
    for k = kstart:kstop
        ocp_qp_set_C!(k, solver.qp, C)
        ocp_qp_set_D!(k, solver.qp, D)
        ocp_qp_set_lg!(k, solver.qp, lb)
        ocp_qp_set_ug!(k, solver.qp, ub)
    end
end

for field in (:A, :B, :b, :Q, :S, :R, :q, :r, :lb, :ub, :lbx, :ubx, :lbu, :ubu, :C, :D, 
        :lg, :ug, :idxbx, :idxbu)
    method = "set_$(field)!"
    @eval function $(Symbol(method))(solver::HPIPMSolver, mats::AbstractVector{<:AbstractArray})
        for stage in eachindex(mats)
            set_A!(solver, mats[stage], stage)
        end
    end

    @eval function $(Symbol(method))(solver::HPIPMSolver, mat::AbstractArray, stage)
        ocp_qp_set_A(stage, solver.qp, mat)
    end
end




