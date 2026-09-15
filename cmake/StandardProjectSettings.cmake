set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_ASM_COMPILER_ARG1 ${CMAKE_ASM_COMPILER_ARG1})
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM AND NOT CMAKE_C_COMPILER MATCHES "ccache")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set build type to "Release" if user did not specify any build type yet.
# Other possible values: Debug and None.
# This must run before any CMAKE_BUILD_TYPE-dependent logic below, so that a
# default build picks up the full Release flag set.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Clear out environment CFLAGS/CXXFLAGS first
if(CMAKE_BUILD_TYPE MATCHES "^(Release|Debug)$")
    set(CMAKE_C_FLAGS "")
    set(CMAKE_CXX_FLAGS "")
    set(CMAKE_EXE_LINKER_FLAGS "")
    set(CMAKE_SHARED_LINKER_FLAGS "")
endif()

# Accumulate compile and link flags in variables.
# These are applied to the ${PROJECT_NAME} target in SourceFiles.cmake after
# the target is created, so they do not leak into the external/ subdirectory
# builds (mt32emu, floppybridge, capsimage, guisan).
set(AMIBERRY_GNU_LIKE_COMPILER OFF)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(AMIBERRY_GNU_LIKE_COMPILER ON)
endif()

set(AMIBERRY_COMPILE_OPTIONS "")
if(AMIBERRY_GNU_LIKE_COMPILER)
    list(APPEND AMIBERRY_COMPILE_OPTIONS "-pipe")
endif()
set(AMIBERRY_LINK_OPTIONS "")

if(WITH_PGO_GENERATE OR WITH_PGO_USE)
    if(WITH_PGO_GENERATE AND WITH_PGO_USE)
        message(FATAL_ERROR "WITH_PGO_GENERATE and WITH_PGO_USE are mutually exclusive")
    endif()
    if(WITH_LTO)
        message(FATAL_ERROR "PGO and WITH_LTO are mutually exclusive")
    endif()
    if(NOT PGO_PROFILE_DIR)
        message(FATAL_ERROR "PGO_PROFILE_DIR must be set when PGO is enabled")
    endif()
    if(CMAKE_CONFIGURATION_TYPES OR NOT CMAKE_BUILD_TYPE STREQUAL "Release")
        message(FATAL_ERROR "PGO requires a single-config Release build")
    endif()

    if(WITH_PGO_GENERATE)
        list(APPEND AMIBERRY_COMPILE_OPTIONS
            "-fprofile-generate=${PGO_PROFILE_DIR}"
            "-fprofile-prefix-path=${CMAKE_BINARY_DIR}"
            "-fprofile-update=atomic"
        )
        list(APPEND AMIBERRY_LINK_OPTIONS "-fprofile-generate=${PGO_PROFILE_DIR}")
    else()
        list(APPEND AMIBERRY_COMPILE_OPTIONS
            "-fprofile-use=${PGO_PROFILE_DIR}"
            "-fprofile-prefix-path=${CMAKE_BINARY_DIR}"
            "-Werror=missing-profile"
            "-Werror=coverage-mismatch"
        )
        list(APPEND AMIBERRY_LINK_OPTIONS "-fprofile-use=${PGO_PROFILE_DIR}")
    endif()
endif()

# 32-bit ARM targets trap on unaligned accesses; keep strict alignment.
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^arm")
    list(APPEND AMIBERRY_COMPILE_OPTIONS "-mno-unaligned-access")
endif ()

# Tune default Linux aarch64 builds for the slowest supported board
# (Raspberry Pi 4 / Cortex-A72). -mtune only affects instruction scheduling;
# the ISA baseline stays generic armv8-a. Leave WITH_OPTIMIZE builds alone so
# their native CPU flags remain authoritative.
if(AMIBERRY_GNU_LIKE_COMPILER
        AND CMAKE_SYSTEM_NAME STREQUAL "Linux"
        AND ARCH_LOWER MATCHES "aarch64|arm64")
    set(AMIBERRY_ARM_TUNE "cortex-a72" CACHE STRING "CPU passed to -mtune for Linux aarch64 builds (set empty to disable)")
    if(WITH_OPTIMIZE)
        message(STATUS "Linux aarch64: WITH_OPTIMIZE enabled, not applying default -mtune=${AMIBERRY_ARM_TUNE}")
    elseif(AMIBERRY_ARM_TUNE)
        list(APPEND AMIBERRY_COMPILE_OPTIONS "-mtune=${AMIBERRY_ARM_TUNE}")
        message(STATUS "Linux aarch64: adding -mtune=${AMIBERRY_ARM_TUNE}")
    endif()
