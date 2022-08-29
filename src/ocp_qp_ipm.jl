mutable struct ocp_qp_ipm_arg
    mu0::Cdouble
    alpha_min::Cdouble
    res_g_max::Cdouble
    res_b_max::Cdouble
    res_d_max::Cdouble
    res_m_max::Cdouble
    reg_prim::Cdouble
    lam_min::Cdouble
    t_min::Cdouble
    tau_min::Cdouble
    iter_max::Cint
    stat_max::Cint
    pred_corr::Cint
    cond_pred_corr::Cint
    itref_pre_max::Cint
    itref_corr_max::Cint
    warm_start::Cint
    square_root_alg::Cint
    lq_fact::Cint
    abs_form::Cint
    comp_dual_sol_eq::Cint
    comp_res_exit::Cint
    comp_res_pred::Cint
    split_step::Cint
    var_init_scheme::Cint
    t_lam_min::Cint
    mode::Cint
    memsize::Csize_t
    function ocp_qp_ipm_arg()
        new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        )
    end
end

function ocp_qp_ipm_arg_strsize()
    ccall(("d_ocp_qp_ipm_arg_strsize", libhpipm), Csize_t, ())
end

function ocp_qp_ipm_arg_memsize(dim::ocp_qp_dim)
    ccall(("d_ocp_qp_ipm_arg_memsize", libhpipm), Csize_t,
        (Ref{ocp_qp_dim},),
        dim
    )
end

function ocp_qp_ipm_arg_create(dim::ocp_qp_dim, arg::ocp_qp_ipm_arg, memory::Vector{UInt8})
    ccall(("d_ocp_qp_ipm_arg_create", libhpipm), Cvoid,
        (Ref{ocp_qp_dim}, Ref{ocp_qp_ipm_arg}, Ptr{Cvoid}),
        dim, arg, memory
    )
end

function ocp_qp_ipm_arg_set_default(mode::hpipm_mode, arg::ocp_qp_ipm_arg)
    ccall(("d_ocp_qp_ipm_arg_set_default", libhpipm), Cvoid,
        (Cint, Ref{ocp_qp_ipm_arg},),
        mode, Ref(arg)
    )
end

for arg in (
        :alpha_min, :mu0, :tol_stat, :tol_eq, :tol_ineq, :tol_comp, 
        :reg_prim, :lam_min, :t_min, :tau_min
    )
    method = "ocp_qp_ipm_arg_set_" * string(arg)
    @eval function $(Symbol(method))(value, arg::ocp_qp_ipm_arg)
        ccall(($("d_" * method), libhpipm), Cvoid,
            (Ptr{Cdouble}, Ref{ocp_qp_ipm_arg}),
            Ref(Cdouble(value)), Ref(arg)
        )
    end
end
for arg in (
        :iter_max, :warm_start, :pred_corr, :cond_pred_corr, :ric_alg, :comp_dual_sol_eq, :comp_res_pred, 
        :split_step, :var_init_scheme, :t_lam_min
    )
    method = "ocp_qp_ipm_arg_set_" * string(arg)
    @eval function $(Symbol(method))(value, arg::ocp_qp_ipm_arg)
        ccall(($("d_" * method), libhpipm), Cvoid,
            (Ptr{Cint}, Ref{ocp_qp_ipm_arg}),
            Ref(Cint(value)), Ref(arg)
        )
    end
end

function ocp_qp_ipm_arg_codegen(file_name::String, mode::String, qp_dim::ocp_qp_dim, arg::ocp_qp_ipm_arg)
    ccall(("d_ocp_qp_ipm_arg_codegen", libhpipm), Cvoid,
        (Cstring, Cstring, Ref{ocp_qp_dim}, Ref{ocp_qp_ipm_arg}),
        file_name, mode, qp_dim, arg
    )
end

function ocp_qp_ipm_arg_print(qp_dim::ocp_qp_dim, arg::ocp_qp_ipm_arg)
    ccall(("d_ocp_qp_ipm_arg_print", libhpipm), Cvoid,
        (Ref{ocp_qp_dim}, Ref{ocp_qp_ipm_arg}),
        qp_dim, arg
    )
end

mutable struct ocp_qp_ipm_ws
    qp_res::NTuple{4,Cdouble}
    core_workspace::Ptr{Cvoid}
    dim::Ptr{Cvoid}
    res_workspace::Ptr{Cvoid}
    sol_step::Ptr{Cvoid}
    sol_itref::Ptr{Cvoid}
    qp_step::Ptr{Cvoid}
    qp_itref::Ptr{Cvoid}
    res_itref::Ptr{Cvoid}
    res::Ptr{Cvoid}
    Gamma::Ptr{Cvoid}
    gamma::Ptr{Cvoid}
    tmp_nuxM::Ptr{Cvoid}
    tmp_nbgM::Ptr{Cvoid}
    tmp_nsM::Ptr{Cvoid}
    Pb::Ptr{Cvoid}
    Zs_inv::Ptr{Cvoid}
    tmp_m::Ptr{Cvoid}
    l::Ptr{Cvoid}
    L::Ptr{Cvoid}
    Ls::Ptr{Cvoid}
    P::Ptr{Cvoid}
    Lh::Ptr{Cvoid}
    AL::Ptr{Cvoid}
    lq0::Ptr{Cvoid}
    tmp_nxM_nxM::Ptr{Cvoid}
    stat::Ptr{Cdouble}
    use_hess_fact::Ptr{Cint}
    lq_work0::Ptr{Cvoid}
    iter::Cint
    stat_max::Cint
    stat_m::Cint
    use_Pb::Cint
    status::Cint
    square_root_alg::Cint
    lq_fact::Cint
    mask_contr::Cint
    valid_ric_vec::Cint
    valid_ric_p::Cint
    memsize::Csize_t
    function ocp_qp_ipm_ws()
        new((0.0,0.0,0.0,0.0), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(),
            Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cdouble}(), Ptr{Cint}(),
            Ptr{Cvoid}(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
        )
    end
end

function ocp_qp_ipm_ws_strsize()
    ccall(("d_ocp_qp_ipm_ws_strsize", libhpipm), Csize_t, ())
end

function ocp_qp_ipm_ws_memsize(dim::ocp_qp_dim, arg::ocp_qp_ipm_arg)
    ccall(("d_ocp_qp_ipm_ws_memsize", libhpipm), Csize_t,
        (Ref{ocp_qp_dim},Ref{ocp_qp_ipm_arg}),
        Ref(dim), Ref(arg)
    )
end

function ocp_qp_ipm_ws_create(dim::ocp_qp_dim, arg::ocp_qp_ipm_arg, ws::ocp_qp_ipm_ws, memory::Vector{UInt8})
    ccall(("d_ocp_qp_ipm_ws_create", libhpipm), Cvoid,
        (Ref{ocp_qp_dim}, Ref{ocp_qp_ipm_arg}, Ref{ocp_qp_ipm_ws}, Ptr{Cvoid}),
        Ref(dim), Ref(arg), Ref(ws), memory
    )
end
