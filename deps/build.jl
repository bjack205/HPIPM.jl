# using BinaryBuilder
# using CMake

curdir = pwd()
cd(@__DIR__)

INSTALLDIR = joinpath(@__DIR__,"install")
BUILDDIR = joinpath(@__DIR__, "build")
# if isdir(BUILDDIR)
#     rm(BUILDDIR, recursive=true, force=true)
# end

mkpath(BUILDDIR)
mkpath(INSTALLDIR)

# Clone Repos
cd(BUILDDIR)
blasfeo_src = joinpath(BUILDDIR, "blasfeo")
hpipm_src = joinpath(BUILDDIR, "hpipm")
if !isdir(blasfeo_src)
    run(`git clone https://github.com/giaf/blasfeo.git`)
end
if !isdir(hpipm_src)
    run(`git clone https://github.com/giaf/hpipm.git`)
end

# Build Blasfeo
cd(BUILDDIR)
mkpath("blasfeo/build")
cd("blasfeo/build")
run(`cmake -D CMAKE_BUILD_TYPE=Release -D LA=HIGH_PERFORMANCE -D TARGET=X64_AUTOMATIC -D CMAKE_INSTALL_PREFIX=$INSTALLDIR ..`)
run(`cmake --build . -j$(Sys.CPU_THREADS)`)
run(`cmake --build . --target=install`)

# Build HPIPM
cd(BUILDDIR)
cd("hpipm")
# rm("build", force=true, recursive=true)
cd(mkpath("build"))
# run(`cmake -D CMAKE_BUILD_TYPE=Release 
#            -D BLASFEO_PATH=$INSTALLDIR
#            -D HPIPM_BLASFEO_LIB=Static 
#            -D BUILD_SHARED_LIBS=ON 
#            -D CMAKE_INSTALL_PREFIX=$INSTALLDIR ..
# `)
# run(`cmake -D CMAKE_BUILD_TYPE=Release -D HPIPM_BLASFEO_LIB=Static -D BLASFEO_PATH=/home/brian/.julia/dev/HPIPM/deps/install -D BUILD_SHARED_LIBS=ON -D CMAKE_INSTALL_PREFIX=$INSTALLDIR ..`)
run(`cmake -D CMAKE_BUILD_TYPE=Release 
           -D HPIPM_BLASFEO_LIB=Static 
           -D BLASFEO_PATH=$INSTALLDIR 
           -D BUILD_SHARED_LIBS=ON 
           -D CMAKE_INSTALL_PREFIX=$INSTALLDIR ..`)
run(`cmake --build . -j$(Sys.CPU_THREADS)`)
run(`cmake --build . --target=install`)
libhpipm = joinpath(INSTALLDIR,"lib","libhpipm.so")

open(joinpath(@__DIR__,"deps.jl"), "w") do f
    write(f, """
    const libhpipm = "$(joinpath(libhpipm))"
    """)
end

cd(curdir)