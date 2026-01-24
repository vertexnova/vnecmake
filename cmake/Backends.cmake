#==============================================================================
# Copyright (c) 2025 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   June 2025
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# Platform Detection and Backend Support
#==============================================================================

# Use existing platform detection from main CMakeLists.txt
if(NOT DEFINED VNE_TARGET_PLATFORM)
    message(FATAL_ERROR "VNE_TARGET_PLATFORM not defined. Please ensure platform detection runs before Backends.cmake")
endif()

# Determine supported backends based on existing platform detection
if(VNE_TARGET_PLATFORM STREQUAL "Windows")
    set(VNE_SUPPORTED_BACKENDS "OpenGL;Vulkan;DirectX11;DirectX12")
elseif(VNE_TARGET_PLATFORM STREQUAL "Linux")
    set(VNE_SUPPORTED_BACKENDS "OpenGL;OpenGLES;Vulkan")
elseif(VNE_TARGET_PLATFORM STREQUAL "macOS")
    set(VNE_SUPPORTED_BACKENDS "OpenGL;Vulkan;Metal")
elseif(VNE_TARGET_PLATFORM STREQUAL "iOS")
    set(VNE_SUPPORTED_BACKENDS "OpenGLES;Vulkan;Metal")
elseif(VNE_TARGET_PLATFORM STREQUAL "visionOS")
    set(VNE_SUPPORTED_BACKENDS "Metal")
elseif(VNE_TARGET_PLATFORM STREQUAL "Android")
    set(VNE_SUPPORTED_BACKENDS "OpenGLES;Vulkan")
elseif(VNE_TARGET_PLATFORM STREQUAL "Web")
    set(VNE_SUPPORTED_BACKENDS "OpenGLES;WebGPU")
else()
    message(FATAL_ERROR "Unsupported platform for backend selection: ${VNE_TARGET_PLATFORM}")
endif()

#==============================================================================
# Backend Options (User Configurable)
#==============================================================================

# Helper function to check if backend is supported
function(vne_is_backend_supported backend result)
    if(backend IN_LIST VNE_SUPPORTED_BACKENDS)
        set(${result} TRUE PARENT_SCOPE)
    else()
        set(${result} FALSE PARENT_SCOPE)
    endif()
endfunction()

# OpenGL Family Options (mutually exclusive)
vne_is_backend_supported("OpenGL" OPENGL_SUPPORTED)
vne_is_backend_supported("OpenGLES" OPENGLES_SUPPORTED)
vne_is_backend_supported("WebGL" WEBGL_SUPPORTED)

# Smart default selection for OpenGL family (only one enabled by default)
if(OPENGL_SUPPORTED)
    set(OPENGL_DEFAULT ON)
    set(OPENGLES_DEFAULT OFF)
    set(WEBGL_DEFAULT OFF)
elseif(OPENGLES_SUPPORTED)
    set(OPENGL_DEFAULT OFF)
    set(OPENGLES_DEFAULT ON)
    set(WEBGL_DEFAULT OFF)
elseif(WEBGL_SUPPORTED)
    set(OPENGL_DEFAULT OFF)
    set(OPENGLES_DEFAULT OFF)
    set(WEBGL_DEFAULT ON)
else()
    set(OPENGL_DEFAULT OFF)
    set(OPENGLES_DEFAULT OFF)
    set(WEBGL_DEFAULT OFF)
endif()

# Debug output for defaults
message(STATUS "OPENGL_SUPPORTED: ${OPENGL_SUPPORTED}")
message(STATUS "OPENGLES_SUPPORTED: ${OPENGLES_SUPPORTED}")
message(STATUS "WEBGL_SUPPORTED: ${WEBGL_SUPPORTED}")
message(STATUS "OPENGL_DEFAULT: ${OPENGL_DEFAULT}")
message(STATUS "OPENGLES_DEFAULT: ${OPENGLES_DEFAULT}")
message(STATUS "WEBGL_DEFAULT: ${WEBGL_DEFAULT}")

# Set options with smart defaults
option(VNE_ENABLE_OPENGL "Enable OpenGL backend" ${OPENGL_DEFAULT})
option(VNE_ENABLE_OPENGLES "Enable OpenGL ES backend" ${OPENGLES_DEFAULT})
option(VNE_ENABLE_WEBGL "Enable WebGL backend" ${WEBGL_DEFAULT})

# Debug output for actual option values
message(STATUS "VNE_ENABLE_OPENGL: ${VNE_ENABLE_OPENGL}")
message(STATUS "VNE_ENABLE_OPENGLES: ${VNE_ENABLE_OPENGLES}")
message(STATUS "VNE_ENABLE_WEBGL: ${VNE_ENABLE_WEBGL}")

# Other Backend Options
vne_is_backend_supported("Vulkan" VULKAN_SUPPORTED)
vne_is_backend_supported("Metal" METAL_SUPPORTED)
vne_is_backend_supported("DirectX11" DIRECTX11_SUPPORTED)
vne_is_backend_supported("DirectX12" DIRECTX12_SUPPORTED)
vne_is_backend_supported("WebGPU" WEBGPU_SUPPORTED)

option(VNE_ENABLE_VULKAN "Enable Vulkan backend" ${VULKAN_SUPPORTED})
option(VNE_ENABLE_METAL "Enable Metal backend" ${METAL_SUPPORTED})
option(VNE_ENABLE_DIRECTX11 "Enable DirectX 11 backend" ${DIRECTX11_SUPPORTED})
option(VNE_ENABLE_DIRECTX12 "Enable DirectX 12 backend" ${DIRECTX12_SUPPORTED})
option(VNE_ENABLE_WEBGPU "Enable WebGPU backend (experimental)" ${WEBGPU_SUPPORTED})

