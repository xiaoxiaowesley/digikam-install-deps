# Cached URL Download Script for ExternalProject_Add
#
# This script implements a local caching mechanism for URL-based downloads
# to avoid redundant downloads on repeated builds.
#
# Expected variables (passed via -D):
#   DOWNLOAD_URL - URL to download from
#   FILE_NAME    - Filename for the cached archive
#   FILE_MD5     - Expected MD5 hash of the file
#   CACHE_DIR    - Directory to store cached downloads
#   SOURCE_DIR   - ExternalProject source directory
#
# Copyright (c) 2015-2026, Gilles Caulier, <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

set(CACHED_FILE "${CACHE_DIR}/${FILE_NAME}")

# Step 1: Check if source already exists (previously extracted)
if(EXISTS "${SOURCE_DIR}/CMakeLists.txt")
    message(STATUS "CachedUrlDownload: Source already exists at ${SOURCE_DIR}, skipping")
    return()
endif()

# Step 2: Download to cache if file not found
file(MAKE_DIRECTORY "${CACHE_DIR}")

if(NOT EXISTS "${CACHED_FILE}")
    message(STATUS "CachedUrlDownload: Downloading ${DOWNLOAD_URL}")
    message(STATUS "CachedUrlDownload: Saving to ${CACHED_FILE}")
    file(DOWNLOAD "${DOWNLOAD_URL}" "${CACHED_FILE}"
         EXPECTED_MD5 "${FILE_MD5}"
         SHOW_PROGRESS
         STATUS DOWNLOAD_STATUS
    )
    list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
    if(NOT STATUS_CODE EQUAL 0)
        file(REMOVE "${CACHED_FILE}")
        list(GET DOWNLOAD_STATUS 1 ERROR_MSG)
        message(FATAL_ERROR "CachedUrlDownload: Download failed: ${ERROR_MSG}")
    endif()
    message(STATUS "CachedUrlDownload: Download complete")
else()
    message(STATUS "CachedUrlDownload: Using cached file ${CACHED_FILE}")
    # Verify MD5 of cached file
    file(MD5 "${CACHED_FILE}" ACTUAL_MD5)
    if(NOT "${ACTUAL_MD5}" STREQUAL "${FILE_MD5}")
        message(STATUS "CachedUrlDownload: MD5 mismatch (expected ${FILE_MD5}, got ${ACTUAL_MD5}), re-downloading...")
        file(REMOVE "${CACHED_FILE}")
        file(DOWNLOAD "${DOWNLOAD_URL}" "${CACHED_FILE}"
             EXPECTED_MD5 "${FILE_MD5}"
             SHOW_PROGRESS
             STATUS DOWNLOAD_STATUS
        )
        list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
        if(NOT STATUS_CODE EQUAL 0)
            file(REMOVE "${CACHED_FILE}")
            list(GET DOWNLOAD_STATUS 1 ERROR_MSG)
            message(FATAL_ERROR "CachedUrlDownload: Re-download failed: ${ERROR_MSG}")
        endif()
    endif()
endif()

# Step 3: Extract to source directory
get_filename_component(EXTRACT_DIR "${SOURCE_DIR}" DIRECTORY)
file(MAKE_DIRECTORY "${EXTRACT_DIR}")

message(STATUS "CachedUrlDownload: Extracting ${FILE_NAME} to ${EXTRACT_DIR}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xJf "${CACHED_FILE}"
    WORKING_DIRECTORY "${EXTRACT_DIR}"
    RESULT_VARIABLE EXTRACT_RESULT
)
if(NOT EXTRACT_RESULT EQUAL 0)
    message(FATAL_ERROR "CachedUrlDownload: Failed to extract ${CACHED_FILE}")
endif()

# Step 4: If extraction created a single subdirectory, rename it to SOURCE_DIR
if(NOT EXISTS "${SOURCE_DIR}")
    file(GLOB EXTRACTED_CONTENTS "${EXTRACT_DIR}/*")
    # Filter to only directories
    set(EXTRACTED_DIRS)
    foreach(item ${EXTRACTED_CONTENTS})
        if(IS_DIRECTORY "${item}")
            list(APPEND EXTRACTED_DIRS "${item}")
        endif()
    endforeach()
    list(LENGTH EXTRACTED_DIRS NUM_DIRS)
    if(NUM_DIRS EQUAL 1)
        list(GET EXTRACTED_DIRS 0 EXTRACTED_ITEM)
        message(STATUS "CachedUrlDownload: Renaming ${EXTRACTED_ITEM} to ${SOURCE_DIR}")
        file(RENAME "${EXTRACTED_ITEM}" "${SOURCE_DIR}")
    endif()
endif()

message(STATUS "CachedUrlDownload: Successfully prepared source at ${SOURCE_DIR}")
