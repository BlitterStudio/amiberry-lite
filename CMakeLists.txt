cmake_minimum_required(VERSION 3.16)

# Enforce modern CMake behavior for find_package and policy resolution
if(POLICY CMP0074)
    cmake_policy(SET CMP0074 NEW)
endif()
if(POLICY CMP0091)
    cmake_policy(SET CMP0091 NEW) # MSVC runtime selection
endif()
if(POLICY CMP0177)
    cmake_policy(SET CMP0177 NEW) # Normalize install() DESTINATION paths
endif()

project(amiberry-lite
    VERSION 5.9.2
    LANGUAGES C CXX ASM
    DESCRIPTION "Optimized Amiga emulator for various platforms"
    HOMEPAGE_URL "https://amiberry.com"
)

# Enforce C++17 explicitly across all toolchains
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# IDE & Tooling support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Export compile_commands.json" FORCE)

# Prevent in-tree builds
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    message(FATAL_ERROR "In-tree builds are not supported. Use a separate build directory.")
endif()

# Set CMake module path
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

# Platform-specific include/link path variables; initialized here (before any
# platform block appends to them) and populated in
# cmake/StandardProjectSettings.cmake, applied to the target in
# cmake/SourceFiles.cmake.
set(AMIBERRY_PLATFORM_INCLUDE_DIRS "")
set(AMIBERRY_PLATFORM_LINK_DIRS "")
set(AMIBERRY_PLATFORM_LIBS "")

# Feature options
option(USE_PCEM          "Use PCem for hardware emulation (no support for RISC-V)" OFF)
option(USE_LIBSERIALPORT "Use LibSerialPort for serial port emulation" ON)
option(USE_LIBENET       "Use LibENET for network emulation" ON)
option(USE_PORTMIDI      "Use PortMidi for MIDI emulation" ON)
option(USE_LIBMPEG2      "Use LibMPEG2 for CD32 FMV support" ON)
option(USE_UAENET_PCAP   "Use libpcap for uaenet (Linux/macOS)" OFF)
option(USE_ZSTD 	     "Use Zstandard for CHD compressed disk images" ON)
option(USE_GPIOD         "Use GPIOD to control GPIO LEDs" OFF)
option(USE_DBUS          "Use DBus to control the emulator" OFF)
option(USE_OPENGL        "Use OpenGL for rendering (currently WIP)" OFF)
option(WITH_LTO          "Enable Link Time Optimization" OFF)
option(WITH_PGO_GENERATE "Generate profile data for Profile-Guided Optimization" OFF)
option(WITH_PGO_USE      "Use profile data for Profile-Guided Optimization" OFF)
option(WITH_OPTIMIZE     "Enable GCC native CPU optimizations" OFF)
option(USE_IMGUI         "Use ImGui for the GUI" OFF)
set(PGO_PROFILE_DIR "" CACHE PATH "Directory containing Profile-Guided Optimization data")

# Automatically disable PCem on architectures without a PCem backend
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" ARCH_LOWER)
if(ARCH_LOWER MATCHES "riscv|loongarch")
    if(USE_PCEM)
        message(STATUS "Detected ${CMAKE_SYSTEM_PROCESSOR} architecture. Disabling USE_PCEM (no backend available).")
    endif()
    set(USE_PCEM OFF CACHE BOOL "Use PCem for hardware emulation (no backend for this architecture)" FORCE)
endif()

# Pre-release version suffix
set(VERSION_PRE_RELEASE "2" CACHE STRING "Pre-release version")
set(AMIBERRY_PRODUCT_VERSION "${PROJECT_VERSION}")
if(VERSION_PRE_RELEASE)
    set(AMIBERRY_PRODUCT_VERSION "${PROJECT_VERSION}-${VERSION_PRE_RELEASE}")
endif()

# Project identity & metadata
set(AMIBERRY_DISPLAY_NAME "Amiberry-Lite")
set(PROJECT_COMPANY_NAME "BlitterStudio")
set(PROJECT_COMPANY_NAMESPACE "com.blitterstudio")
file(WRITE "${CMAKE_BINARY_DIR}/amiberry-product-version.txt" "${AMIBERRY_PRODUCT_VERSION}\n")

# FreeBSD-specific paths and libraries
if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    list(APPEND AMIBERRY_PLATFORM_LINK_DIRS /usr/local/lib)
    find_library(LIBUSB_LIBRARY NAMES usb PATHS /usr/lib REQUIRED)
    if(NOT LIBUSB_LIBRARY)
        message(FATAL_ERROR "libusb not found in /usr/lib")
    endif()
endif()

# Install system and packaging
include(GNUInstallDirs)
set(AMIBERRY_PACKAGE_METADATA_EXCLUDES
    PATTERN ".DS_Store" EXCLUDE
    PATTERN "._*" EXCLUDE
    PATTERN "__MACOSX" EXCLUDE
    PATTERN ".AppleDouble" EXCLUDE
    PATTERN ".LSOverride" EXCLUDE
    PATTERN ".Spotlight-V100" EXCLUDE
    PATTERN ".Trashes" EXCLUDE
    PATTERN ".fseventsd" EXCLUDE
)
include(cmake/StandardProjectSettings.cmake)
include(cmake/SourceFiles.cmake)
include(cmake/Dependencies.cmake)

# Install rules may need dependency targets, so include them after dependency
# discovery.
if (CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    include(cmake/linux/install.cmake)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include(cmake/macos/install.cmake)
endif ()

include(packaging/CMakeLists.txt)