#==============================================================================
# Backend Validation
#==============================================================================

# Validate that at least one backend is enabled
set(ENABLED_BACKENDS "")
if(VNE_ENABLE_OPENGL)
    list(APPEND ENABLED_BACKENDS "OpenGL")
endif()
if(VNE_ENABLE_OPENGLES)
    list(APPEND ENABLED_BACKENDS "OpenGLES")
endif()
if(VNE_ENABLE_WEBGL)
    list(APPEND ENABLED_BACKENDS "WebGL")
endif()
if(VNE_ENABLE_WEBGPU)
    list(APPEND ENABLED_BACKENDS "WebGPU")
endif()
if(VNE_ENABLE_VULKAN)
    list(APPEND ENABLED_BACKENDS "Vulkan")
endif()
if(VNE_ENABLE_METAL)
    list(APPEND ENABLED_BACKENDS "Metal")
endif()
if(VNE_ENABLE_DIRECTX11)
    list(APPEND ENABLED_BACKENDS "DirectX11")
endif()
if(VNE_ENABLE_DIRECTX12)
    list(APPEND ENABLED_BACKENDS "DirectX12")
endif()

if(ENABLED_BACKENDS STREQUAL "")
    message(FATAL_ERROR "No graphics backend enabled. Please enable at least one backend.")
endif()

# Validate OpenGL family exclusivity (only one can be active)
set(OPENGL_FAMILY_COUNT 0)
if(VNE_ENABLE_OPENGL)
    math(EXPR OPENGL_FAMILY_COUNT "${OPENGL_FAMILY_COUNT} + 1")
endif()
if(VNE_ENABLE_OPENGLES)
    math(EXPR OPENGL_FAMILY_COUNT "${OPENGL_FAMILY_COUNT} + 1")
endif()
if(VNE_ENABLE_WEBGL)
    math(EXPR OPENGL_FAMILY_COUNT "${OPENGL_FAMILY_COUNT} + 1")
endif()

message(STATUS "OPENGL_FAMILY_COUNT: ${OPENGL_FAMILY_COUNT}")
message(STATUS "OPENGL_DEFAULT: ${OPENGL_DEFAULT}")
message(STATUS "OPENGLES_DEFAULT: ${OPENGLES_DEFAULT}")
message(STATUS "WEBGL_DEFAULT: ${WEBGL_DEFAULT}")
message(STATUS "OPENGL_SUPPORTED: ${OPENGL_SUPPORTED}")
message(STATUS "OPENGLES_SUPPORTED: ${OPENGLES_SUPPORTED}")
message(STATUS "WEBGL_SUPPORTED: ${WEBGL_SUPPORTED}")

# Auto-fix OpenGL family conflicts by keeping only the first enabled one
if(OPENGL_FAMILY_COUNT GREATER 1)
    message(WARNING "Multiple OpenGL family backends enabled. Auto-disabling conflicting backends.")

    if(VNE_ENABLE_OPENGL)
        message(STATUS "Keeping OpenGL, disabling OpenGL ES and WebGL")
        set(VNE_ENABLE_OPENGLES OFF CACHE BOOL "Enable OpenGL ES backend" FORCE)
        set(VNE_ENABLE_WEBGL OFF CACHE BOOL "Enable WebGL backend" FORCE)
    elseif(VNE_ENABLE_OPENGLES)
        message(STATUS "Keeping OpenGL ES, disabling OpenGL and WebGL")
        set(VNE_ENABLE_OPENGL OFF CACHE BOOL "Enable OpenGL backend" FORCE)
        set(VNE_ENABLE_WEBGL OFF CACHE BOOL "Enable WebGL backend" FORCE)
    elseif(VNE_ENABLE_WEBGL)
        message(STATUS "Keeping WebGL, disabling OpenGL and OpenGL ES")
        set(VNE_ENABLE_OPENGL OFF CACHE BOOL "Enable OpenGL backend" FORCE)
        set(VNE_ENABLE_OPENGLES OFF CACHE BOOL "Enable OpenGL ES backend" FORCE)
    endif()

    # Recalculate enabled backends after auto-fix
    set(ENABLED_BACKENDS "")
    if(VNE_ENABLE_OPENGL)
        list(APPEND ENABLED_BACKENDS "OpenGL")
    endif()
    if(VNE_ENABLE_OPENGLES)
        list(APPEND ENABLED_BACKENDS "OpenGLES")
    endif()
    if(VNE_ENABLE_WEBGL)
        list(APPEND ENABLED_BACKENDS "WebGL")
    endif()
    if(VNE_ENABLE_WEBGPU)
        list(APPEND ENABLED_BACKENDS "WebGPU")
    endif()
    if(VNE_ENABLE_VULKAN)
        list(APPEND ENABLED_BACKENDS "Vulkan")
    endif()
    if(VNE_ENABLE_METAL)
        list(APPEND ENABLED_BACKENDS "Metal")
    endif()
    if(VNE_ENABLE_DIRECTX11)
        list(APPEND ENABLED_BACKENDS "DirectX11")
    endif()
    if(VNE_ENABLE_DIRECTX12)
        list(APPEND ENABLED_BACKENDS "DirectX12")
    endif()
endif()

#==============================================================================
# Default Backend Selection
#==============================================================================

