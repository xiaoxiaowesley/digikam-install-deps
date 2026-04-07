# Script to build static version of OpenSSL
#
# SPDX-FileCopyrightText: 2015-2026 by Gilles Caulier  <caulier dot gilles at gmail dot com>
#
# SPDX-License-Identifier: BSD-3-Clause
#

if (NOT APPLE)

    SET(EXTPREFIX_openssl "${EXTPREFIX}/local/")

    ExternalProject_Add(ext_openssl

        DOWNLOAD_COMMAND ${CMAKE_COMMAND}
            -DGIT_URL=https://github.com/jimmy-park/openssl-cmake.git
            -DGIT_TAG=3.6.1
            -DCACHE_DIR=${GIT_CLONE_CACHE_DIR}/openssl-cmake
            -DSOURCE_DIR=<SOURCE_DIR>
            -P ${CACHED_GIT_CLONE_SCRIPT}

        INSTALL_DIR ${EXTPREFIX_openssl}

        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX_openssl}
                   -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
                   -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE
                   -DCPM_SOURCE_CACHE=${EXTERNALS_DOWNLOAD_DIR}/cpm_cache
                   -DOPENSSL_BUILD_VERBOSE=ON
                   -DOPENSSL_ENABLE_PARALLEL=OFF
                   -DOPENSSL_INSTALL=ON
                   -DOPENSSL_INSTALL_CERT=OFF
                   -DOPENSSL_TEST=OFF
                   -DOPENSSL_USE_CCACHE=OFF
                   ${GLOBAL_PROFILE}

        BUILD_COMMAND ${BUILD_CLI}

        UPDATE_COMMAND ""
        ALWAYS 0
    )

endif()
