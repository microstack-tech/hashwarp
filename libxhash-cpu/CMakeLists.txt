file(GLOB sources "*.cpp")
file(GLOB headers "*.h")

add_library(xhash-cpu ${sources} ${headers})
target_link_libraries(xhash-cpu parallaxcore xhash::xhash xhash::global-context Boost::thread)
target_include_directories(xhash-cpu PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR})
