#==============================================================================
# Copyright (c) 2025 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   JULY-2025
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# Swift Configuration for iOS/macOS
#==============================================================================

# Function to configure Swift target properties
function(configure_swift_target TARGET_NAME)
    if(NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "Target ${TARGET_NAME} not found")
    endif()
    
    # Set Swift-specific properties
    set_target_properties(${TARGET_NAME} PROPERTIES
        SWIFT_OPTIMIZATION_LEVEL "-Onone"
        SWIFT_VERSION "5.0"
        SWIFT_EMIT_LOC_STRINGS "NO"
        SWIFT_EMIT_LOC_STRINGS_FILE "NO"
    )
    
    # Set Xcode-specific attributes for Swift with explicit optimization settings
    set_target_properties(${TARGET_NAME} PROPERTIES
        XCODE_ATTRIBUTE_SWIFT_OPTIMIZATION_LEVEL "-Onone"
        XCODE_ATTRIBUTE_SWIFT_OPTIMIZATION_LEVEL_DEBUG "-Onone"
        XCODE_ATTRIBUTE_SWIFT_OPTIMIZATION_LEVEL_RELEASE "-Onone"
        XCODE_ATTRIBUTE_SWIFT_COMPILATION_MODE "singlefile"
        XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
        XCODE_ATTRIBUTE_SWIFT_EMIT_LOC_STRINGS "NO"
        XCODE_ATTRIBUTE_SWIFT_EMIT_LOC_STRINGS_FILE "NO"
        XCODE_ATTRIBUTE_SWIFT_EMIT_LOC_STRINGS_FILE_PATH ""
        XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/HelloWorldSwift-Bridging-Header.h"
        XCODE_ATTRIBUTE_SWIFT_OBJC_INTERFACE_HEADER_NAME "${TARGET_NAME}-Swift.h"
    )
    
    message(STATUS "Configured Swift target: ${TARGET_NAME}")
endfunction()

# Function to check Swift compiler availability
function(check_swift_compiler)
    if(CMAKE_Swift_COMPILER_WORKS)
        message(STATUS "Swift compiler is available")
    else()
        message(WARNING "Swift compiler not available - Swift targets will be disabled")
        set(SWIFT_AVAILABLE FALSE PARENT_SCOPE)
    endif()
endfunction()

# Check Swift compiler on Apple platforms
if(APPLE)
    check_swift_compiler()
endif() 