if(NOT DEFINED VNE_DEFAULT_BACKEND)
    # Platform-aware priority order for default backend
    if(VNE_TARGET_PLATFORM STREQUAL "macOS")
        # macOS: Metal > Vulkan > OpenGL
        if(VNE_ENABLE_METAL)
            set(VNE_DEFAULT_BACKEND "Metal")
        elseif(VNE_ENABLE_VULKAN)
            set(VNE_DEFAULT_BACKEND "Vulkan")
        elseif(VNE_ENABLE_OPENGL)
    set(VNE_DEFAULT_BACKEND "OpenGL")
        else()
            message(FATAL_ERROR "No suitable backend enabled for macOS")
endif()
    elseif(VNE_TARGET_PLATFORM STREQUAL "iOS")
        # iOS: Metal > OpenGLES > Vulkan
        if(VNE_ENABLE_METAL)
            set(VNE_DEFAULT_BACKEND "Metal")
        elseif(VNE_ENABLE_OPENGLES)
            set(VNE_DEFAULT_BACKEND "OpenGLES")
        elseif(VNE_ENABLE_VULKAN)
            set(VNE_DEFAULT_BACKEND "Vulkan")
        else()
            message(FATAL_ERROR "No suitable backend enabled for iOS")
        endif()
    elseif(VNE_TARGET_PLATFORM STREQUAL "visionOS")
        # visionOS: Metal only (required for ARKit-based XR)
        if(VNE_ENABLE_METAL)
            set(VNE_DEFAULT_BACKEND "Metal")
        else()
            message(FATAL_ERROR "Metal backend is required for visionOS. Please enable VNE_ENABLE_METAL.")
        endif()
    elseif(VNE_TARGET_PLATFORM STREQUAL "Linux")
        # Linux: Vulkan > OpenGL > OpenGLES
        if(VNE_ENABLE_VULKAN)
            set(VNE_DEFAULT_BACKEND "Vulkan")
        elseif(VNE_ENABLE_OPENGL)
            set(VNE_DEFAULT_BACKEND "OpenGL")
        elseif(VNE_ENABLE_OPENGLES)
            set(VNE_DEFAULT_BACKEND "OpenGLES")
        else()
            message(FATAL_ERROR "No suitable backend enabled for Linux")
        endif()
    elseif(VNE_TARGET_PLATFORM STREQUAL "Windows")
        # Windows: DirectX12 > DirectX11 > Vulkan > OpenGL
        if(VNE_ENABLE_DIRECTX12)
            set(VNE_DEFAULT_BACKEND "DirectX12")
        elseif(VNE_ENABLE_DIRECTX11)
            set(VNE_DEFAULT_BACKEND "DirectX11")
        elseif(VNE_ENABLE_VULKAN)
            set(VNE_DEFAULT_BACKEND "Vulkan")
        elseif(VNE_ENABLE_OPENGL)
            set(VNE_DEFAULT_BACKEND "OpenGL")
        else()
            message(FATAL_ERROR "No suitable backend enabled for Windows")
        endif()
    elseif(VNE_TARGET_PLATFORM STREQUAL "Android")
        # Android: OpenGLES > Vulkan
        if(VNE_ENABLE_OPENGLES)
            set(VNE_DEFAULT_BACKEND "OpenGLES")
        elseif(VNE_ENABLE_VULKAN)
            set(VNE_DEFAULT_BACKEND "Vulkan")
        else()
            message(FATAL_ERROR "No suitable backend enabled for Android")
        endif()
    elseif(VNE_TARGET_PLATFORM STREQUAL "Web")
        # Web: OpenGL ES > WebGPU
        if(VNE_ENABLE_OPENGLES)
            set(VNE_DEFAULT_BACKEND "OpenGLES")
        elseif(VNE_ENABLE_WEBGPU)
            set(VNE_DEFAULT_BACKEND "WebGPU")
        else()
            message(FATAL_ERROR "No suitable backend enabled for Web")
        endif()
    else()
        # Fallback priority order for unknown platforms
        if(VNE_ENABLE_OPENGL)
            set(VNE_DEFAULT_BACKEND "OpenGL")
        elseif(VNE_ENABLE_OPENGLES)
            set(VNE_DEFAULT_BACKEND "OpenGLES")
        elseif(VNE_ENABLE_METAL)
            set(VNE_DEFAULT_BACKEND "Metal")
        elseif(VNE_ENABLE_VULKAN)
            set(VNE_DEFAULT_BACKEND "Vulkan")
        elseif(VNE_ENABLE_DIRECTX12)
            set(VNE_DEFAULT_BACKEND "DirectX12")
        elseif(VNE_ENABLE_DIRECTX11)
            set(VNE_DEFAULT_BACKEND "DirectX11")
        elseif(VNE_ENABLE_WEBGL)
            set(VNE_DEFAULT_BACKEND "WebGL")
        elseif(VNE_ENABLE_WEBGPU)
            set(VNE_DEFAULT_BACKEND "WebGPU")
        else()
            message(FATAL_ERROR "No enabled backend found for default selection")
        endif()
    endif()
endif()

# Validate default backend is enabled
if(NOT VNE_DEFAULT_BACKEND IN_LIST ENABLED_BACKENDS)
    message(FATAL_ERROR "Default backend '${VNE_DEFAULT_BACKEND}' is not enabled. Available: ${ENABLED_BACKENDS}")
endif()

#==============================================================================
# C/C++ Preprocessor Definitions
#==============================================================================

# Backend enable macros (for conditional compilation)
if(VNE_ENABLE_OPENGL)
    add_definitions(-DVNE_ENABLE_OPENGL)
