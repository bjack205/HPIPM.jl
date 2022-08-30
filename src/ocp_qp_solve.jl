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

const STATS_INT = (:stat_m, :iter)
const STATS_FLOAT = (:max_res_stat, :max_res_eq, :max_res_ineq, :max_res_comp, :obj)

for field in STATS_INT
    method = "ocp_qp_ipm_get_" * string(field)
    @eval function $(Symbol(method))(ws::ocp_qp_ipm_ws)
        val = zero(Cint)
        rval = Ref(val)
        ccall(($("d_" * method), libhpipm), Cvoid, (Ref{ocp_qp_ipm_ws}, Ref{Cint}), ws, rval)
        return rval[]
    end
end

for field in STATS_FLOAT
    method = "ocp_qp_ipm_get_" * string(field)
    @eval function $(Symbol(method))(ws::ocp_qp_ipm_ws)
        val = zero(Cdouble)
        rval = Ref(val)
        ccall(($("d_" * method), libhpipm), Cvoid, (Ref{ocp_qp_ipm_ws}, Ref{Cdouble}), ws, rval)
        return rval[]
    end
end

const STATS_FLOAT_METHODS = map(STATS_FLOAT) do arg
    eval(Symbol("ocp_qp_ipm_get_" * string(arg)))
end

const STATS_INT_METHODS = map(STATS_INT) do arg
    eval(Symbol("ocp_qp_ipm_get_" * string(arg)))
end
