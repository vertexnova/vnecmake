#==============================================================================
# Copyright (c) 2024 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   May-2024
#
# Autodoc:   yes
#==============================================================================

find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    # Update submodules as needed
    option(GIT_SUBMODULE "Check submodules during build" ON)
    if(GIT_SUBMODULE)
        message(STATUS "Submodule update")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        RESULT_VARIABLE GIT_SUBMOD_RESULT)
        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(FATAL_ERROR "git submodule update --init --recursive failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
        endif()
    endif()
endif()

# Check all the submodules with platform-specific requirements

# Core submodules (required on all platforms)
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/glm/CMakeLists.txt")
    message(FATAL_ERROR "The GLM submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
endif()

if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/googletest/CMakeLists.txt")
    message(FATAL_ERROR "The GOOGLETEST submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
endif()

if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/stb_image/CMakeLists.txt")
    message(FATAL_ERROR "The STB_IMAGE submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
endif()

# Desktop platform submodules (Windows, Linux, macOS)
if(VNE_TARGET_PLATFORM IN_LIST DESKTOP_PLATFORMS)
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/glfw/CMakeLists.txt")
        message(FATAL_ERROR "The GLFW submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()

    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/spdlog/CMakeLists.txt")
        message(FATAL_ERROR "The SPDLOG submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()

    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/glad/src/glad.c")
        message(FATAL_ERROR "The GLAD submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()
endif()

# ImGui submodule (available on all platforms)
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/imgui/imgui.h")
    message(FATAL_ERROR "The IMGUI submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
endif()

# Apple platform submodules (macOS, iOS)
if(VNE_TARGET_PLATFORM IN_LIST APPLE_PLATFORMS)
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/metal-cpp/Metal/Metal.hpp")
        message(FATAL_ERROR "The METAL-CPP submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()

    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/moltenvk/CMakeLists.txt")
        message(FATAL_ERROR "The MOLTENVK submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()
endif()

# Web platform submodules
if(VNE_TARGET_PLATFORM STREQUAL "Web")
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/emsdk/emsdk")
        message(FATAL_ERROR "The EMSDK submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()
endif()

# Vulkan support (Windows, Linux, macOS, iOS, Android)
if(VNE_TARGET_PLATFORM IN_LIST WINDOWS_LINUX_PLATFORMS OR VNE_TARGET_PLATFORM IN_LIST APPLE_PLATFORMS OR VNE_TARGET_PLATFORM STREQUAL "Android")
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/vulkan-headers/include/vulkan/vulkan.h")
        message(FATAL_ERROR "The VULKAN-HEADERS submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()

    # Shader compilation support (shaderc for GLSL/HLSL → SPIR-V)
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/shaderc/CMakeLists.txt")
        message(FATAL_ERROR "The SHADERC submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()

    # Sync shaderc dependencies (SPIRV-Tools, glslang, etc.)
    if(EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/shaderc/utils/git-sync-deps")
        # Check if dependencies are already synced
        if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/shaderc/third_party/spirv-tools")
            message(STATUS "Syncing shaderc dependencies (SPIRV-Tools, glslang, etc.)...")
            find_program(PYTHON3_EXECUTABLE python3)
            if(PYTHON3_EXECUTABLE)
                execute_process(
                    COMMAND ${PYTHON3_EXECUTABLE} "${PROJECT_SOURCE_DIR}/3rd_party/shaderc/utils/git-sync-deps"
                    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/3rd_party/shaderc"
                    RESULT_VARIABLE SYNC_RESULT
                    OUTPUT_QUIET
                    ERROR_QUIET
                )
                if(NOT SYNC_RESULT EQUAL "0")
                    message(WARNING "Failed to sync shaderc dependencies. This may cause build errors.")
                else()
                    message(STATUS "Shaderc dependencies synced successfully")
                endif()
            else()
                message(WARNING "Python3 not found - cannot sync shaderc dependencies automatically")
                message(WARNING "Please run: cd 3rd_party/shaderc && python3 utils/git-sync-deps")
            endif()
        else()
            message(STATUS "Shaderc dependencies already synced")
        endif()
    endif()

    # SPIR-V translation support (SPIRV-Cross for SPIR-V → GLSL/MSL)
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/SPIRV-Cross/CMakeLists.txt")
        message(FATAL_ERROR "The SPIRV-CROSS submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
    endif()
endif()

# Qt support (optional, but check if present)
if(EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/qtbase/CMakeLists.txt")
    message(STATUS "Qt submodule found - Qt support will be available")
else()
    message(STATUS "Qt submodule not found - Qt support will be disabled")
endif()

# Zlib support (required for compression)
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rd_party/zlib/CMakeLists.txt")
    message(FATAL_ERROR "The ZLIB submodule was not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
endif()