endif()
if(VNE_ENABLE_OPENGLES)
    add_definitions(-DVNE_ENABLE_OPENGLES)
endif()
if(VNE_ENABLE_WEBGL)
    add_definitions(-DVNE_ENABLE_WEBGL)
endif()
if(VNE_ENABLE_WEBGPU)
    add_definitions(-DVNE_ENABLE_WEBGPU)
endif()
if(VNE_ENABLE_VULKAN)
    add_definitions(-DVNE_ENABLE_VULKAN)
endif()
if(VNE_ENABLE_METAL)
    add_definitions(-DVNE_ENABLE_METAL)
endif()
if(VNE_ENABLE_DIRECTX11)
    add_definitions(-DVNE_ENABLE_DIRECTX11)
endif()
if(VNE_ENABLE_DIRECTX12)
    add_definitions(-DVNE_ENABLE_DIRECTX12)
endif()

# Default backend macro
add_definitions(-DVNE_DEFAULT_BACKEND="${VNE_DEFAULT_BACKEND}")

# Platform macros (using existing VNE_TARGET_PLATFORM)
add_definitions(-DVNE_PLATFORM_${VNE_TARGET_PLATFORM})

#==============================================================================
# Backend-Specific Configuration
#==============================================================================

# OpenGL Family Configuration (GLAD integration)
if(VNE_ENABLE_OPENGL OR VNE_ENABLE_OPENGLES OR VNE_ENABLE_WEBGL)
    # Set GLAD API options based on enabled backend
    if(VNE_ENABLE_OPENGL)
        set(VNE_GL_API "OpenGL")
        add_definitions(-DVNE_GL_API_OPENGL)
    elseif(VNE_ENABLE_OPENGLES)
        set(VNE_GL_API "OpenGLES")
        add_definitions(-DVNE_GL_API_OPENGLES)
    elseif(VNE_ENABLE_WEBGL)
        set(VNE_GL_API "WebGL")
        add_definitions(-DVNE_GL_API_WEBGL)
    endif()
    add_definitions(-DVNE_USE_GLAD)
endif()

# Shader Compilation Support (shaderc + SPIRV-Cross)
# These are needed for:
#   - Vulkan: GLSL → SPIR-V compilation
#   - OpenGL: GLSL 4.5 → SPIR-V → OpenGL GLSL cross-compilation (for 13_spirv demo)
#   - OpenGL ES: GLSL 4.5 → SPIR-V → GLSL ES 3.0 cross-compilation (for 13_spirv demo)
#   - Metal: GLSL → SPIR-V → MSL cross-compilation
if(VNE_ENABLE_VULKAN OR VNE_ENABLE_OPENGLES OR VNE_ENABLE_OPENGL OR VNE_ENABLE_METAL)
    # Try to find system shaderc first (faster, saves CI minutes)
    # Option is set in main CMakeLists.txt with CI-aware defaults

    set(SHADERC_FOUND_SYSTEM FALSE)
    if(VNE_USE_SYSTEM_SHADERC)
        # Try to find shaderc package (provides shaderc::shaderc target)
        find_package(shaderc QUIET)
        if(shaderc_FOUND)
            set(SHADERC_FOUND_SYSTEM TRUE)
            add_definitions(-DVNE_SHADERC_AVAILABLE)
            message(STATUS "Using system-installed shaderc (saves build time)")
        else()
            message(STATUS "System shaderc not found, will build from source")
        endif()
    endif()

    # Build shaderc from source if system version not found
    if(NOT SHADERC_FOUND_SYSTEM AND EXISTS ${VNE_THIRD_PARTY_DIR}/shaderc/CMakeLists.txt)
        # Configure shaderc to build as static library and skip installation
        set(SHADERC_SKIP_INSTALL ON CACHE BOOL "Skip shaderc installation" FORCE)
        set(SHADERC_SKIP_TESTS ON CACHE BOOL "Skip shaderc tests" FORCE)
        set(SHADERC_ENABLE_EXAMPLES OFF CACHE BOOL "Disable shaderc examples" FORCE)

        # Disable installation for shaderc dependencies to avoid export errors
        # These must be set before add_subdirectory() so they're available when glslang/SPIRV-Tools configure
        set(ENABLE_GLSLANG_INSTALL OFF CACHE BOOL "Disable glslang installation" FORCE)
        set(ENABLE_SPIRV_TOOLS_INSTALL OFF CACHE BOOL "Disable SPIRV-Tools installation" FORCE)
        set(SPIRV_TOOLS_SKIP_EXECUTABLES ON CACHE BOOL "Skip SPIRV-Tools executables" FORCE)

        # Additional options to prevent export set errors and speed up compilation
        # Set BUILD_SHARED_LIBS OFF globally to prevent SPIRV-Tools from building shared libraries
        # This significantly reduces compile time since SPIRV-Tools has many source files
        set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build static libraries only" FORCE)
        set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON CACHE BOOL "Skip install dependencies" FORCE)

        # Temporarily disable install() commands in subdirectories
        set(CMAKE_SKIP_INSTALL_RULES ON CACHE BOOL "Skip install rules" FORCE)

        add_subdirectory(${VNE_THIRD_PARTY_DIR}/shaderc)
        add_definitions(-DVNE_SHADERC_AVAILABLE)

        # Add shaderc include directory to global include paths
        include_directories(SYSTEM ${VNE_THIRD_PARTY_DIR}/shaderc/libshaderc/include)

        message(STATUS "shaderc submodule found - GLSL/HLSL → SPIR-V compilation enabled (building from source)")
    elseif(NOT SHADERC_FOUND_SYSTEM)
        message(WARNING "shaderc not found (neither system nor submodule). Runtime shader compilation will be disabled.")
    endif()

    # Add SPIRV-Cross for SPIR-V → GLSL/MSL translation
    # Needed for: Vulkan (SPIR-V → GLSL/MSL), OpenGL ES (GLSL 4.5 → SPIR-V → GLSL ES 3.0), Metal (SPIR-V → MSL)
    if(EXISTS ${VNE_THIRD_PARTY_DIR}/SPIRV-Cross/CMakeLists.txt)
        # Configure SPIRV-Cross options
        set(SPIRV_CROSS_CLI OFF CACHE BOOL "Disable SPIRV-Cross CLI" FORCE)
        set(SPIRV_CROSS_ENABLE_TESTS OFF CACHE BOOL "Disable SPIRV-Cross tests" FORCE)
        add_subdirectory(${VNE_THIRD_PARTY_DIR}/SPIRV-Cross)
        add_definitions(-DVNE_SPIRV_CROSS_AVAILABLE)
        message(STATUS "SPIRV-Cross submodule found - SPIR-V translation enabled")
    else()
        message(WARNING "SPIRV-Cross submodule not found. SPIR-V translation will be disabled.")
    endif()
