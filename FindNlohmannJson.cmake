# ==============================================================================
# Find nlohmann/json (from submodule or system package)
# ==============================================================================

# Check if nlohmann/json is already available
if(TARGET nlohmann_json::nlohmann_json)
    set(NLOHMANN_JSON_FOUND TRUE)
    return()
endif()

# Try to find system package first
find_package(nlohmann_json QUIET)

if(nlohmann_json_FOUND)
    set(NLOHMANN_JSON_FOUND TRUE)
    add_compile_definitions(VNE_NLOHMANN_JSON_AVAILABLE)
    message(STATUS "Found nlohmann/json: system package")
    return()
endif()

# Try to use submodule (3rd_party/nlohmann_json)
set(NLOHMANN_JSON_SUBMODULE_DIR "${CMAKE_SOURCE_DIR}/3rd_party/nlohmann_json")

if(EXISTS "${NLOHMANN_JSON_SUBMODULE_DIR}/CMakeLists.txt")
    # Add submodule as a subdirectory
    add_subdirectory("${NLOHMANN_JSON_SUBMODULE_DIR}" "${CMAKE_BINARY_DIR}/3rd_party/nlohmann_json" EXCLUDE_FROM_ALL)

    if(TARGET nlohmann_json::nlohmann_json)
        set(NLOHMANN_JSON_FOUND TRUE)
        add_compile_definitions(VNE_NLOHMANN_JSON_AVAILABLE)
        message(STATUS "Found nlohmann/json: using submodule at ${NLOHMANN_JSON_SUBMODULE_DIR}")
        return()
    endif()
endif()

# If submodule not found, provide helpful error
message(FATAL_ERROR
    "nlohmann/json not found. Options:\n"
    "  1. Initialize submodule: git submodule update --init --recursive\n"
    "  2. Install system package: brew install nlohmann-json (macOS)\n"
    "  3. The submodule should be at: ${NLOHMANN_JSON_SUBMODULE_DIR}"
)

