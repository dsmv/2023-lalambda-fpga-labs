cmake_minimum_required(VERSION 3.0.0)
project(uart_mic VERSION 0.1.0)

set(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)

add_compile_options(-std=c++14)


add_compile_options(-Wno-write-strings)

include_directories("src/")

file(GLOB_RECURSE SRC_FILES_APP     src/*.c*)

#include_directories(${FASTCGI_INCLUDE_DIRS})

add_executable(uart_mic ${SRC_FILES_APP} )

TARGET_LINK_LIBRARIES(uart_mic rt  )

set(EXECUTABLE_OUTPUT_PATH "../bin")

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)
