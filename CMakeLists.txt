cmake_minimum_required(VERSION 3.15)
project(learn_c C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Default to Debug so binaries always have symbols for gdb/lldb
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# Collect all .c files in src/ automatically — add new files there, no CMake edits needed
file(GLOB SOURCES "src/*.c")

foreach(SOURCE ${SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE} NAME_WE)
    add_executable(${EXEC_NAME} ${SOURCE})
    target_compile_options(${EXEC_NAME} PRIVATE -Wall -Wextra -Wpedantic)
endforeach()