endif()

# Vulkan Configuration
if(VNE_ENABLE_VULKAN)
    # Check if Vulkan headers submodule is available
    if(EXISTS ${VNE_THIRD_PARTY_DIR}/vulkan-headers/include/vulkan/vulkan.h)
        add_definitions(-DVNE_VULKAN_AVAILABLE)
        message(STATUS "Vulkan headers found in submodule")

        # macOS: Check for MoltenVK (system installation or submodule)
        if(APPLE)
            # First try to find system MoltenVK installation
            find_library(MOLTENVK_LIBRARY MoltenVK)
            if(MOLTENVK_LIBRARY)
                add_definitions(-DVNE_MOLTENVK_AVAILABLE)
                message(STATUS "MoltenVK found in system: ${MOLTENVK_LIBRARY}")
            elseif(EXISTS ${VNE_THIRD_PARTY_DIR}/moltenvk)
                # Fallback to submodule (would need to be built)
                add_definitions(-DVNE_MOLTENVK_AVAILABLE)
                message(STATUS "MoltenVK submodule found (needs to be built)")
                message(STATUS "Consider installing MoltenVK system-wide: brew install molten-vk")
            else()
                message(WARNING "MoltenVK not found. Vulkan will not work on macOS.")
                message(STATUS "Install MoltenVK: brew install molten-vk")
            endif()
        endif()
    else()
        # Fallback to system Vulkan if submodule not available
        find_package(Vulkan QUIET)
        if(Vulkan_FOUND)
            add_definitions(-DVNE_VULKAN_AVAILABLE)
            message(STATUS "Vulkan found in system installation")
        else()
            message(WARNING "Vulkan requested but not found. Disabling Vulkan backend.")
            set(VNE_ENABLE_VULKAN OFF)
            list(REMOVE_ITEM ENABLED_BACKENDS "Vulkan")
        endif()
    endif()
endif()

# Metal Configuration
if(VNE_ENABLE_METAL)
    if(APPLE)
        find_library(METAL_FRAMEWORK Metal)
        find_library(METALKIT_FRAMEWORK MetalKit)
        if(METAL_FRAMEWORK AND METALKIT_FRAMEWORK)
            add_definitions(-DVNE_METAL_AVAILABLE)
        else()
            message(WARNING "Metal requested but not found. Disabling Metal backend.")
            set(VNE_ENABLE_METAL OFF)
            list(REMOVE_ITEM ENABLED_BACKENDS "Metal")
        endif()
    else()
        message(WARNING "Metal requested but not on Apple platform. Disabling Metal backend.")
        set(VNE_ENABLE_METAL OFF)
        list(REMOVE_ITEM ENABLED_BACKENDS "Metal")
    endif()
endif()

# DirectX Configuration
if(VNE_ENABLE_DIRECTX11 OR VNE_ENABLE_DIRECTX12)
    if(WIN32)
        if(VNE_ENABLE_DIRECTX11)
            find_library(D3D11_LIBRARY d3d11)
            find_library(DXGI_LIBRARY dxgi)
            if(D3D11_LIBRARY AND DXGI_LIBRARY)
                add_definitions(-DVNE_DIRECTX11_AVAILABLE)
            else()
                message(WARNING "DirectX 11 requested but not found. Disabling DirectX 11 backend.")
                set(VNE_ENABLE_DIRECTX11 OFF)
                list(REMOVE_ITEM ENABLED_BACKENDS "DirectX11")
            endif()
        endif()

        if(VNE_ENABLE_DIRECTX12)
            find_library(D3D12_LIBRARY d3d12)
            find_library(DXGI_LIBRARY dxgi)
            if(D3D12_LIBRARY AND DXGI_LIBRARY)
                add_definitions(-DVNE_DIRECTX12_AVAILABLE)
            else()
                message(WARNING "DirectX 12 requested but not found. Disabling DirectX 12 backend.")
                set(VNE_ENABLE_DIRECTX12 OFF)
                list(REMOVE_ITEM ENABLED_BACKENDS "DirectX12")
            endif()
        endif()
    else()
        message(WARNING "DirectX requested but not on Windows platform. Disabling DirectX backends.")
        set(VNE_ENABLE_DIRECTX11 OFF)
        set(VNE_ENABLE_DIRECTX12 OFF)
        list(REMOVE_ITEM ENABLED_BACKENDS "DirectX11")
        list(REMOVE_ITEM ENABLED_BACKENDS "DirectX12")
    endif()