endif()

if(AMIBERRY_GNU_LIKE_COMPILER)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND AMIBERRY_COMPILE_OPTIONS "-Og" "-funwind-tables" "-DDEBUG")

        if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
            list(APPEND AMIBERRY_COMPILE_OPTIONS "-ggdb")
        else()
            list(APPEND AMIBERRY_COMPILE_OPTIONS "-g")
        endif()
    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        list(APPEND AMIBERRY_COMPILE_OPTIONS "-fdata-sections" "-ffunction-sections")
    elseif(CMAKE_BUILD_TYPE)
        list(APPEND AMIBERRY_COMPILE_OPTIONS "-O1")
    endif()
endif()

# Platform-specific linker flags
if(AMIBERRY_GNU_LIKE_COMPILER)
    if(NOT CMAKE_SYSTEM_NAME MATCHES "Darwin")
        # ELF linker flags (not for Apple platforms)
        list(APPEND AMIBERRY_LINK_OPTIONS "-Wl,--no-undefined" "-Wl,--as-needed" "-Wl,-z,combreloc")

        if(CMAKE_BUILD_TYPE STREQUAL "Release")
            list(APPEND AMIBERRY_LINK_OPTIONS
                "-Wl,--gc-sections"
                "-Wl,--strip-all"
                "-Wl,-O1"
                "-Wl,-z,relro"
                "-Wl,-z,now"
            )

            # GNU ld-only flags (do not work on FreeBSD or Windows linkers)
            if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
                list(APPEND AMIBERRY_LINK_OPTIONS
                    "-Wl,--sort-common=descending"
                    "-Wl,--hash-style=gnu"
                )
            endif()
        endif()
    else()
        if(CMAKE_BUILD_TYPE STREQUAL "Release")
            list(APPEND AMIBERRY_LINK_OPTIONS "-Wl,-dead_strip")
        endif()
    endif()
endif()

if(WITH_OPTIMIZE)
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        if(AMIBERRY_GNU_LIKE_COMPILER)
            include(${CMAKE_SOURCE_DIR}/cmake/optimize.cmake)
        else()
            message(FATAL_ERROR "WITH_OPTIMIZE requires a GNU-like C/C++ compiler")
        endif()
    else()
        message(FATAL_ERROR "WITH_OPTIMIZE can only be used on Release builds")
    endif()
endif()

if(WITH_LTO)
    # ensure LTO links with lld on FreeBSD/clang.
    if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        string(APPEND CMAKE_EXE_LINKER_FLAGS " -fuse-ld=lld")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS " -fuse-ld=lld")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS " -fuse-ld=lld")
    endif()

    include(CheckIPOSupported)
    check_ipo_supported(RESULT lto_supported OUTPUT lto_error)
    if(lto_supported)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    else()
        message(FATAL_ERROR "LTO is not supported: ${lto_error}")
    endif()
endif()

# Platform-specific include/link paths and frameworks.
# The variables are initialized in CMakeLists.txt and applied to the target in
# SourceFiles.cmake.
if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
        list(APPEND AMIBERRY_PLATFORM_INCLUDE_DIRS "/opt/homebrew/include")
        list(APPEND AMIBERRY_PLATFORM_LINK_DIRS "/opt/homebrew/lib")
    else()
        list(APPEND AMIBERRY_PLATFORM_INCLUDE_DIRS "/usr/local/include")
        list(APPEND AMIBERRY_PLATFORM_LINK_DIRS "/usr/local/lib")
    endif()

    list(APPEND AMIBERRY_PLATFORM_LIBS "-framework IOKit" "-framework Foundation" "iconv")

    list(APPEND AMIBERRY_COMPILE_OPTIONS "$<$<CONFIG:Debug>:-fno-omit-frame-pointer;-mno-omit-leaf-frame-pointer>")
endif()
