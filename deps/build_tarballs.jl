using BinaryBuilder, Pkg

version = v"0.1.3"

sources = [
    GitSource(
        "https://github.com/giaf/blasfeo.git",
        "386e6556ce643e9863458c2479192de4c9689b81",
    ),
    GitSource(
        "https://github.com/giaf/hpipm.git",
        "9fa4c1f976bd6f057db1fd0e264ff74de6df71ff"
    ),
]

script = raw"""
cd $WORKSPACE/srcdir/blasfeo
mkdir build
cd build/
echo "Target ="
echo ${target}
echo "MACHTYPE = "
echo ${MACHTYPE}
echo ${proc_family}
cmake \
    -D CMAKE_C_FLAGS="-lrt" \
    -D CMAKE_INSTALL_PREFIX=${prefix} \
    -D CMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_SHARED_LIBS=ON \
    -D TARGET=GENERIC \
    -D MF=PANELMAJ \
    -D LA=HIGH_PERFORMANCE \
    ..
cmake --build . --target install -j${nproc}

cd $WORKSPACE/srcdir/hpipm
mkdir build
cd build/
cmake \
    -D CMAKE_C_FLAGS="-lrt" \
    -D CMAKE_INSTALL_PREFIX=${prefix} \
    -D CMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_SHARED_LIBS=ON \
    -D BLASFEO_INCLUDE_DIR=${includedir} \
    -D BLASFEO_PATH=${prefix} \
    -D HPIPM_TESTING=OFF \
    ..
cmake --build . --target install -j${nproc}
"""

# Platforms
platforms = supported_platforms()

# Products
products = [
    LibraryProduct("libblasfeo", :blasfeo),
    LibraryProduct("libhpipm", :hpipm),
]

# Dependencies
dependencies = Dependency[
]

# Build the tarballs
build_tarballs(
    ARGS,
    "HPIPM",
    version,
    sources,
    script,
    platforms,
    products,
    dependencies,
    julia_compat = "1.6"
)