#==============================================================================
# Copyright (c) 2024 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   JULY-2025
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# Emscripten Integration Module
#==============================================================================

# Check if we're building for Emscripten
if(EMSCRIPTEN)
    message(STATUS "Emscripten detected - configuring for Web platform")

    # Set Emscripten-specific variables
    set(VNE_EMSCRIPTEN TRUE)
    set(VNE_TARGET_PLATFORM "Web")

    # Emscripten version detection
    if(DEFINED EMSCRIPTEN_VERSION)
        message(STATUS "Emscripten version: ${EMSCRIPTEN_VERSION}")
    else()
        message(STATUS "Emscripten version: Unknown")
    endif()

    #==============================================================================
    # Emscripten Compiler Settings
    #==============================================================================

    # Set C++ standard for Emscripten
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
    set(CMAKE_CXX_EXTENSIONS FALSE)

    # Emscripten-specific compiler flags
    # Note: Most Emscripten settings should be in linker flags, not compiler flags

    # Enable WebGPU support (experimental)
    option(VNE_ENABLE_WEBGPU "Enable WebGPU support (experimental)" OFF)
    if(VNE_ENABLE_WEBGPU)
        message(STATUS "WebGPU support enabled")
    endif()

    #==============================================================================
    # Emscripten Linker Settings
    #==============================================================================

    # Set output format to HTML
    set(CMAKE_EXECUTABLE_SUFFIX ".html")

    # Emscripten linker flags
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s USE_WEBGL2=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s FULL_ES3=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s ALLOW_MEMORY_GROWTH=1")
    # Increase initial memory for shader compilation (shaderc/glslang need significant memory)
    # Initial heap: 64MB (default is 16MB, which is too small for shader compilation)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s INITIAL_MEMORY=67108864")
    # Maximum memory: 2GB (default, but explicit for clarity)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s MAXIMUM_MEMORY=2147483648")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s USE_GLFW=3")

    # Enable GLFW for window management
    # Note: GLFW_WINDOW_TITLE is not a valid Emscripten setting

    # WebGPU support
    if(VNE_ENABLE_WEBGPU)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s USE_WEBGPU=1")
    endif()

    #==============================================================================
    # Emscripten Platform Configuration
    #==============================================================================

    # Disable desktop-specific features
    set(BUILD_GLFW OFF)
    # Keep ImGui enabled for web - it works with OpenGL ES
    # set(BUILD_IMGUI OFF)
    set(BUILD_SPDLOG OFF)

    # Enable OpenGL ES backend for web platform
    set(VNE_ENABLE_WEBGL OFF)
    set(VNE_ENABLE_OPENGL OFF)
    set(VNE_ENABLE_OPENGLES ON)
    set(VNE_ENABLE_VULKAN OFF)
    set(VNE_ENABLE_METAL OFF)
    set(VNE_ENABLE_DIRECTX11 OFF)
    set(VNE_ENABLE_DIRECTX12 OFF)

    #==============================================================================
    # Emscripten Build Options
    #==============================================================================

    # Optimization level for Web builds
    option(VNE_WEB_OPTIMIZATION "Enable optimization for Web builds" ON)
    if(VNE_WEB_OPTIMIZATION)
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O2")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -O2")
    endif()

    # Enable source maps for debugging
    option(VNE_WEB_SOURCE_MAPS "Enable source maps for Web debugging" OFF)
    if(VNE_WEB_SOURCE_MAPS)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -g4")
    endif()

    # Enable WebGL debugging
    option(VNE_WEBGL_DEBUG "Enable WebGL debugging" OFF)
    if(VNE_WEBGL_DEBUG)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s GL_DEBUG=1")
    endif()

    #==============================================================================
    # Emscripten HTML Template
    #==============================================================================

    # Set custom HTML template if provided
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/web/template.html")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --shell-file ${CMAKE_CURRENT_SOURCE_DIR}/web/template.html")
        message(STATUS "Using custom HTML template: ${CMAKE_CURRENT_SOURCE_DIR}/web/template.html")
    endif()

    #==============================================================================
    # Emscripten Testing Configuration
    #==============================================================================

    # Configure testing for Web platform
    if(ENABLE_TESTING)
        # Set test timeout for Web platform (longer due to compilation)
        set(CTEST_TEST_TIMEOUT 300)

        # Configure test environment for Web
        set(TEST_WEB_PLATFORM TRUE)
    endif()

    #==============================================================================
    # Emscripten Development Server
    #==============================================================================

    # Function to start Emscripten development server
    function(vne_start_web_server target_name)
        if(EMSCRIPTEN)
            add_custom_target(${target_name}_serve
                COMMAND ${CMAKE_COMMAND} -E echo "Starting Emscripten development server..."
                COMMAND python3 -m http.server 8000
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                COMMENT "Starting development server for ${target_name}"
            )
            message(STATUS "Development server target created: ${target_name}_serve")
        endif()
    endfunction()

    #==============================================================================
    # Emscripten Build Commands
    #==============================================================================

    # Function to configure Emscripten build
    function(vne_configure_emscripten_target target_name)
        if(EMSCRIPTEN)
            # Set target properties for Emscripten
            set_target_properties(${target_name} PROPERTIES
                SUFFIX ".html"
                LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS}"
            )

            # Add custom build step to copy assets
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/web/assets")
                add_custom_command(TARGET ${target_name} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_directory
                    "${CMAKE_CURRENT_SOURCE_DIR}/web/assets"
                    "${CMAKE_CURRENT_BINARY_DIR}/assets"
                    COMMENT "Copying web assets for ${target_name}"
                )
            endif()

            message(STATUS "Emscripten target configured: ${target_name}")
        endif()
    endfunction()

    #==============================================================================
    # Emscripten Environment Setup
    #==============================================================================

    # Function to setup Emscripten environment
    function(vne_setup_emscripten_env)
        if(EMSCRIPTEN)
            # Set environment variables for Emscripten
            set(ENV{EMSDK} "${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/emsdk")

            # Source Emscripten environment
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/emsdk/emsdk_env.sh")
                execute_process(
                    COMMAND bash -c "source ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/emsdk/emsdk_env.sh && env"
                    OUTPUT_VARIABLE EMSDK_ENV
                )
                message(STATUS "Emscripten environment sourced")
            endif()
        endif()
    endfunction()

    # Call environment setup
    vne_setup_emscripten_env()

    message(STATUS "Emscripten integration configured successfully")

else()
    message(STATUS "Not building for Emscripten - skipping Web configuration")
endif()
