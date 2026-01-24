#==============================================================================
# Copyright (c) 2024 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   JULY-2024
#
# Autodoc:   yes
#==============================================================================

#==============================================================================
# HeaderSetup.cmake
#==============================================================================

#==============================================================================
# Header Generation Functions
#==============================================================================

# Function to generate include stub files
function(generate_include_stub include_file source_file)
    # Get the relative path from include to source
    file(RELATIVE_PATH relative_path ${VNE_INCLUDE_DIR} ${source_file})
    
    # Create the include directory if it doesn't exist
    get_filename_component(include_dir ${include_file} DIRECTORY)
    file(MAKE_DIRECTORY ${include_dir})
    
    # Generate the include stub content
    set(stub_content "#pragma once\n")
    set(stub_content "${stub_content}#include \"${relative_path}\"\n")
    
    # Write the stub file
    file(WRITE ${include_file} ${stub_content})
    
    message(STATUS "Generated include stub: ${include_file} -> ${source_file}")
endfunction()

# Function to generate module-level include file
function(generate_module_include module_name header_files)
    set(module_include_file "${VNE_INCLUDE_DIR}/vertexnova/${module_name}.h")
    
    # Create the include directory if it doesn't exist
    get_filename_component(include_dir ${module_include_file} DIRECTORY)
    file(MAKE_DIRECTORY ${include_dir})
    
    # Generate the module include content
    set(module_content "#pragma once\n")
    set(module_content "${module_content}// ${module_name} module includes\n")
    set(module_content "${module_content}// Auto-generated - do not edit manually\n\n")
    
    foreach(header_file ${header_files})
        # Get the relative path from module include to individual header
        file(RELATIVE_PATH relative_path ${VNE_INCLUDE_DIR}/vertexnova ${header_file})
        set(module_content "${module_content}#include \"vertexnova/${relative_path}\"\n")
    endforeach()
    
    # Write the module include file
    file(WRITE ${module_include_file} ${module_content})
    
    message(STATUS "Generated module include: ${module_include_file}")
endfunction()

# Function to setup include paths for a target
function(setup_include_paths target_name)
    target_include_directories(${target_name}
        PUBLIC
            $<BUILD_INTERFACE:${VNE_INCLUDE_DIR}>
            $<INSTALL_INTERFACE:include>
    )
endfunction()

#==============================================================================
# Header Management Macros
#==============================================================================

# Macro to register headers for a module
macro(register_module_headers module_name)
    set(${module_name}_HEADERS ${ARGN})
    set(${module_name}_HEADERS ${${module_name}_HEADERS} PARENT_SCOPE)
endmacro()

# Macro to generate all include stubs for a module
macro(generate_module_stubs module_name)
    if(DEFINED ${module_name}_HEADERS)
        foreach(header_file ${${module_name}_HEADERS})
            # Get the source file path
            set(source_file "${VNE_SRC_DIR}/${module_name}/${header_file}")
            
            # Generate the include stub path
            set(include_file "${VNE_INCLUDE_DIR}/vertexnova/${module_name}/${header_file}")
            
            # Generate the stub
            generate_include_stub(${include_file} ${source_file})
        endforeach()
        
        # Generate module-level include file
        set(module_include_files)
        foreach(header_file ${${module_name}_HEADERS})
            list(APPEND module_include_files "${VNE_INCLUDE_DIR}/vertexnova/${module_name}/${header_file}")
        endforeach()
        generate_module_include(${module_name} "${module_include_files}")
    endif()
endmacro()

#==============================================================================
# Utility Functions
#==============================================================================

# Function to clean up generated include files
function(clean_generated_includes)
    if(EXISTS ${VNE_INCLUDE_DIR})
        file(REMOVE_RECURSE ${VNE_INCLUDE_DIR})
        message(STATUS "Cleaned generated include files")
    endif()
endfunction()

# Function to validate include structure
function(validate_include_structure)
    if(NOT EXISTS ${VNE_INCLUDE_DIR})
        message(FATAL_ERROR "Include directory does not exist: ${VNE_INCLUDE_DIR}")
    endif()
    
    # Check for common issues
    file(GLOB_RECURSE include_files "${VNE_INCLUDE_DIR}/*.h")
    foreach(include_file ${include_files})
        file(READ ${include_file} content)
        if(NOT content MATCHES "#pragma once")
            message(WARNING "Include file missing pragma once: ${include_file}")
        endif()
    endforeach()
    
    message(STATUS "Include structure validation complete")
endfunction() 