endif()

#==============================================================================
# Helper Functions and Macros
#==============================================================================

# Macro to add backend-specific sources
macro(vne_backend_sources out_var)
    set(sources "")

    if(VNE_ENABLE_OPENGL)
        list(APPEND sources ${ARGN}OpenGL)
    endif()
    if(VNE_ENABLE_OPENGLES)
        list(APPEND sources ${ARGN}OpenGLES)
    endif()
    if(VNE_ENABLE_WEBGL)
        list(APPEND sources ${ARGN}WebGL)
    endif()
    if(VNE_ENABLE_VULKAN)
        list(APPEND sources ${ARGN}Vulkan)
    endif()
    if(VNE_ENABLE_METAL)
        list(APPEND sources ${ARGN}Metal)
    endif()
    if(VNE_ENABLE_DIRECTX11)
        list(APPEND sources ${ARGN}DirectX11)
    endif()
    if(VNE_ENABLE_DIRECTX12)
        list(APPEND sources ${ARGN}DirectX12)
    endif()

    set(${out_var} ${sources} PARENT_SCOPE)
endmacro()

# Macro to add backend-specific include directories
macro(vne_backend_include_dirs target)
    # OpenGL Family backends (OpenGL, OpenGL ES, WebGL)
    if(VNE_ENABLE_OPENGL OR VNE_ENABLE_OPENGLES OR VNE_ENABLE_WEBGL)
        # Add GLAD include directory if available
        if(TARGET glad)
            target_include_directories(${target} PRIVATE ${VNE_THIRD_PARTY_DIR}/glad/include)
        endif()

        # Add backend-specific include directories (if they exist)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include/opengl)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/opengl)
        endif()
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/backend/opengl)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backend/opengl)
        endif()
    endif()

    # Vulkan backend
    if(VNE_ENABLE_VULKAN)
        # Add Vulkan headers from submodule
        if(EXISTS ${VNE_THIRD_PARTY_DIR}/vulkan-headers/include)
            target_include_directories(${target} SYSTEM PRIVATE ${VNE_THIRD_PARTY_DIR}/vulkan-headers/include)
        endif()

        # Add project-specific Vulkan includes
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include/vulkan)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/vulkan)
        endif()
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/backend/vulkan)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backend/vulkan)
        endif()
    endif()

    # Metal backend
    if(VNE_ENABLE_METAL)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include/metal)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/metal)
        endif()
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/backend/metal)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backend/metal)
        endif()
    endif()

    # DirectX backends
    if(VNE_ENABLE_DIRECTX11)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include/directx11)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/directx11)
        endif()
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/backend/directx11)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backend/directx11)
        endif()
    endif()

    if(VNE_ENABLE_DIRECTX12)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include/directx12)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/directx12)
        endif()
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/backend/directx12)
            target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backend/directx12)
        endif()
    endif()
endmacro()

