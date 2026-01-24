# Windows-specific configuration for VertexNova
# This file contains Windows-specific settings and configurations

# Set Windows-specific compiler flags
if(MSVC)
    # Enable secure functions by default
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    
    # Set Windows SDK version if not specified
    if(NOT CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION)
        set(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION "10.0")
    endif()
    
    # Ensure C++20 standard (don't override if already set)
    if(NOT CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD 20)
        set(CMAKE_CXX_STANDARD_REQUIRED ON)
        set(CMAKE_CXX_EXTENSIONS OFF)
    endif()
    
    # Disable specific warnings that are not relevant
    add_compile_options(/wd4251)  # class needs to have dll-interface
    add_compile_options(/wd4275)  # non dll-interface class used as base
    add_compile_options(/wd4996)  # deprecated functions (handled by _CRT_SECURE_NO_WARNINGS)
    
    # Enable modern C++ features
    add_compile_options(/permissive-)  # Enable strict C++ standard compliance
    add_compile_options(/Zc:__cplusplus)  # Enable proper __cplusplus macro
    
    message(STATUS "Windows MSVC configuration: C++${CMAKE_CXX_STANDARD}")
endif()

# Windows-specific Vulkan configuration
if(WIN32 AND VNE_ENABLE_VULKAN)
    # Try to find Vulkan SDK in common Windows locations
    set(VULKAN_SDK_PATHS
        "$ENV{VULKAN_SDK}"
        "C:/VulkanSDK"
        "C:/Program Files/VulkanSDK"
        "C:/Program Files (x86)/VulkanSDK"
        "$ENV{PROGRAMFILES}/VulkanSDK"
    )
    
    # Add PROGRAMFILES(X86) separately to avoid CMake syntax issues
    if(DEFINED ENV{PROGRAMFILES\(X86\)})
        list(APPEND VULKAN_SDK_PATHS "$ENV{PROGRAMFILES\(X86\)}/VulkanSDK")
    endif()
    
    # Find Vulkan SDK
    set(VULKAN_SDK_ROOT "")
    foreach(sdk_path ${VULKAN_SDK_PATHS})
        if(sdk_path AND EXISTS "${sdk_path}")
            # Check if this is a versioned installation
            if(IS_DIRECTORY "${sdk_path}")
                # Look for versioned subdirectories
                file(GLOB version_dirs "${sdk_path}/*")
                foreach(version_dir ${version_dirs})
                    if(IS_DIRECTORY "${version_dir}")
                        if(EXISTS "${version_dir}/Bin/vulkan-1.dll" OR EXISTS "${version_dir}/Lib/x64/vulkan-1.lib")
                            set(VULKAN_SDK_ROOT "${version_dir}")
                            message(STATUS "Found Vulkan SDK at: ${VULKAN_SDK_ROOT}")
                            break()
                        endif()
                    endif()
                endforeach()
                
                # If no versioned directory found, check if this is a direct installation
                if(NOT VULKAN_SDK_ROOT AND (EXISTS "${sdk_path}/Bin/vulkan-1.dll" OR EXISTS "${sdk_path}/Lib/x64/vulkan-1.lib"))
                    set(VULKAN_SDK_ROOT "${sdk_path}")
                    message(STATUS "Found Vulkan SDK at: ${VULKAN_SDK_ROOT}")
                    break()
                endif()
            endif()
        endif()
    endforeach()
    
    # Set Vulkan CMake config path
    if(VULKAN_SDK_ROOT)
        set(Vulkan_DIR "${VULKAN_SDK_ROOT}/cmake")
        set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} "${VULKAN_SDK_ROOT}/cmake")
    endif()
    
    # Try to find Vulkan package
    find_package(Vulkan QUIET)
    if(Vulkan_FOUND)
        message(STATUS "Vulkan package found via CMake")
    else()
        # Fallback: try to find vulkan-1 library directly
        find_library(VULKAN_LIBRARY vulkan-1
            PATHS
                "${VULKAN_SDK_ROOT}/Lib"
                "${VULKAN_SDK_ROOT}/Lib/x64"
                "${VULKAN_SDK_ROOT}/Lib/x86"
                "C:/Windows/System32"
        )
        
        if(VULKAN_LIBRARY)
            message(STATUS "Found Vulkan library: ${VULKAN_LIBRARY}")
            # Create Vulkan target manually
            add_library(Vulkan::Vulkan UNKNOWN IMPORTED)
            set_target_properties(Vulkan::Vulkan PROPERTIES
                IMPORTED_LOCATION "${VULKAN_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${VULKAN_SDK_ROOT}/Include"
            )
        else()
            message(WARNING "Vulkan library not found. Vulkan functionality will not be available.")
            message(STATUS "Please install Vulkan SDK from: https://vulkan.lunarg.com/")
        endif()
    endif()
