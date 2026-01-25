#==============================================================================
# Copyright (c) 2025 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   August-2025
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# DebugConfig.cmake - Standardized Debug Configuration
#==============================================================================

#==============================================================================
# Function: vne_configure_debug_target
#
# Applies standardized debug configuration to a target for proper debugging
# support across all platforms, with special handling for macOS issues.
#
# Parameters:
#   target_name - Name of the CMake target to configure
#
# Features:
#   - Enhanced debug symbol generation (DWARF 4 format)
#   - Disabled optimizations for debug builds
#   - Frame pointer preservation for complete stack traces
#   - LTO disabled for debug builds to preserve symbols
#   - macOS-specific debug enhancements
#
# Usage:
#   vne_configure_debug_target(MyTarget)
#==============================================================================
function(vne_configure_debug_target target_name)
    # Only apply debug configuration for Debug builds
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        message(STATUS "Applying debug configuration to target: ${target_name}")

        # Disable LTO for debug builds to preserve debug symbols (cross-platform)
        # LTO can strip or relocate debug symbols, making debugging difficult
        set_target_properties(${target_name} PROPERTIES
            INTERPROCEDURAL_OPTIMIZATION FALSE
        )

        # Platform and compiler-specific debug flags
        if(MSVC)
            # Windows MSVC compiler
            target_compile_options(${target_name} PRIVATE
                /Zi         # Generate debug information (PDB files)
                /Od         # Disable optimizations
                /Oy-        # Disable frame pointer omission
                /RTC1       # Runtime checks
            )
            target_link_options(${target_name} PRIVATE
                /DEBUG      # Generate debug info for linker
                /INCREMENTAL:NO  # Better debugging experience
            )
            message(STATUS "  Applied Windows MSVC debug configuration")

        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
            # GCC/Clang (Linux, macOS, MinGW)
            target_compile_options(${target_name} PRIVATE
                -g                      # Generate debug information
                -O0                     # Disable optimizations
                -fno-omit-frame-pointer # Preserve frame pointers for stack traces
            )

            # Use DWARF 4 format if supported (check compiler version)
            if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "3.5")
                target_compile_options(${target_name} PRIVATE -gdwarf-4)
                target_link_options(${target_name} PRIVATE -gdwarf-4)
            elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.5")
                target_compile_options(${target_name} PRIVATE -gdwarf-4)
                target_link_options(${target_name} PRIVATE -gdwarf-4)
            else()
                # Fallback to default debug format
                target_link_options(${target_name} PRIVATE -g)
            endif()

            message(STATUS "  Applied GCC/Clang debug configuration")

        else()
            # Unknown compiler - apply basic flags
            target_compile_options(${target_name} PRIVATE -g -O0)
            message(STATUS "  Applied basic debug configuration for unknown compiler")
        endif()

        # Platform-specific debug enhancements
        if(APPLE)
            # macOS-specific debug flags for better debugging experience
            if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                target_compile_options(${target_name} PRIVATE
                    -fstandalone-debug     # Standalone debug info (better for debuggers)
                )

                target_link_options(${target_name} PRIVATE
                    -Wl,-no_compact_unwind # Disable compact unwinding for better stack traces
                )
            endif()
            message(STATUS "  Applied macOS-specific debug enhancements")

        elseif(WIN32)
            # Windows-specific debug enhancements
            if(MSVC)
                # Additional MSVC debug options
                target_compile_definitions(${target_name} PRIVATE
                    _DEBUG              # Standard debug macro
                    DEBUG               # Additional debug macro
                )
            endif()
            message(STATUS "  Applied Windows-specific debug enhancements")

        elseif(UNIX)
            # Linux-specific debug enhancements
            if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
                # Additional GCC/Clang debug options for Linux
                target_compile_options(${target_name} PRIVATE
                    -ggdb              # Enhanced GDB debugging info
                )
            endif()
            message(STATUS "  Applied Linux-specific debug enhancements")
        endif()

        message(STATUS "  Debug configuration applied successfully")
    else()
        message(STATUS "Skipping debug configuration for ${target_name} (build type: ${CMAKE_BUILD_TYPE})")
    endif()
