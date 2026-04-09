#!/bin/bash

################################################################################
#
# Script to symlink apt-installed QtWebEngine to /opt/qt6/
# This allows using system QtWebEngine with custom Qt6 installation.
#
# Usage: sudo ./symlink-qtwebengine.sh
#
################################################################################

set -e

QT6_INSTALL_DIR="/opt/qt6"

echo "========================================="
echo "Linking QtWebEngine to ${QT6_INSTALL_DIR}"
echo "========================================="

# Check if Qt6 is installed
if [ ! -d "${QT6_INSTALL_DIR}" ]; then
    echo "Error: Qt6 installation not found at ${QT6_INSTALL_DIR}"
    exit 1
fi

# Check if QtWebEngine is installed via apt
if ! dpkg -l | grep -q qt6-webengine-dev; then
    echo "Warning: qt6-webengine-dev package not found."
    echo "Please install it first: sudo apt install qt6-webengine-dev"
    exit 1
fi

echo "Found qt6-webengine-dev package installed."

# Create symbolic links for libraries
echo ""
echo "Linking libraries..."
WEBENGINE_LIBS=$(find /usr/lib/aarch64-linux-gnu -name "libQt6WebEngine*" -o -name "libQt6Pdf*" 2>/dev/null)

if [ -n "${WEBENGINE_LIBS}" ]; then
    for lib in ${WEBENGINE_LIBS}; do
        libname=$(basename "${lib}")
        target="${QT6_INSTALL_DIR}/lib/${libname}"
        
        if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
            ln -s "${lib}" "${target}"
            echo "  Linked: ${libname}"
        else
            echo "  Skipped (exists): ${libname}"
        fi
    done
else
    echo "  No QtWebEngine libraries found in /usr/lib/aarch64-linux-gnu"
fi

# Create symbolic links for headers
echo ""
echo "Linking headers..."
WEBENGINE_HEADERS=$(find /usr/include/aarch64-linux-gnu/qt6 -name "QtWebEngine*" -o -name "QtPdf*" 2>/dev/null | head -20)

if [ -n "${WEBENGINE_HEADERS}" ]; then
    for header_dir in ${WEBENGINE_HEADERS}; do
        dirname=$(basename "${header_dir}")
        target="${QT6_INSTALL_DIR}/include/${dirname}"
        
        if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
            ln -s "${header_dir}" "${target}"
            echo "  Linked: ${dirname}"
        else
            echo "  Skipped (exists): ${dirname}"
        fi
    done
else
    echo "  No QtWebEngine headers found"
fi

# Create symbolic links for CMake configs
echo ""
echo "Linking CMake configurations..."
WEBENGINE_CMAKE=$(find /usr/lib/aarch64-linux-gnu/cmake -name "Qt6WebEngine*" -o -name "Qt6Pdf*" 2>/dev/null)

if [ -n "${WEBENGINE_CMAKE}" ]; then
    for cmake_dir in ${WEBENGINE_CMAKE}; do
        dirname=$(basename "${cmake_dir}")
        target="${QT6_INSTALL_DIR}/lib/cmake/${dirname}"
        
        # Create target directory if it doesn't exist
        mkdir -p "${QT6_INSTALL_DIR}/lib/cmake"
        
        if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
            ln -s "${cmake_dir}" "${target}"
            echo "  Linked: ${dirname}"
        else
            echo "  Skipped (exists): ${dirname}"
        fi
    done
else
    echo "  No QtWebEngine CMake configs found"
fi

# Create symbolic links for QML modules
echo ""
echo "Linking QML modules..."
WEBENGINE_QML=$(find /usr/lib/aarch64-linux-gnu/qt6/qml -name "QtWebEngine*" -o -name "QtPdf*" 2>/dev/null)

if [ -n "${WEBENGINE_QML}" ]; then
    for qml_dir in ${WEBENGINE_QML}; do
        dirname=$(basename "${qml_dir}")
        target="${QT6_INSTALL_DIR}/qml/${dirname}"
        
        # Create target directory if it doesn't exist
        mkdir -p "${QT6_INSTALL_DIR}/qml"
        
        if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
            ln -s "${qml_dir}" "${target}"
            echo "  Linked: ${dirname}"
        else
            echo "  Skipped (exists): ${dirname}"
        fi
    done
else
    echo "  No QtWebEngine QML modules found"
fi

# Create symbolic links for plugins
echo ""
echo "Linking plugins..."
WEBENGINE_PLUGINS=$(find /usr/lib/aarch64-linux-gnu/qt6/plugins -name "*webengine*" -o -name "*pdf*" 2>/dev/null)

if [ -n "${WEBENGINE_PLUGINS}" ]; then
    for plugin in ${WEBENGINE_PLUGINS}; do
        pluginname=$(basename "${plugin}")
        target="${QT6_INSTALL_DIR}/plugins/${pluginname}"
        
        # Create target directory if it doesn't exist
        mkdir -p "${QT6_INSTALL_DIR}/plugins"
        
        if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
            ln -s "${plugin}" "${target}"
            echo "  Linked: ${pluginname}"
        else
            echo "  Skipped (exists): ${pluginname}"
        fi
    done
else
    echo "  No QtWebEngine plugins found"
fi

echo ""
echo "========================================="
echo "QtWebEngine linking complete!"
echo "========================================="
echo ""
echo "You can verify the links with:"
echo "  ls -la ${QT6_INSTALL_DIR}/lib/libQt6WebEngine*"
echo "  ls -la ${QT6_INSTALL_DIR}/lib/cmake/Qt6WebEngine*"
echo ""
