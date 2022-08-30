mutable struct ocp_qp{T}
    dim::Ptr{ocp_qp_dim}
    BAbt::Ptr{Cvoid}
    RSQrq::Ptr{Cvoid}
    DCt::Ptr{Cvoid}
    b::Ptr{Cvoid}
    rqz::Ptr{Cvoid}
    d::Ptr{Cvoid}
    d_mask::Ptr{Cvoid}
    m::Ptr{Cvoid}
    Z::Ptr{Cvoid}
    idxb::Ptr{Ptr{Int}}
    idxs_rev::Ptr{Ptr{Int}}
    idxe::Ptr{Ptr{Int}}
    diag_H_flag::Ptr{Int}
    memsize::Csize_t
    function ocp_qp(::Type{T}=Float64) where T
        new{T}(Ptr{ocp_qp_dim}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), Ptr{Cvoid}(), 
            Ptr{Ptr{Int}}(), Ptr{Ptr{Int}}(), Ptr{Ptr{Int}}(), Ptr{Int}(), 0
        )
    end
end

function ocp_qp_strsize()
    ccall(("d_ocp_qp_strsize", libhpipm), Csize_t, ())
end

function ocp_qp_memsize(dim::ocp_qp_dim)
    ccall(("d_ocp_qp_memsize", libhpipm), Csize_t,
        (Ref{ocp_qp_dim},),
        dim
    )
end

function ocp_qp_create(dim::ocp_qp_dim, qp::ocp_qp{Cdouble}, memory::Vector{UInt8})
    ccall(("d_ocp_qp_create", libhpipm), Cvoid,
        (Ref{ocp_qp_dim}, Ref{ocp_qp}, Ptr{Cvoid}),
        dim, qp, memory
    )
end

function ocp_qp_set_all(A, B, b, Q, S, R, q, r, idxbx, lbx, ubx, idxbu, lbu, ubu, C, D, lg, 
        ug, Zl, Zu, zl, zu, idxs, ls, us, qp)
    ccall(("d_ocp_qp_set_all", libhpipm), Cvoid,
        (Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},     # A,B,b
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},  # Q,S,R
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # q, r,
            Ref{Ptr{Cint}},                                                 # idxbx
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # lbx, ubx
            Ref{Ptr{Int}},                                                  # idxbu
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # lbu, ubu
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # C, D 
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # lg, ug 
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # Zl, Zu 
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # zl, zu 
            Ref{Ptr{Int}},                                                  # idxs
            Ref{Ptr{Cdouble}}, Ref{Ptr{Cdouble}},                        # ls, us 
            Ref{ocp_qp}
        ),
        A, B, b, Q, S, R, q, r, idxbx, lbx, ubx, idxbu, lbu, ubu, C, D, lg, ug, Zl, Zu, 
        zl, zu, idxs, ls, us, qp
    )
end

function ocp_qp_codegen(file_name::String, mode::String, qp_dim::ocp_qp_dim, qp::ocp_qp)
    ccall(("d_ocp_qp_codegen", libhpipm), Cvoid,
        (Cstring, Cstring, Ref{ocp_qp_dim}, Ref{ocp_qp}),
        file_name, mode, qp_dim, qp
    )
end

function ocp_qp_print(qp_dim::ocp_qp_dim, qp::ocp_qp)
    ccall(("d_ocp_qp_print", libhpipm), Cvoid,
        (Ref{ocp_qp_dim}, Ref{ocp_qp}),
        qp_dim, qp 
    )
end

function ocp_qp_set_all_zero(qp::ocp_qp)
    ccall(("d_ocp_qp_set_all_zero", libhpipm), Cvoid, (Ref{ocp_qp},), qp)
end

for field in (:A, :B, :b, :Q, :S, :R, :q, :r, :lb, :ub, :lbx, :ubx, :lbu, :ubu, :C, :D, 
        :lg, :ug)
    method = "ocp_qp_set_" * string(field)
    @eval function $(Symbol(method * "!"))(stage::Integer, mat::Array{Cdouble}, qp::ocp_qp)
        ccall(($("d_" * method), libhpipm), Cvoid,
            (Cint, Ref{Cdouble}, Ref{ocp_qp}),
            stage, mat, qp
        )
    end
end

for field in (:idxbx, :idxbu)
    method = "ocp_qp_set_" * string(field)
    @eval function $(Symbol(method * "!"))(stage::Integer, mat::Array{Cint}, qp::ocp_qp)
        ccall(($("d_" * method), libhpipm), Cvoid,
            (Cint, Ref{Cint}, Ref{ocp_qp}),
            stage, mat, qp
        )
    end
end