endif()

# ============================================================================
# DirectX Configuration
# ============================================================================
if(VNE_ENABLE_DIRECTX11)
    find_library(D3D11_LIBRARY d3d11)
    find_library(DXGI_LIBRARY dxgi)
    find_library(D3DCOMPILER_LIBRARY d3dcompiler)
    
    if(D3D11_LIBRARY AND DXGI_LIBRARY AND D3DCOMPILER_LIBRARY)
        message(STATUS "DirectX 11 libraries found")
        set(DIRECTX11_AVAILABLE TRUE)
    else()
        message(WARNING "DirectX 11 libraries not found")
        set(DIRECTX11_AVAILABLE FALSE)
    endif()
endif()

if(VNE_ENABLE_DIRECTX12)
    find_library(D3D12_LIBRARY d3d12)
    find_library(DXGI_LIBRARY dxgi)
    find_library(D3DCOMPILER_LIBRARY d3dcompiler)
    
    if(D3D12_LIBRARY AND DXGI_LIBRARY AND D3DCOMPILER_LIBRARY)
        message(STATUS "DirectX 12 libraries found")
        set(DIRECTX12_AVAILABLE TRUE)
    else()
        message(WARNING "DirectX 12 libraries not found")
        set(DIRECTX12_AVAILABLE FALSE)
    endif()
endif()

# ============================================================================
# OpenGL Configuration
# ============================================================================
if(VNE_ENABLE_OPENGL OR VNE_ENABLE_OPENGLES)
    # OpenGL is typically available on Windows via system libraries
    find_package(OpenGL)
    if(OpenGL_FOUND)
        message(STATUS "OpenGL found on Windows")
        set(OPENGL_AVAILABLE TRUE)
    else()
        message(WARNING "OpenGL not found on Windows")
        set(OPENGL_AVAILABLE FALSE)
    endif()
endif()

# ============================================================================
# Windows System Libraries
# ============================================================================
# Find common Windows system libraries
find_library(KERNEL32_LIBRARY kernel32)
find_library(USER32_LIBRARY user32)
find_library(GDI32_LIBRARY gdi32)
find_library(SHELL32_LIBRARY shell32)
find_library(ADVAPI32_LIBRARY advapi32)
find_library(WS2_32_LIBRARY ws2_32)

# ============================================================================
# Windows Runtime Configuration
# ============================================================================
# Set Windows-specific defines
add_definitions(-DWIN32_LEAN_AND_MEAN)  # Exclude rarely-used stuff from Windows headers
add_definitions(-DNOMINMAX)  # Prevent Windows.h from defining min/max macros

# ============================================================================
# Windows Build Configuration
# ============================================================================
# Set Windows-specific build options
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions(-D_DEBUG)
    add_definitions(-DDEBUG)
endif()

# ============================================================================
# Windows SDK Configuration
# ============================================================================
# Ensure Windows SDK is properly configured
if(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION)
    message(STATUS "Windows SDK version: ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}")
endif()

# ============================================================================
# Windows Security Configuration
# ============================================================================
# Enable Windows security features
add_definitions(-DSECURITY_WIN32)

# ============================================================================
# Windows Performance Configuration
# ============================================================================
# Optimize for Windows performance
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options(/O2)  # Optimize for speed
    add_compile_options(/GL)  # Whole program optimization
    add_compile_options(/Gy)  # Function-level linking
endif()

message(STATUS "Windows configuration completed") 