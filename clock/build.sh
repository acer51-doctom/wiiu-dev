#!/bin/bash

# Default: Silent exit on error
set -e

# --- Verbose Logic ---
VERBOSE=false
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=true
    echo "!!! Verbose Mode Active !!!"
    set -x # Print commands as they run
fi

# Configuration
APP_NAME="AnotherClock4WiiU"
BUILD_DIR="build"
ZIP_STAGING="zip_staging"
FINAL_ZIP="AnotherClock4WiiU_Release.zip"

# Path Exports for Intel Mac
export DEVKITPRO=/opt/devkitpro
export DEVKITPPC=$DEVKITPRO/devkitPPC
export PATH=$PATH:$DEVKITPRO/tools/bin:$DEVKITPPC/bin

echo "This build file is made for MACOS! Linux has NOT been tested!"
echo "Checking for devkitPPC compiler..."

if [ ! -f "$DEVKITPPC/bin/powerpc-eabi-gcc" ]; then
    echo "ERROR: PowerPC compiler not found at $DEVKITPPC/bin/powerpc-eabi-gcc"
    echo "Please ensure devkitPPC or devkitPro is installed."
    exit 1
fi

# Only countdown if NOT in verbose mode (keeps logs cleaner)
if [ "$VERBOSE" = false ]; then
    echo "Compiler found. Starting countdown..."
    for i in {5..1}; do
        echo "$i..."
        sleep 1
    done
    echo "GO!"
fi

echo "--- Cleaning Environment ---"
rm -rf "$BUILD_DIR"
rm -rf "$ZIP_STAGING"
rm -f "$FINAL_ZIP"

mkdir -p "$BUILD_DIR"
mkdir -p "$ZIP_STAGING/wiiu/apps/$APP_NAME"

echo "--- Compiling ---"
cd "$BUILD_DIR"

# Adjust CMake verbosity based on flag
CMAKE_LOG_LEVEL="STATUS"
if [ "$VERBOSE" = true ]; then
    CMAKE_LOG_LEVEL="DEBUG"
fi

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=$DEVKITPRO/wut/share/wut.toolchain.cmake \
    -DCMAKE_C_COMPILER=$DEVKITPPC/bin/powerpc-eabi-gcc \
    -DCMAKE_CXX_COMPILER=$DEVKITPPC/bin/powerpc-eabi-g++ \
    -DCMAKE_ASM_COMPILER=$DEVKITPPC/bin/powerpc-eabi-as \
    --log-level=$CMAKE_LOG_LEVEL

# If verbose, tell 'make' to show every command string
if [ "$VERBOSE" = true ]; then
    make VERBOSE=1
else
    make
fi
cd ..

echo "--- Organizing Files ---"
if [ -f "$BUILD_DIR/$APP_NAME.rpx" ]; then
    cp "$BUILD_DIR/$APP_NAME.rpx" "$ZIP_STAGING/wiiu/apps/$APP_NAME/"
    cp "$BUILD_DIR/$APP_NAME.wuhb" "$ZIP_STAGING/wiiu/apps/$APP_NAME/"
    cp "$BUILD_DIR/${APP_NAME}_legacy.elf" "$ZIP_STAGING/wiiu/apps/$APP_NAME/$APP_NAME.elf"
else
    echo "Build failed: Output files not found."
    exit 1
fi

if [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$ZIP_STAGING/wiiu/apps/$APP_NAME/icon.png"
fi

echo "--- Creating ZIP ---"
cd "$ZIP_STAGING"
if [ "$VERBOSE" = true ]; then
    zip -r "../$FINAL_ZIP" .
else
    zip -rq "../$FINAL_ZIP" . # 'q' for quiet
fi
cd ..

echo "--- Success! ---"
echo "Your release package is ready: $FINAL_ZIP"
echo "Just drag and drop to your SD Card!"