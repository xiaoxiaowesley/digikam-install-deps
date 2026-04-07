# Script to build Cmake.
#
# Copyright (c) 2015-2026 by Gilles Caulier  <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

SET(EXTPREFIX_cmake "${EXTPREFIX}")

# Check if CMake is already installed with the expected version.
SET(EXT_CMAKE_VERSION "4.3.0")
SET(EXT_CMAKE_BINARY "${EXTPREFIX_cmake}/bin/cmake")

if(EXISTS ${EXT_CMAKE_BINARY})
    execute_process(
        COMMAND ${EXT_CMAKE_BINARY} --version
        OUTPUT_VARIABLE _cmake_version_output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Extract version number from output like "cmake version 4.3.0"
    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" _cmake_installed_version "${_cmake_version_output}")

    if("${_cmake_installed_version}" VERSION_EQUAL "${EXT_CMAKE_VERSION}")
        message(STATUS "CMake ${EXT_CMAKE_VERSION} is already installed at ${EXTPREFIX_cmake}, skipping build.")
        add_custom_target(ext_cmake)
        return()
    else()
        message(STATUS "CMake version mismatch: installed=${_cmake_installed_version}, expected=${EXT_CMAKE_VERSION}. Rebuilding.")
    endif()
else()
    message(STATUS "CMake not found at ${EXT_CMAKE_BINARY}. Building from source.")
endif()

ExternalProject_Add(ext_cmake
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
        -DGIT_URL=https://github.com/Kitware/CMake.git
        -DGIT_TAG=v4.3.0
        -DCACHE_DIR=${GIT_CLONE_CACHE_DIR}/cmake
        -DSOURCE_DIR=<SOURCE_DIR>
        -P ${CACHED_GIT_CLONE_SCRIPT}

    INSTALL_DIR ${EXTPREFIX_cmake}

    CONFIGURE_COMMAND cd <SOURCE_DIR> && ./bootstrap --prefix=${EXTPREFIX_cmake}

    BUILD_COMMAND ${MAKE}

    UPDATE_COMMAND ""
    BUILD_IN_SOURCE 1
    ALWAYS 0
)
