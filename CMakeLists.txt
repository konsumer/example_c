cmake_minimum_required(VERSION 3.15)
project(learn_c C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Default to Debug so binaries always have symbols for gdb/lldb
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

include(FetchContent)

# SDL2 — try system first (brew install sdl2), else fetch
find_package(SDL2 QUIET)
if(NOT SDL2_FOUND)
    FetchContent_Declare(
        SDL2
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG        release-2.28.5
        GIT_SHALLOW    TRUE
    )
    FetchContent_MakeAvailable(SDL2)
endif()

# SDL_bgi — graphics.h BGI API over SDL2
FetchContent_Declare(
    sdl_bgi_src
    URL https://sourceforge.net/projects/sdl-bgi/files/SDL2_bgi-3.0.4.tar.gz/download
)
FetchContent_GetProperties(sdl_bgi_src)
if(NOT sdl_bgi_src_POPULATED)
    FetchContent_Populate(sdl_bgi_src)
endif()

# graphics.h includes <SDL2/SDL2_bgi.h> — stage header into SDL2/ subdir in build tree
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/SDL2)
configure_file(
    ${sdl_bgi_src_SOURCE_DIR}/src/SDL2_bgi.h
    ${CMAKE_CURRENT_BINARY_DIR}/include/SDL2/SDL2_bgi.h
    COPYONLY
)

add_library(sdl_bgi STATIC ${sdl_bgi_src_SOURCE_DIR}/src/SDL2_bgi.c)
target_include_directories(sdl_bgi PUBLIC
    ${sdl_bgi_src_SOURCE_DIR}/src
    ${sdl_bgi_src_SOURCE_DIR}/demo
    ${CMAKE_CURRENT_BINARY_DIR}/include
)
target_link_libraries(sdl_bgi PUBLIC SDL2::SDL2)
# SDL_bgi includes <SDL2/SDL.h> so needs the parent of SDL2's include dir
foreach(_inc_dir ${SDL2_INCLUDE_DIRS})
    get_filename_component(_parent "${_inc_dir}" DIRECTORY)
    target_include_directories(sdl_bgi PUBLIC "${_parent}")
endforeach()

# Regular C examples (src/*.c)
file(GLOB SOURCES "src/*.c")
foreach(SOURCE ${SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE} NAME_WE)
    add_executable(${EXEC_NAME} ${SOURCE})
    target_compile_options(${EXEC_NAME} PRIVATE -Wall -Wextra -Wpedantic)
endforeach()

# Graphics examples (src/graphics/*.c) — use graphics.h via SDL_bgi
file(GLOB GRAPHICS_SOURCES "src/graphics/*.c")
foreach(SOURCE ${GRAPHICS_SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE} NAME_WE)
    add_executable(${EXEC_NAME} ${SOURCE})
    target_link_libraries(${EXEC_NAME} PRIVATE sdl_bgi)
endforeach()
