cmake_minimum_required(VERSION 3.20)

project(hpipm_jll LANGUAGES C VERSION "0.1")

set(PATH_TO_HPIPM "/home/brian/Code/hpipm/build/install" CACHE STRING "")
set(PATH_TO_BLASFEO "/home/brian/Code/blasfeo/build/install" CACHE STRING "")

add_library(blasfeo STATIC IMPORTED)
set_property(TARGET blasfeo PROPERTY IMPORTED_LOCATION "${PATH_TO_BLASFEO}/lib/libblasfeo.a")
target_include_directories(blasfeo
  INTERFACE
  "${PATH_TO_BLASFEO}/include"
)

add_library(hpipm SHARED IMPORTED)
set_property(TARGET hpipm PROPERTY IMPORTED_LOCATION "${PATH_TO_HPIPM}/lib/libhpipm.so")
target_link_libraries(hpipm
  INTERFACE
  blasfeo
  m
)
target_include_directories(hpipm
  INTERFACE
  "${PATH_TO_HPIPM}/include" 
)

add_library(hpipm_jll
  SHARED
  hpipm_jll.h
  hpipm_jll.c
)
target_link_libraries(hpipm_jll
  PUBLIC
  hpipm
)

add_executable(main
  main.c
)
target_link_libraries(main
  PRIVATE
  hpipm_jll
)

