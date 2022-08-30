using BinaryBuilder
using CMake

curdir = pwd()
cd(@__DIR__)
mkpath("build")
cd("build")
clone_cmd = ```
git clone https://github.com/giaf/blasfeo.git
git clone https://github.com/giaf/hpipm.git 
```

build_cmd = ```
$cmake 
```

cd(curdir)