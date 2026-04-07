# Script to build Cmake.
#
# Copyright (c) 2015-2026 by Gilles Caulier  <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

SET(EXTPREFIX_cmake "${EXTPREFIX}")

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
