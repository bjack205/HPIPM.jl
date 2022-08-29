mutable struct ocp_qp_dim
    nx::Ptr{Cint}
    nu::Ptr{Cint}
    nb::Ptr{Cint}    # number of (two-sided) box constraints
    nbx::Ptr{Cint}   # number of (two-sided) state box constraints
    nbu::Ptr{Cint}   # number of (two-sided) input box constraints
    ng::Ptr{Cint}    # number of (two-sided) general constraints
    ns::Ptr{Cint}    # number of soft constraints
    nsbx::Ptr{Cint}  # number of (two-sided) soft state box constraints
    nsbu::Ptr{Cint}  # number of (two-sided) soft input box constraints
    nsg::Ptr{Cint}   # number of (two-sided) soft general constraints
    nbxe::Ptr{Cint}  # number of state box constraints which are equality 
    nbue::Ptr{Cint}  # number of input box constraints which are equality 
    nge::Ptr{Cint}   # number of general constraints which are equality 
    N::Cint             # horizon length
    memsize::Csize_t
end
function ocp_qp_dim()
    ocp_qp_dim(Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), 
        Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), Ptr{Cint}(), 
        Ptr{Cint}(), 0, 0 
    ) 
end

function ocp_qp_dim_strsize()
    ccall(("d_ocp_qp_dim_strsize", libhpipm), Csize_t,()) 
end

function ocp_qp_dim_memsize(N)
    ccall(("d_ocp_qp_dim_memsize", libhpipm), Csize_t,
        (Cint,),
        N
    ) 
end

function ocp_qp_dim_create(N, qp_dim::ocp_qp_dim, memory::Vector{UInt8})
    ccall(("d_ocp_qp_dim_create", libhpipm), Cvoid,
        (Cint, Ref{ocp_qp_dim}, Ref{UInt8}),
        N, Ref(qp_dim), memory
    )
end

function ocp_qp_dim_set_all(nx, nu, nbx, nbu, ng, nsbx, nsbu, nsg, dim::ocp_qp_dim)
    ccall(("d_ocp_qp_dim_set_all", libhpipm), Cvoid,
        (Ref{Cint}, Ref{Cint}, Ref{Cint}, Ref{Cint}, Ref{Cint}, Ref{Cint}, Ref{Cint}, 
            Ref{Cint}, Ref{ocp_qp_dim}),
        nx, nu, nbx, nbu, ng, nsbx, nsbu, nsg, Ref(dim),
    )  
end

function ocp_qp_dim_codegen(file_name::String, mode::String, qp_dim::ocp_qp_dim)
    ccall(("d_ocp_qp_dim_codegen", libhpipm), Cvoid,
        (Cstring, Cstring, Ref{ocp_qp_dim}),
        file_name, mode, qp_dim
    )
end

function ocp_qp_dim_print(qp_dim::ocp_qp_dim)
    ccall(("d_ocp_qp_dim_print", libhpipm), Cvoid,
        (Ref{ocp_qp_dim},),
        qp_dim
    )
end