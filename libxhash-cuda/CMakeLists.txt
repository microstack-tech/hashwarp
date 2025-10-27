find_package(CUDAToolkit REQUIRED)

# Enable CUDA as a language and set standard
enable_language(CUDA)
set(CMAKE_CUDA_STANDARD 11)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# Allow users to specify CUDA arch list; default to RTX 40xx (SM89) for modern toolchains
set(XHASH_CUDA_ARCHS "89" CACHE STRING "CUDA SM architectures to build for (e.g. 75;86;89).")

# Collect sources
file(GLOB sources "*.cpp" "*.cu")
file(GLOB headers "*.h" "*.cuh")

# Library target
add_library(xhash-cuda STATIC ${sources} ${headers})

# Base CUDA compile options
set(_cuda_base_opts "--ptxas-options=-v" "-use_fast_math")
if (NOT MSVC)
  list(APPEND _cuda_base_opts "--disable-warnings")
endif()

# Prefer modern CMake CUDA architectures property
if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
  # Set target architectures; accepts list like "86;89"
  # Users can override with -DXHASH_CUDA_ARCHS=...
  set_property(TARGET xhash-cuda PROPERTY CUDA_ARCHITECTURES ${XHASH_CUDA_ARCHS})
else()
  # Legacy fallback: emit -gencode for requested archs
  set(_cuda_arch_flags)
  foreach(sm ${XHASH_CUDA_ARCHS})
    list(APPEND _cuda_arch_flags "-gencode" "arch=compute_${sm},code=sm_${sm}")
  endforeach()
  target_compile_options(xhash-cuda PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:${_cuda_arch_flags}>)
endif()

target_compile_options(xhash-cuda PRIVATE
  $<$<COMPILE_LANGUAGE:CUDA>:${_cuda_base_opts}>
  $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:-O3>
  $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-G>
)

target_link_libraries(xhash-cuda
  PRIVATE
    parallaxcore
    xhash::xhash
    Boost::thread
    CUDA::cudart
)

target_include_directories(xhash-cuda PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR} ${CUDAToolkit_INCLUDE_DIRS})
