set(SOURCES
 XHashAux.h XHashAux.cpp
 Farm.cpp Farm.h
 Miner.h Miner.cpp
)

include_directories(BEFORE ..)

add_library(parallaxcore ${SOURCES})
target_link_libraries(parallaxcore PUBLIC devcore xhash::xhash xhash::global-context PRIVATE hwmon)

if(XHASHCL)
  target_link_libraries(parallaxcore PRIVATE xhash-cl)
endif()
if(XHASHCUDA)
  target_link_libraries(parallaxcore PUBLIC xhash-cuda)
endif()
if(XHASHCPU)
  target_link_libraries(parallaxcore PUBLIC xhash-cpu)
endif()