endfunction()

#==============================================================================
# Function: vne_configure_debug_target_advanced
#
# Advanced debug configuration with additional options for specialized debugging
#
# Parameters:
#   target_name - Name of the CMake target to configure
#   SANITIZERS - Enable address/undefined behavior sanitizers (optional)
#   COVERAGE - Enable code coverage (optional)
#   VERBOSE_SYMBOLS - Enable verbose debug symbols (optional)
#
# Usage:
#   vne_configure_debug_target_advanced(MyTarget SANITIZERS COVERAGE)
#==============================================================================
function(vne_configure_debug_target_advanced target_name)
    # Parse optional arguments
    set(options SANITIZERS COVERAGE VERBOSE_SYMBOLS)
    cmake_parse_arguments(DEBUG "" "" "${options}" ${ARGN})

    # Apply base debug configuration
    vne_configure_debug_target(${target_name})

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        # Add sanitizers if requested
        if(DEBUG_SANITIZERS)
            if(MSVC)
                # MSVC Address Sanitizer (available in VS 2019 16.9+)
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "19.28")
                    target_compile_options(${target_name} PRIVATE /fsanitize=address)
                    message(STATUS "  Enabled MSVC AddressSanitizer for ${target_name}")
                else()
                    message(WARNING "  MSVC AddressSanitizer requires VS 2019 16.9+ (current: ${CMAKE_CXX_COMPILER_VERSION})")
                endif()
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
                target_compile_options(${target_name} PRIVATE
                    -fsanitize=address
                    -fsanitize=undefined
                    -fno-sanitize-recover=all
                )
                target_link_options(${target_name} PRIVATE
                    -fsanitize=address
                    -fsanitize=undefined
                )
                message(STATUS "  Enabled GCC/Clang sanitizers for ${target_name}")
            else()
                message(WARNING "  Sanitizers not supported for compiler: ${CMAKE_CXX_COMPILER_ID}")
            endif()
        endif()

        # Add coverage if requested
        if(DEBUG_COVERAGE)
            if(MSVC)
                # MSVC doesn't have built-in coverage, suggest external tools
                message(WARNING "  Code coverage for MSVC requires external tools (e.g., OpenCppCoverage)")
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
                target_compile_options(${target_name} PRIVATE --coverage)
                target_link_options(${target_name} PRIVATE --coverage)
                message(STATUS "  Enabled GCC/Clang coverage for ${target_name}")
            else()
                message(WARNING "  Coverage not supported for compiler: ${CMAKE_CXX_COMPILER_ID}")
            endif()
        endif()

        # Add verbose symbols if requested
        if(DEBUG_VERBOSE_SYMBOLS)
            if(MSVC)
                # MSVC verbose debug info
                target_compile_options(${target_name} PRIVATE /Z7)  # Full debug info in obj files
                message(STATUS "  Enabled MSVC verbose debug symbols for ${target_name}")
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
                target_compile_options(${target_name} PRIVATE -g3)  # Maximum debug information
                message(STATUS "  Enabled GCC/Clang verbose debug symbols for ${target_name}")
            else()
                message(WARNING "  Verbose symbols not supported for compiler: ${CMAKE_CXX_COMPILER_ID}")
            endif()
        endif()
    endif()
endfunction()

#==============================================================================
# Function: vne_apply_debug_to_all_targets
#
# Apply debug configuration to all targets in the current directory
# Useful for applying debug config to multiple targets at once
#
# Usage:
#   vne_apply_debug_to_all_targets()
#==============================================================================
function(vne_apply_debug_to_all_targets)
    get_property(targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
    foreach(target ${targets})
        get_target_property(target_type ${target} TYPE)
        if(target_type STREQUAL "EXECUTABLE" OR target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "STATIC_LIBRARY")
            vne_configure_debug_target(${target})
        endif()
    endforeach()
endfunction()
