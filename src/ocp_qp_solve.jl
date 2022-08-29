function ocp_qp_ipm_solve(qp::ocp_qp, qp_sol::ocp_qp_sol, arg::ocp_qp_ipm_arg, 
        workspace::ocp_qp_ipm_ws)
    ccall(("d_ocp_qp_ipm_solve", libhpipm), Cvoid,
        (Ref{ocp_qp}, Ref{ocp_qp_sol}, Ref{ocp_qp_ipm_arg}, Ref{ocp_qp_ipm_ws}),
        qp, qp_sol, arg, workspace
    )
end

function ocp_qp_ipm_get_status(ws::ocp_qp_ipm_ws)
    status = Cint(0)
    ref = Ref(status)
    ccall(("d_ocp_qp_ipm_get_status", libhpipm), Cvoid,
        (Ref{ocp_qp_ipm_ws}, Ref{Cint}),
        Ref(ws), ref 
    )
    return HPIPM.hpipm_status(ref[])
end

# function ocp_qp_ipm_get_iter(ws::ocp_qp_ipm_ws)
#     val = Cint(0)
#     rval = Ref(val)
#     ccall(("d_ocp_qp_ipm_get_iter", libhpipm), Cvoid,
#         (Ref{ocp_qp_ipm_ws}, Ptr{Cint}),
#         Ref(ws), rval 
#     )
#     println(rval)
#     println(rval[])
#     return rval[]
# end

# function ocp_qp_ipm_get_obj(ws::ocp_qp_ipm_ws)
#     val = zero(Cdouble)
#     rval = Ref(val)
#     ccall(("d_ocp_qp_ipm_get_obj", libhpipm), Cvoid,
#         (Ref{ocp_qp_ipm_ws}, Ref{Cdouble}),
#         Ref(ws), rval 
#     )
#     return rval[]
# end

for field in (:stat_m, :iter)
    method = "ocp_qp_ipm_get_" * string(field)
    @eval function $(Symbol(method))(ws::ocp_qp_ipm_ws)
        val = zero(Cint)
        rval = Ref(val)
        ccall(($("d_" * method), libhpipm), Cvoid, (Ref{ocp_qp_ipm_ws}, Ref{Cint}), ws, rval)
        return rval[]
    end
end

for field in (:max_res_stat, :max_res_eq, :max_res_ineq, :max_res_comp, :obj)
    method = "ocp_qp_ipm_get_" * string(field)
    @eval function $(Symbol(method))(ws::ocp_qp_ipm_ws)
        val = zero(Cdouble)
        rval = Ref(val)
        ccall(($("d_" * method), libhpipm), Cvoid, (Ref{ocp_qp_ipm_ws}, Ref{Cdouble}), ws, rval)
        return rval[]
    end
end