# Macro to link backend-specific libraries
macro(vne_backend_link_libraries target)
    # OpenGL Family backends (OpenGL, OpenGL ES, WebGL)
    if(VNE_ENABLE_OPENGL OR VNE_ENABLE_OPENGLES OR VNE_ENABLE_WEBGL)
        # Link GLAD if available
        if(TARGET glad)
            target_link_libraries(${target} PRIVATE glad)
        endif()

        # Link OpenGL library
        find_package(OpenGL)
        if(OpenGL_FOUND)
            target_link_libraries(${target} PRIVATE OpenGL::GL)
        endif()

        # Link shaderc and SPIRV-Cross for OpenGL/OpenGL ES (needed for GLSL 4.5 → SPIR-V → OpenGL GLSL)
        # This enables the 13_spirv demo to work on desktop OpenGL and web/OpenGL ES
        if(VNE_ENABLE_OPENGL OR VNE_ENABLE_OPENGLES)
            # Determine backend name for logging
            if(VNE_ENABLE_OPENGLES)
                set(BACKEND_NAME "OpenGL ES")
            else()
                set(BACKEND_NAME "OpenGL")
            endif()

            # Link shaderc for shader compilation
            if(TARGET shaderc::shaderc)
                target_link_libraries(${target} PRIVATE shaderc::shaderc)
                message(STATUS "Linking system shaderc to ${target} (${BACKEND_NAME})")
            elseif(TARGET shaderc)
                target_link_libraries(${target} PRIVATE shaderc)
                message(STATUS "Linking built shaderc to ${target} (${BACKEND_NAME})")
            endif()

            # Link SPIRV-Cross for shader translation
            # Note: We link MSL library too even though it's not used for OpenGL/OpenGL ES,
            # because spirv_cross_compiler.cpp includes MSL code that references MSL symbols
            if(TARGET spirv-cross-core)
                target_link_libraries(${target} PRIVATE
                    spirv-cross-core
                    spirv-cross-glsl
                    spirv-cross-msl
                    spirv-cross-reflect)
                message(STATUS "Linking SPIRV-Cross libraries to ${target} (${BACKEND_NAME})")
            endif()
        endif()
    endif()

    # Vulkan backend
    if(VNE_ENABLE_VULKAN)
        # Add Vulkan headers include directory
        if(EXISTS ${VNE_THIRD_PARTY_DIR}/vulkan-headers/include)
            target_include_directories(${target} SYSTEM PRIVATE ${VNE_THIRD_PARTY_DIR}/vulkan-headers/include)
        endif()

        # Enable Vulkan C++ bindings
        target_compile_definitions(${target} PRIVATE VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1)
        target_compile_definitions(${target} PRIVATE VULKAN_HPP_NO_EXCEPTIONS)
        target_compile_definitions(${target} PRIVATE VULKAN_HPP_NO_SMART_HANDLE)

        # Link shaderc for shader compilation
        # Try system shaderc first, then fallback to built target
        if(TARGET shaderc::shaderc)
            # System shaderc (CMake imported target)
            target_link_libraries(${target} PRIVATE shaderc::shaderc)
            message(STATUS "Linking system shaderc to ${target}")
        elseif(TARGET shaderc)
            # Built shaderc from submodule
            target_link_libraries(${target} PRIVATE shaderc)
            message(STATUS "Linking built shaderc to ${target}")
        else()
            message(WARNING "shaderc target not found - shader compilation will not be available")
        endif()

        # Link SPIRV-Cross for shader translation
        if(TARGET spirv-cross-core)
            target_link_libraries(${target} PRIVATE spirv-cross-core spirv-cross-glsl spirv-cross-msl spirv-cross-reflect)
            message(STATUS "Linking SPIRV-Cross libraries to ${target}")
        endif()

        # macOS: Link MoltenVK
        if(APPLE AND DEFINED VNE_MOLTENVK_AVAILABLE)
            # Link MoltenVK library
            if(MOLTENVK_LIBRARY)
                target_link_libraries(${target} PRIVATE ${MOLTENVK_LIBRARY})
                message(STATUS "Linked MoltenVK library: ${MOLTENVK_LIBRARY}")
            endif()

            # Link required macOS frameworks for MoltenVK
            find_library(METAL_FRAMEWORK Metal)
            find_library(METALKIT_FRAMEWORK MetalKit)
            find_library(COCOA_FRAMEWORK Cocoa)
            find_library(IOKIT_FRAMEWORK IOKit)
            find_library(QUARTZCORE_FRAMEWORK QuartzCore)

            if(METAL_FRAMEWORK AND METALKIT_FRAMEWORK AND COCOA_FRAMEWORK AND IOKIT_FRAMEWORK AND QUARTZCORE_FRAMEWORK)
                target_link_libraries(${target} PRIVATE
                    ${METAL_FRAMEWORK}
                    ${METALKIT_FRAMEWORK}
                    ${COCOA_FRAMEWORK}
                    ${IOKIT_FRAMEWORK}
                    ${QUARTZCORE_FRAMEWORK}
                )
                message(STATUS "Linked macOS frameworks for MoltenVK")
            endif()

            add_definitions(-DVNE_VULKAN_LIBRARY_AVAILABLE)
        else()
            # Non-macOS: Try to link system Vulkan library if available
            find_package(Vulkan QUIET)
            if(Vulkan_FOUND)
                target_link_libraries(${target} PRIVATE Vulkan::Vulkan)
                add_definitions(-DVNE_VULKAN_LIBRARY_AVAILABLE)
                message(STATUS "Linked system Vulkan library")
            else()
                # Windows-specific Vulkan library linking
                if(WIN32)
                    # Try to find Vulkan library directly
                    find_library(VULKAN_LIBRARY vulkan-1)
                    if(VULKAN_LIBRARY)
                        target_link_libraries(${target} PRIVATE ${VULKAN_LIBRARY})
                        add_definitions(-DVNE_VULKAN_LIBRARY_AVAILABLE)
                        message(STATUS "Linked Windows Vulkan library: ${VULKAN_LIBRARY}")
                    else()
                        # For header-only usage, we don't need to link anything
                        message(STATUS "Vulkan library not found, using headers only")
                        message(WARNING "Vulkan functions will not be available at runtime without vulkan-1.dll")
                        add_definitions(-DVNE_VULKAN_HEADERS_ONLY)
                    endif()
                else()
                    # For header-only usage, we don't need to link anything
                    message(STATUS "Vulkan library not found, using headers only")
                    add_definitions(-DVNE_VULKAN_HEADERS_ONLY)
                endif()
            endif()
        endif()
    endif()

    # Metal backend
    if(VNE_ENABLE_METAL)
        if(APPLE)
            find_library(METAL_FRAMEWORK Metal)
            find_library(METALKIT_FRAMEWORK MetalKit)
            find_library(FOUNDATION_FRAMEWORK Foundation)
            find_library(QUARTZCORE_FRAMEWORK QuartzCore)
            if(METAL_FRAMEWORK AND METALKIT_FRAMEWORK AND FOUNDATION_FRAMEWORK AND QUARTZCORE_FRAMEWORK)
                target_link_libraries(${target} PRIVATE ${METAL_FRAMEWORK} ${METALKIT_FRAMEWORK} ${FOUNDATION_FRAMEWORK} ${QUARTZCORE_FRAMEWORK})
                message(STATUS "Linked Metal frameworks: Metal, MetalKit, Foundation, QuartzCore")
            endif()

            # iOS/visionOS-specific: Link UIKit framework
            if(VNE_TARGET_PLATFORM STREQUAL "iOS" OR VNE_TARGET_PLATFORM STREQUAL "visionOS")
                find_library(UIKIT_FRAMEWORK UIKit)
                if(UIKIT_FRAMEWORK)
                    target_link_libraries(${target} PRIVATE ${UIKIT_FRAMEWORK})
                    message(STATUS "Linked UIKit framework for ${VNE_TARGET_PLATFORM}")
                endif()
            endif()
        endif()
    endif()

    # DirectX backends
    if(VNE_ENABLE_DIRECTX11)
        if(WIN32)
            find_library(D3D11_LIBRARY d3d11)
            find_library(DXGI_LIBRARY dxgi)
            if(D3D11_LIBRARY AND DXGI_LIBRARY)
                target_link_libraries(${target} PRIVATE ${D3D11_LIBRARY} ${DXGI_LIBRARY})
            endif()
        endif()
    endif()

    if(VNE_ENABLE_DIRECTX12)
        if(WIN32)
            find_library(D3D12_LIBRARY d3d12)
            find_library(DXGI_LIBRARY dxgi)
            if(D3D12_LIBRARY AND DXGI_LIBRARY)
                target_link_libraries(${target} PRIVATE ${D3D12_LIBRARY} ${DXGI_LIBRARY})
            endif()
        endif()
    endif()
