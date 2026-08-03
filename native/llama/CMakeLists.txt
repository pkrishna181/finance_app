cmake_minimum_required(VERSION 3.16)
project(arth_llm C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

if(NOT DEFINED LLAMA_CPP_DIR)
    set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vendor/llama.cpp")
endif()

if(NOT EXISTS "${LLAMA_CPP_DIR}/CMakeLists.txt")
    message(FATAL_ERROR "llama.cpp not found at ${LLAMA_CPP_DIR}. Run build_android.sh or build_ios.sh first.")
endif()

set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

add_subdirectory(${LLAMA_CPP_DIR} llama_cpp EXCLUDE_FROM_ALL)

add_library(arth_llm SHARED
    shim/arth_llm.c
)

target_include_directories(arth_llm PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/shim
    ${LLAMA_CPP_DIR}/include
    ${LLAMA_CPP_DIR}/ggml/include
)

target_link_libraries(arth_llm PRIVATE llama)

if(ANDROID)
    target_compile_options(arth_llm PRIVATE -O3)
    # arm64-v8a: enable dotprod / i8mm when available (runtime detection in ggml).
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        target_compile_options(arth_llm PRIVATE -march=armv8.2-a+dotprod+i8mm)
    endif()
endif()

if(APPLE AND CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set_target_properties(arth_llm PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER com.arth.arthllm
    )
endif()

install(TARGETS arth_llm LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)
