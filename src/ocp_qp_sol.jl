mutable struct ocp_qp_sol{T}
    dim::Ptr{ocp_qp_dim}
    ux::Ptr{Cvoid}   # vector
    ppi::Ptr{Cvoid}  # vector
    lam::Ptr{Cvoid}  # vector
    t::Ptr{Cvoid}    # vector
    misc::Ptr{Cvoid}
    memsize::Csize_t
    function ocp_qp_sol(::Type{T}=Float64) where T
        new{T}(
            Ptr{ocp_qp_dim}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Cvoid}(), 0
        )
    end
end

function ocp_qp_sol_strsize()
    ccall(("d_ocp_qp_sol_strsize", libhpipm), Csize_t, ())
end

function ocp_qp_sol_memsize(dim::ocp_qp_dim)
    ccall(("d_ocp_qp_sol_memsize", libhpipm), Csize_t,
        (Ref{ocp_qp_dim},),
        dim
    )
end

function ocp_qp_sol_create(dim::ocp_qp_dim, qp::ocp_qp_sol{Cdouble}, memory::Vector{UInt8})
    ccall(("d_ocp_qp_sol_create", libhpipm), Cvoid,
        (Ref{ocp_qp_dim}, Ref{ocp_qp_sol{Cdouble}}, Ptr{Cvoid}),
        dim, qp, memory
    )
end

function ocp_qp_sol_get_u(stage, qp_sol, vec::Vector{Cdouble})
    ccall(("d_ocp_qp_sol_get_u", libhpipm), Cvoid,
        (Cint, Ref{ocp_qp_sol}, Ref{Cdouble}),
        stage, qp_sol, vec
    )
end

function ocp_qp_sol_get_x(stage, qp_sol, vec::Vector{Cdouble})
    ccall(("d_ocp_qp_sol_get_x", libhpipm), Cvoid,
        (Cint, Ref{ocp_qp_sol}, Ref{Cdouble}),
        stage, qp_sol, vec
    )
end

function ocp_qp_sol_get_pi(stage, qp_sol, vec::Vector{Cdouble})
    ccall(("d_ocp_qp_sol_get_pi", libhpipm), Cvoid,
        (Cint, Ref{ocp_qp_sol}, Ref{Cdouble}),
        stage, qp_sol, vec
    )
end