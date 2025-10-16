set(SOURCES
 XHashAux.h XHashAux.cpp
 Farm.cpp Farm.h
 Miner.h Miner.cpp
)

include_directories(BEFORE ..)

add_library(ethcore ${SOURCES})
target_link_libraries(ethcore PUBLIC devcore xhash::xhash xhash::global-context PRIVATE hwmon)

if(XHASHCL)
  target_link_libraries(ethcore PRIVATE xhash-cl)
endif()
if(XHASHCUDA)
  target_link_libraries(ethcore PUBLIC xhash-cuda)
endif()
if(XHASHCPU)
  target_link_libraries(ethcore PUBLIC xhash-cpu)
endif()
