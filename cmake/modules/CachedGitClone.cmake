# Cached Git Clone Script for ExternalProject_Add
#
# This script implements a local caching mechanism for git repositories
# to speed up repeated builds by avoiding full remote clones.
#
# Expected variables (passed via -D):
#   GIT_URL     - Git repository URL
#   GIT_TAG     - Tag or branch to checkout
#   CACHE_DIR   - Local cache directory (persistent storage)
#   SOURCE_DIR  - ExternalProject source directory
#
# Copyright (c) 2015-2026, Gilles Caulier, <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

# Step 1: Clone or update the cache repository
# Add safe.directory configuration to handle Docker environments where UID may differ
execute_process(
    COMMAND git config --global --add safe.directory "${CACHE_DIR}"
    RESULT_VARIABLE GIT_CONFIG_RESULT
    ERROR_VARIABLE GIT_CONFIG_ERROR
)
if(NOT GIT_CONFIG_RESULT EQUAL 0)
    message(WARNING "CachedGitClone: Failed to add safe.directory config (non-fatal):\n${GIT_CONFIG_ERROR}")
endif()

if(NOT EXISTS "${CACHE_DIR}/.git")
    message(STATUS "CachedGitClone: Cloning ${GIT_URL} to cache directory ${CACHE_DIR}")
    get_filename_component(CACHE_PARENT_DIR "${CACHE_DIR}" DIRECTORY)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CACHE_PARENT_DIR}"
    )
    execute_process(
        COMMAND git clone "${GIT_URL}" "${CACHE_DIR}"
        RESULT_VARIABLE GIT_CLONE_RESULT
        OUTPUT_VARIABLE GIT_CLONE_OUTPUT
        ERROR_VARIABLE GIT_CLONE_ERROR
    )
    if(NOT GIT_CLONE_RESULT EQUAL 0)
        message(FATAL_ERROR "CachedGitClone: Failed to clone ${GIT_URL} to cache:\n${GIT_CLONE_ERROR}")
    endif()
else()
    message(STATUS "CachedGitClone: Cache exists at ${CACHE_DIR}, fetching updates...")
    execute_process(
        COMMAND git -C "${CACHE_DIR}" fetch origin --tags --force
        RESULT_VARIABLE GIT_FETCH_RESULT
        OUTPUT_VARIABLE GIT_FETCH_OUTPUT
        ERROR_VARIABLE GIT_FETCH_ERROR
    )
    if(NOT GIT_FETCH_RESULT EQUAL 0)
        message(WARNING "CachedGitClone: Failed to fetch from origin (may be offline):\n${GIT_FETCH_ERROR}")
    endif()
endif()

# Step 2: Clone from cache to source directory (using hard links for speed)
# Add safe.directory configuration for source directory as well
execute_process(
    COMMAND git config --global --add safe.directory "${SOURCE_DIR}"
    RESULT_VARIABLE GIT_CONFIG_SRC_RESULT
    ERROR_VARIABLE GIT_CONFIG_SRC_ERROR
)
if(NOT GIT_CONFIG_SRC_RESULT EQUAL 0)
    message(WARNING "CachedGitClone: Failed to add safe.directory config for source (non-fatal):\n${GIT_CONFIG_SRC_ERROR}")
endif()

if(NOT EXISTS "${SOURCE_DIR}/.git")
    message(STATUS "CachedGitClone: Creating local clone from cache to ${SOURCE_DIR}")
    execute_process(
        COMMAND git clone --local --no-checkout "${CACHE_DIR}" "${SOURCE_DIR}"
        RESULT_VARIABLE GIT_LOCAL_CLONE_RESULT
        OUTPUT_VARIABLE GIT_LOCAL_CLONE_OUTPUT
        ERROR_VARIABLE GIT_LOCAL_CLONE_ERROR
    )
    if(NOT GIT_LOCAL_CLONE_RESULT EQUAL 0)
        message(FATAL_ERROR "CachedGitClone: Failed to clone from cache to source:\n${GIT_LOCAL_CLONE_ERROR}")
    endif()
else()
    message(STATUS "CachedGitClone: Source directory already exists, fetching updates from cache...")
    execute_process(
        COMMAND git -C "${SOURCE_DIR}" fetch origin --tags --force
        RESULT_VARIABLE GIT_SOURCE_FETCH_RESULT
        OUTPUT_VARIABLE GIT_SOURCE_FETCH_OUTPUT
        ERROR_VARIABLE GIT_SOURCE_FETCH_ERROR
    )
    if(NOT GIT_SOURCE_FETCH_RESULT EQUAL 0)
        message(WARNING "CachedGitClone: Failed to fetch in source directory:\n${GIT_SOURCE_FETCH_ERROR}")
    endif()
endif()

# Step 3: Checkout the target tag in source directory
message(STATUS "CachedGitClone: Checking out ${GIT_TAG} in ${SOURCE_DIR}")
execute_process(
    COMMAND git -C "${SOURCE_DIR}" checkout -f "${GIT_TAG}"
    RESULT_VARIABLE GIT_CHECKOUT_RESULT
    OUTPUT_VARIABLE GIT_CHECKOUT_OUTPUT
    ERROR_VARIABLE GIT_CHECKOUT_ERROR
)
if(NOT GIT_CHECKOUT_RESULT EQUAL 0)
    message(FATAL_ERROR "CachedGitClone: Failed to checkout ${GIT_TAG}:\n${GIT_CHECKOUT_ERROR}")
endif()

message(STATUS "CachedGitClone: Successfully prepared ${GIT_TAG} in ${SOURCE_DIR}")
