#==============================================================================
# Copyright (c) 2024 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   January 2025
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# Zlib Configuration
#==============================================================================

# Option to enable/disable zlib
option(BUILD_ZLIB "Build and link zlib library" OFF)

if(BUILD_ZLIB)
    # Check if zlib submodule exists
    if(NOT EXISTS "${VNE_THIRD_PARTY_DIR}/zlib/CMakeLists.txt")
        message(FATAL_ERROR "The ZLIB submodule was not downloaded! Please update submodules and try again.")
    endif()

    # Use the zlib wrapper to fix include directory issues
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/zlib_wrapper.cmake)
else()
    # Create a dummy interface library when zlib is disabled
    if(NOT TARGET Zlib)
        add_library(Zlib INTERFACE)
        message(STATUS "Created dummy Zlib interface library (zlib disabled)")
    endif()

    # Set zlib variables for compatibility
    set(ZLIB_FOUND FALSE)
    set(ZLIB_INCLUDE_DIRS "")
    set(ZLIB_LIBRARIES "")

    # Print configuration summary
    message(STATUS "ZLIB Configuration:")
    message(STATUS "  Status: DISABLED")
endif()
