# Script to build libjasper
#
# Copyright (c) 2015-2026 by Gilles Caulier  <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

SET(PREFIX_ext_jasper "${EXTPREFIX}")

ExternalProject_Add(ext_jasper
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
        -DGIT_URL=https://github.com/jasper-software/jasper.git
        -DGIT_TAG=version-4.2.9
        -DCACHE_DIR=${GIT_CLONE_CACHE_DIR}/jasper
        -DSOURCE_DIR=<SOURCE_DIR>
        -P ${CACHED_GIT_CLONE_SCRIPT}

    INSTALL_DIR ${PREFIX_ext_jasper}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${PREFIX_ext_jasper}
               -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
               ${GLOBAL_PROFILE}
               -DCMAKE_SYSTEM_PREFIX_PATH=${PREFIX_ext_jasper}
               -DJAS_ENABLE_SHARED=ON
               -DJAS_ENABLE_LIBJPEG=ON
               -DJAS_ENABLE_LIBHEIF=OFF
               -DJAS_ENABLE_OPENGL=ON
               -DJAS_ENABLE_DOC=OFF
               -DJAS_ENABLE_LATEX=OFF
               -DJAS_ENABLE_PROGRAMS=OFF
               -DJAS_ENABLE_MULTITHREADING_SUPPORT=ON
               -DJAS_ENABLE_CMAKE_PACKAGE_CONFIG=OFF
               -DJAS_ENABLE_PIC=ON
               -DJAS_ENABLE_HIDDEN=ON
               -DJAS_ENABLE_32BIT=OFF
               -DJAS_LOCAL=OFF
               -DJAS_PACKAGING=OFF
               -DJAS_STRICT=OFF
               -Wno-dev

    UPDATE_COMMAND ""
    ALWAYS 0
)
