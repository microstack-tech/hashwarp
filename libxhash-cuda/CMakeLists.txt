# libxhash-cuda/CMakeLists.txt
cmake_minimum_required(VERSION 3.21)
project(xhash_cuda LANGUAGES CXX CUDA)

find_package(CUDAToolkit REQUIRED)

set(CMAKE_CUDA_STANDARD 11)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# User-selectable SM list (Pascal→Hopper)
set(XHASH_CUDA_ARCHS "60;61;62;70;72;75;80;86;87;89;90"
  CACHE STRING "CUDA SM architectures to build for (e.g. 75;86;89)")

file(GLOB sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/*.cu")
file(GLOB headers CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.h"   "${CMAKE_CURRENT_SOURCE_DIR}/*.cuh")

add_library(xhash-cuda STATIC ${sources} ${headers})

# --- Always prefer native CUDA_ARCHITECTURES path (CMake >= 3.18) ------------
if(CMAKE_VERSION VERSION_LESS 3.18)
  message(FATAL_ERROR "CMake >= 3.18 required for reliable CUDA arch handling.")
endif()
set_property(TARGET xhash-cuda PROPERTY CUDA_ARCHITECTURES "${XHASH_CUDA_ARCHS}")
message(STATUS "xhash-cuda: using CUDA_ARCHITECTURES=${XHASH_CUDA_ARCHS}")

# Base CUDA compile options
set(_cuda_base_opts "--ptxas-options=-v" "-use_fast_math")
if(NOT MSVC)
  list(APPEND _cuda_base_opts "--disable-warnings")
endif()

target_compile_options(xhash-cuda PRIVATE
  $<$<COMPILE_LANGUAGE:CUDA>:${_cuda_base_opts}>
  $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:-O3>
  $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-G>
)

# Host flags for CUDA translation units (wrapped correctly)
if(MSVC)
  target_compile_options(xhash-cuda PRIVATE
    $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/EHsc>
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:-Xcompiler=/O2>
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-Xcompiler=/Zi>
    $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/MD>
  )
endif()

target_include_directories(xhash-cuda
  PRIVATE
    ..
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CUDAToolkit_INCLUDE_DIRS}
)

target_link_libraries(xhash-cuda
  PRIVATE
    parallaxcore
    xhash::xhash
    Boost::thread
    CUDA::cudart
)

set_target_properties(xhash-cuda PROPERTIES POSITION_INDEPENDENT_CODE ON)
