# Script to build Qt6.
#
# Copyright (c) 2015-2026 by Gilles Caulier <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

set(EXTPREFIX_qt ${EXTPREFIX})

message(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")

if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")

    set(QT_FILE_NAME qt-everywhere-src-6.10.2.tar.xz)
    set(QT_REMOTE_URL https://download.qt.io/official_releases/qt/6.10/6.10.2/single/${QT_FILE_NAME})
    set(QT_HASH c888eeca204d8ee144d9c57c2df9f8f4)

else() # Intel

    set(QT_FILE_NAME qt-everywhere-src-6.11.0.tar.xz)
    set(QT_REMOTE_URL https://download.qt.io/official_releases/qt/6.11/6.11.0/single/${QT_FILE_NAME})
    set(QT_HASH a93e9f424a9d11ee8d67bf8fb1af4772)

endif()

# Use local cached file if it exists, otherwise download from remote

set(QT_LOCAL_FILE "${EXTERNALS_DOWNLOAD_DIR}/${QT_FILE_NAME}")

if(EXISTS "${QT_LOCAL_FILE}")
    message(STATUS "Found local Qt6 archive: ${QT_LOCAL_FILE}, skipping download.")
    set(QT_URL "file://${QT_LOCAL_FILE}")
else()
    message(STATUS "Local Qt6 archive not found, will download from ${QT_REMOTE_URL}")
    set(QT_URL ${QT_REMOTE_URL})
endif()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/qt6_cmake_path.patch.cmake.in
               ${CMAKE_CURRENT_BINARY_DIR}/qt6_cmake_path.patch)

# Linux with G++ compiler

include("config-qt6-linux.cmake")

ExternalProject_Add(ext_qt6
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    URL ${QT_URL}
    URL_MD5 ${QT_HASH}

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/qt6-openssl-linked.patch &&
                  ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/qt611-fix-compile.patch &&
                  ${CMAKE_COMMAND} -E rm -rf <SOURCE_DIR>/qtwebengine

    CMAKE_ARGS -DOPENSSL_LIBS='-l${EXTPREFIX}/local/lib/libssl.a -l${EXTPREFIX}/local/lib/libcrypto.a -lpthread -ldl'
               -DOPENSSL_INCDIR='${EXTPREFIX}/local/include/openssl/'
               -DOPENSSL_LIBDIR='${EXTPREFIX}/local/lib'

    CONFIGURE_COMMAND <SOURCE_DIR>/configure ${QT_CONFIG}

    # Compile with Ninja build framework.
    BUILD_COMMAND ninja

    INSTALL_COMMAND ninja install

    UPDATE_COMMAND ""
    BUILD_IN_SOURCE 1
    ALWAYS 0
)
