function greet()
    ccall(("greet", libhpipm_jll), Cvoid, ())
end

function create_ocp_qp_dim(N)
    ccall(("create_ocp_qp_dim", libhpipm_jll), Cvoid, (Cint,), N)
end