endmacro()

# Macro to add backend-specific sources with flexible naming
macro(vne_backend_sources_flexible out_var base_name)
    set(sources "")

    # Check for backend-specific files with various naming patterns
    if(VNE_ENABLE_OPENGL)
        # Try different naming patterns
        set(possible_files
            "${base_name}_opengl"
            "${base_name}OpenGL"
            "opengl_${base_name}"
            "OpenGL${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    if(VNE_ENABLE_OPENGLES)
        set(possible_files
            "${base_name}_opengles"
            "${base_name}OpenGLES"
            "opengles_${base_name}"
            "OpenGLES${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    if(VNE_ENABLE_WEBGL)
        set(possible_files
            "${base_name}_webgl"
            "${base_name}WebGL"
            "webgl_${base_name}"
            "WebGL${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    if(VNE_ENABLE_VULKAN)
        set(possible_files
            "${base_name}_vulkan"
            "${base_name}Vulkan"
            "vulkan_${base_name}"
            "Vulkan${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    if(VNE_ENABLE_METAL)
        set(possible_files
            "${base_name}_metal"
            "${base_name}Metal"
            "metal_${base_name}"
            "Metal${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    if(VNE_ENABLE_DIRECTX11)
        set(possible_files
            "${base_name}_directx11"
            "${base_name}DirectX11"
            "directx11_${base_name}"
            "DirectX11${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    if(VNE_ENABLE_DIRECTX12)
        set(possible_files
            "${base_name}_directx12"
            "${base_name}DirectX12"
            "directx12_${base_name}"
            "DirectX12${base_name}"
        )
        foreach(pattern ${possible_files})
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}.cpp")
                list(APPEND sources "${pattern}.cpp")
                break()
            endif()
        endforeach()
    endif()

    set(${out_var} ${sources} PARENT_SCOPE)
endmacro()

#==============================================================================
# Status Reporting
#==============================================================================

message(STATUS "=== VertexNova Backend Configuration ===")
message(STATUS "Platform: ${VNE_TARGET_PLATFORM}")
message(STATUS "Supported Backends: ${VNE_SUPPORTED_BACKENDS}")
message(STATUS "Default Backend: ${VNE_DEFAULT_BACKEND}")
message(STATUS "Enabled Backends: ${ENABLED_BACKENDS}")

# Show backend status with clear indicators
message(STATUS "")
message(STATUS "Backend Status:")
message(STATUS "  OpenGL:     ${VNE_ENABLE_OPENGL} ${OPENGL_SUPPORTED}")
message(STATUS "  OpenGL ES:  ${VNE_ENABLE_OPENGLES} ${OPENGLES_SUPPORTED}")
message(STATUS "  WebGL:      ${VNE_ENABLE_WEBGL} ${WEBGL_SUPPORTED}")
message(STATUS "  Vulkan:     ${VNE_ENABLE_VULKAN} ${VULKAN_SUPPORTED}")
message(STATUS "  Metal:      ${VNE_ENABLE_METAL} ${METAL_SUPPORTED}")
message(STATUS "  DirectX 11: ${VNE_ENABLE_DIRECTX11} ${DIRECTX11_SUPPORTED}")
message(STATUS "  DirectX 12: ${VNE_ENABLE_DIRECTX12} ${DIRECTX12_SUPPORTED}")

# Show OpenGL family configuration
if(VNE_GL_API)
    message(STATUS "")
    message(STATUS "OpenGL Family Configuration:")
    message(STATUS "  GL API: ${VNE_GL_API}")
    message(STATUS "  GLAD: Enabled")
endif()

# Show multi-backend capabilities
set(ENABLED_COUNT 0)
if(VNE_ENABLE_OPENGL OR VNE_ENABLE_OPENGLES OR VNE_ENABLE_WEBGL)
    math(EXPR ENABLED_COUNT "${ENABLED_COUNT} + 1")
endif()
if(VNE_ENABLE_VULKAN)
    math(EXPR ENABLED_COUNT "${ENABLED_COUNT} + 1")
endif()
if(VNE_ENABLE_METAL)
    math(EXPR ENABLED_COUNT "${ENABLED_COUNT} + 1")
endif()
if(VNE_ENABLE_DIRECTX11 OR VNE_ENABLE_DIRECTX12)
    math(EXPR ENABLED_COUNT "${ENABLED_COUNT} + 1")
endif()

if(ENABLED_COUNT GREATER 1)
    message(STATUS "")
    message(STATUS "Multi-Backend Support: ${ENABLED_COUNT} backends enabled")
    message(STATUS "  - Runtime backend selection available")
    message(STATUS "  - Use VNE_DEFAULT_BACKEND to set preferred backend")
endif()

message(STATUS "=========================================")
