# dependencies

find_package(Threads REQUIRED)

# third-party

include_directories(.)

if (EMSCRIPTEN)
else()
    if (NOT GGML_BACKEND_DL)
        add_subdirectory(vdot)
    endif()
endif()
