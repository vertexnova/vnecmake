#==============================================================================
# VneUseDep.cmake - Use a VertexNova dependency if already in build, else add it
#
# Bulletproof pattern for all modules: check TARGET first, then add_subdirectory
# only when the dependency is not already provided by a parent (e.g. vnescene,
# vneio) or another submodule. Use this for vnecommon, vnelogging, vnemath, etc.
#
# Usage:
#   vne_use_dep(TARGET vne::common SUBDIR "${DIR}/vnecommon" BINARY_DIR "${BIN}/vnecommon")
#   vne_use_dep(TARGET vne::logging SUBDIR "${DIR}/vnelogging" BINARY_DIR "${BIN}/vnelogging"
#               CACHE_VARS BUILD_TESTS OFF BUILD_EXAMPLES OFF)
#
# If TARGET already exists: nothing is done (message "using from parent").
# If SUBDIR/CMakeLists.txt exists: add_subdirectory(SUBDIR BINARY_DIR) with
# optional CACHE_VARS applied (and restored) around the add.
#==============================================================================

if(DEFINED VNE_USE_DEP_INCLUDED)
    return()
endif()
set(VNE_USE_DEP_INCLUDED TRUE)

function(vne_use_dep)
    set(oneValueArgs TARGET SUBDIR BINARY_DIR)
    set(multiValueArgs CACHE_VARS)
    cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "vne_use_dep: TARGET is required")
    endif()
    if(NOT ARG_SUBDIR)
        message(FATAL_ERROR "vne_use_dep: SUBDIR is required")
    endif()

    # If target already in build (e.g. added by parent), do nothing
    if(TARGET ${ARG_TARGET})
        message(STATUS "VneDep: using ${ARG_TARGET} from parent")
        return()
    endif()

    if(NOT EXISTS "${ARG_SUBDIR}/CMakeLists.txt")
        message(WARNING "VneDep: ${ARG_TARGET} not found at ${ARG_SUBDIR}")
        return()
    endif()

    message(STATUS "VneDep: adding ${ARG_TARGET} from ${ARG_SUBDIR}")

    # Optional: apply cache vars before add_subdirectory (caller restores if needed)
    if(ARG_CACHE_VARS)
        list(LENGTH ARG_CACHE_VARS _len)
        set(_i 0)
        while(_i LESS _len)
            list(GET ARG_CACHE_VARS ${_i} _var)
            math(EXPR _vi "${_i} + 1")
            if(_vi GREATER_EQUAL _len)
                break()
            endif()
            list(GET ARG_CACHE_VARS ${_vi} _val)
            if(_val MATCHES "^(ON|OFF|TRUE|FALSE|0|1)$")
                set(${_var} ${_val} CACHE BOOL "" FORCE)
            else()
                set(${_var} ${_val} CACHE STRING "" FORCE)
            endif()
            math(EXPR _i "${_i} + 2")
        endwhile()
    endif()

    if(ARG_BINARY_DIR)
        add_subdirectory(${ARG_SUBDIR} ${ARG_BINARY_DIR})
    else()
        add_subdirectory(${ARG_SUBDIR})
    endif()
endfunction()
