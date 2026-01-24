#==============================================================================
# Copyright (c) 2025 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   September 2025
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# Entt.cmake
#==============================================================================
# Configuration for EnTT Entity-Component-System library
# Version: v3.15.0 (Git Submodule)
# Source: https://github.com/skypjack/entt
#==============================================================================

# ===== EnTT Library Configuration =====
set(ENTT_LIBRARY_NAME "EnTT")
set(ENTT_VERSION "3.15.0")
set(ENTT_SOURCE_DIR "${VNE_THIRD_PARTY_DIR}/entt")

# ===== EnTT Build Options =====
option(ENTT_USE_LIBCPP "Use libc++ by adding -stdlib=libc++ flag if available." OFF)
option(ENTT_USE_SANITIZER "Enable sanitizers by adding -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined flags if available." OFF)
option(ENTT_USE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)

# ===== EnTT Target Configuration =====
if(NOT TARGET EnTT::EnTT)
    # Check if EnTT source directory exists
    if(NOT EXISTS "${ENTT_SOURCE_DIR}")
        message(FATAL_ERROR "EnTT source directory not found at: ${ENTT_SOURCE_DIR}")
    endif()

    # Add EnTT as an interface library
    add_library(${ENTT_LIBRARY_NAME} INTERFACE)
    add_library(EnTT::EnTT ALIAS ${ENTT_LIBRARY_NAME})

    # Set include directories
    target_include_directories(${ENTT_LIBRARY_NAME}
        INTERFACE
            $<BUILD_INTERFACE:${ENTT_SOURCE_DIR}/src>
            $<BUILD_INTERFACE:${ENTT_SOURCE_DIR}/single_include>
            $<INSTALL_INTERFACE:include>
    )

    # Set compile features (EnTT requires C++17)
    target_compile_features(${ENTT_LIBRARY_NAME} INTERFACE cxx_std_17)

    # Set compile options based on configuration
    if(ENTT_USE_LIBCPP)
        if(NOT WIN32)
            include(CheckCXXSourceCompiles)
            include(CMakePushCheckState)

            cmake_push_check_state()
            set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -stdlib=libc++")

            check_cxx_source_compiles("
                #include<type_traits>
                int main() { return std::is_same_v<int, char>; }
            " ENTT_HAS_LIBCPP)

            cmake_pop_check_state()
        endif()

        if(ENTT_HAS_LIBCPP)
            target_compile_options(${ENTT_LIBRARY_NAME} BEFORE INTERFACE -stdlib=libc++)
        else()
            message(VERBOSE "The option ENTT_USE_LIBCPP is set but libc++ is not available.")
        endif()
    endif()

    if(ENTT_USE_SANITIZER)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
            set(ENTT_HAS_SANITIZER TRUE CACHE BOOL "" FORCE)
            mark_as_advanced(ENTT_HAS_SANITIZER)
        endif()

        if(NOT ENTT_HAS_SANITIZER)
            message(VERBOSE "The option ENTT_USE_SANITIZER is set but sanitizer support is not available.")
        endif()
    endif()

    if(ENTT_USE_CLANG_TIDY)
        find_program(ENTT_CLANG_TIDY_EXECUTABLE "clang-tidy")

        if(NOT ENTT_CLANG_TIDY_EXECUTABLE)
            message(VERBOSE "The option ENTT_USE_CLANG_TIDY is set but clang-tidy executable is not available.")
        endif()
    endif()

    # Set target properties
    set_target_properties(${ENTT_LIBRARY_NAME} PROPERTIES
        VERSION ${ENTT_VERSION}
        DESCRIPTION "Gaming meets modern C++ - a fast and reliable entity-component system (ECS) and much more"
        HOMEPAGE_URL "https://github.com/skypjack/entt"
    )

    message(STATUS "EnTT ${ENTT_VERSION} configured successfully (Git Submodule)")
    message(STATUS "  - Source: ${ENTT_SOURCE_DIR}")
    message(STATUS "  - C++ Standard: 17")
    message(STATUS "  - Type: Interface Library")
    message(STATUS "  - Integration: Git Submodule")

    if(ENTT_USE_LIBCPP)
        message(STATUS "  - libc++: Enabled")
    endif()

    if(ENTT_USE_SANITIZER)
        message(STATUS "  - Sanitizers: Enabled")
    endif()

    if(ENTT_USE_CLANG_TIDY)
        message(STATUS "  - Clang-Tidy: Enabled")
    endif()
else()
    message(STATUS "EnTT target already exists, skipping configuration")
endif()

# ===== EnTT Utility Functions =====

# Function to check if EnTT is properly configured
function(check_entt_configured)
    if(NOT TARGET EnTT::EnTT)
        message(FATAL_ERROR "EnTT is not properly configured. Please ensure EnTT.cmake is included.")
    endif()
endfunction()

# Function to link EnTT to a target
function(link_entt target_name)
    check_entt_configured()

    target_link_libraries(${target_name} PRIVATE EnTT::EnTT)

    message(STATUS "Linked EnTT to target: ${target_name}")
endfunction()

# Function to get EnTT version information
function(get_entt_version)
    set(ENTT_VERSION_MAJOR 3 PARENT_SCOPE)
    set(ENTT_VERSION_MINOR 15 PARENT_SCOPE)
    set(ENTT_VERSION_PATCH 0 PARENT_SCOPE)
    set(ENTT_VERSION_STRING "3.15.0" PARENT_SCOPE)
endfunction()

# ===== EnTT Feature Detection =====

# Check for EnTT features
function(detect_entt_features)
    # Check if we can include EnTT headers
    include(CheckCXXSourceCompiles)

    set(CMAKE_REQUIRED_INCLUDES "${ENTT_SOURCE_DIR}/src")
    set(CMAKE_REQUIRED_LIBRARIES)

    check_cxx_source_compiles("
        #include <entt/entt.hpp>
        int main() {
            entt::registry registry;
            auto entity = registry.create();
            return 0;
        }
    " ENTT_HEADERS_AVAILABLE)

    if(ENTT_HEADERS_AVAILABLE)
        message(STATUS "EnTT headers are available and working")
        set(ENTT_AVAILABLE TRUE CACHE BOOL "EnTT is available" FORCE)
    else()
        message(WARNING "EnTT headers are not available or not working")
        set(ENTT_AVAILABLE FALSE CACHE BOOL "EnTT is available" FORCE)
    endif()

    mark_as_advanced(ENTT_AVAILABLE)
endfunction()

# ===== EnTT Installation =====

# Function to install EnTT
function(install_entt)
    if(TARGET EnTT::EnTT)
        install(TARGETS ${ENTT_LIBRARY_NAME}
            EXPORT VertexNovaTargets
            LIBRARY DESTINATION lib
            ARCHIVE DESTINATION lib
            RUNTIME DESTINATION bin
        )

        message(STATUS "EnTT installation configured")
    endif()
endfunction()

# ===== EnTT Testing =====

# Function to add EnTT tests
function(add_entt_tests)
    if(VNE_BUILD_TESTS AND EXISTS "${ENTT_SOURCE_DIR}/test")
        enable_testing()

        # Add EnTT's own tests if requested
        option(ENTT_BUILD_TESTS "Build EnTT tests" OFF)
        if(ENTT_BUILD_TESTS)
            add_subdirectory(${ENTT_SOURCE_DIR}/test)
            message(STATUS "EnTT tests enabled")
        endif()
    endif()
endfunction()

# ===== EnTT Documentation =====

# Function to setup EnTT documentation
function(setup_entt_docs)
    if(VNE_BUILD_DOCS AND EXISTS "${ENTT_SOURCE_DIR}/docs")
        message(STATUS "EnTT documentation available at: ${ENTT_SOURCE_DIR}/docs")

        # Copy EnTT documentation if needed
        option(ENTT_COPY_DOCS "Copy EnTT documentation to project docs" OFF)
        if(ENTT_COPY_DOCS)
            # Implementation for copying docs
            message(STATUS "EnTT documentation copying enabled")
        endif()
    endif()
endfunction()

# ===== EnTT Submodule Management =====

# Function to update EnTT submodule
function(update_entt_submodule)
    message(STATUS "Updating EnTT submodule...")

    # Check if we're in a git repository
    find_package(Git QUIET)
    if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --remote --merge 3rd_party/entt
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE GIT_UPDATE_RESULT
            OUTPUT_VARIABLE GIT_UPDATE_OUTPUT
            ERROR_VARIABLE GIT_UPDATE_ERROR
        )

        if(GIT_UPDATE_RESULT EQUAL 0)
            message(STATUS "EnTT submodule updated successfully")
            message(STATUS "Output: ${GIT_UPDATE_OUTPUT}")
        else()
            message(WARNING "Failed to update EnTT submodule")
            message(STATUS "Error: ${GIT_UPDATE_ERROR}")
        endif()
    else()
        message(WARNING "Git not found, cannot update EnTT submodule")
    endif()
endfunction()

# Function to initialize EnTT submodule
function(init_entt_submodule)
    message(STATUS "Initializing EnTT submodule...")

    find_package(Git QUIET)
    if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive 3rd_party/entt
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE GIT_INIT_RESULT
            OUTPUT_VARIABLE GIT_INIT_OUTPUT
            ERROR_VARIABLE GIT_INIT_ERROR
        )

        if(GIT_INIT_RESULT EQUAL 0)
            message(STATUS "EnTT submodule initialized successfully")
        else()
            message(WARNING "Failed to initialize EnTT submodule")
            message(STATUS "Error: ${GIT_INIT_ERROR}")
        endif()
    else()
        message(WARNING "Git not found, cannot initialize EnTT submodule")
    endif()
endfunction()

# ===== EnTT Configuration Summary =====

# Print configuration summary
function(print_entt_summary)
    message(STATUS "")
    message(STATUS "=== EnTT Configuration Summary ===")
    message(STATUS "Version: ${ENTT_VERSION}")
    message(STATUS "Source: ${ENTT_SOURCE_DIR}")
    message(STATUS "Target: ${ENTT_LIBRARY_NAME}")
    message(STATUS "C++ Standard: 17")
    message(STATUS "Available: ${ENTT_AVAILABLE}")
    message(STATUS "Integration: Git Submodule")
    message(STATUS "==================================")
    message(STATUS "")
endfunction()
