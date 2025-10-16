file(GLOB sources "*.cpp")
file(GLOB headers "*.h")

add_library(xhash-cpu ${sources} ${headers})
#target_link_libraries(xhash-cpu ethcore Boost::fiber Boost::thread)
target_link_libraries(xhash-cpu ethcore xhash::xhash xhash::global-context Boost::thread)
target_include_directories(xhash-cpu PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR})
