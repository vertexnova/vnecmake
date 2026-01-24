# ----------------------------------------------------------------------
# Copyright (c) 2024 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   May-2024
#
# Autodoc:   yes
# ----------------------------------------------------------------------

# Enable automatic processing of Qt files
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Ensure compatibility with older CMake versions
if(CMAKE_VERSION VERSION_LESS "3.7.0")
    set(CMAKE_INCLUDE_CURRENT_DIR ON)
endif()

# Set Qt paths based on the operating system
if(EXISTS "${CMAKE_SOURCE_DIR}/3rd_party/qtbase")
    set(Qt6_DIR "${CMAKE_SOURCE_DIR}/3rd_party/qtbase/lib/cmake/Qt6")
    set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/3rd_party/qtbase/lib/cmake")
    message(STATUS "Using Qt submodule at ${CMAKE_SOURCE_DIR}/3rd_party/qtbase")
else()
    message(WARNING "Qt submodule not found! Please install Qt or add the submodule at 3rd_party/qtbase.")
endif()

# Find and configure the necessary Qt components
find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Gui Quick REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} CONFIG COMPONENTS Core Gui Quick REQUIRED)
