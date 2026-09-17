# Base package settings
if (NOT CMAKE_SYSTEM_NAME MATCHES "Darwin" AND NOT WIN32)
    set(CPACK_PACKAGING_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
endif ()
set(CPACK_VERBATIM_VARIABLES YES)
set(CPACK_SOURCE_IGNORE_FILES .git/ .github/ .vscode/ _CPack_Packages/ build/ out/ cmake-build-.*)
if (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(CPACK_PACKAGE_NAME ${AMIBERRY_DISPLAY_NAME})
else()
    set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
endif()
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

# Include pre-release suffix in the package version if set.
# DEB uses ~ (sorts lower than release). RPM cannot have - or ~ in Version,
# so the pre-release tag goes into CPACK_RPM_PACKAGE_RELEASE instead.
if(VERSION_PRE_RELEASE)
    set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}~pre${VERSION_PRE_RELEASE}")
    set(CPACK_RPM_PACKAGE_VERSION "${PROJECT_VERSION}")
    set(CPACK_RPM_PACKAGE_RELEASE "0.pre${VERSION_PRE_RELEASE}")
else()
    set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
endif()

# Append distro codename suffix for Linux packages when DISTRO_CODENAME is set.
# DEB: appends +${DISTRO_CODENAME} to version (e.g., 5.9.2+bookworm)
# RPM: appends .${DISTRO_CODENAME} to release (e.g., 0.pre2.bookworm or 1.bookworm)
if(CMAKE_SYSTEM_NAME MATCHES "Linux" AND DISTRO_CODENAME)
    string(APPEND CPACK_PACKAGE_VERSION "+${DISTRO_CODENAME}")
    if(CPACK_RPM_PACKAGE_RELEASE)
        string(APPEND CPACK_RPM_PACKAGE_RELEASE ".${DISTRO_CODENAME}")
    else()
        set(CPACK_RPM_PACKAGE_RELEASE "1.${DISTRO_CODENAME}")
    endif()
endif()

set(CPACK_PACKAGE_VENDOR "BlitterStudio")
set(CPACK_PACKAGE_CONTACT "Dimitris Panokostas <midwan@gmail.com>")
set(CPACK_PACKAGE_DESCRIPTION
        "Optimized Amiga emulator for various ARM, ARM64, AMD64 and RISC-V platforms.
Amiberry is an optimized Amiga emulator for various platforms. It is based on
the latest WinUAE and supports various Amiga models, including the A4000T,
A4000D, A1200, A3000 and A600. Additionally, it includes several unique
features, such as support for WHDLoad titles, RetroArch integration, custom
Controller Mappings and more.")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/packaging/Description.txt")

# macOS settings for DragNDrop generator
set(CPACK_DMG_SLA_USE_RESOURCE_FILE_LICENSE OFF)
set(CPACK_DMG_VOLUME_NAME "${AMIBERRY_DISPLAY_NAME}")
set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_SOURCE_DIR}/packaging/dmg/AppDMGBackground.tiff")
set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/packaging/dmg/AppDMGSetup.scpt")

# Detect package architecture once, map to DEB and RPM names
if (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
    set(_deb_arch "arm64")
    set(_rpm_arch "aarch64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    set(_deb_arch "armhf")
    set(_rpm_arch "armhf")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "riscv64")
    set(_deb_arch "riscv64")
    set(_rpm_arch "riscv64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "loongarch64")
    set(_deb_arch "loong64")
    set(_rpm_arch "loongarch64")
else()
    set(_deb_arch "amd64")
    set(_rpm_arch "x86_64")
endif()

# Linux DEB settings - build dependency list conditionally based on enabled features
set(_deb_deps "libc6, libstdc++6, libsdl2-2.0-0, libsdl2-image-2.0-0, libsdl2-ttf-2.0-0, flac, libpng16-16, zlib1g")
if(USE_MPG123)
    string(APPEND _deb_deps ", libmpg123-0")
endif()
if(USE_ZSTD)
    string(APPEND _deb_deps ", libzstd1")
endif()
if(USE_LIBSERIALPORT)
    string(APPEND _deb_deps ", libserialport0")
endif()
# PortMidi's runtime package follows its SONAME (libportmidi0, libportmidi2,
# ...). Let dpkg-shlibdeps add the distro-correct dependency.
if(USE_LIBENET)
    string(APPEND _deb_deps ", libenet7")
endif()
if(USE_LIBMPEG2)
    string(APPEND _deb_deps ", libmpeg2-4")
endif()
if(USE_UAENET_PCAP)
    string(APPEND _deb_deps ", libpcap0.8")
endif()
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
# Force the DEB payload to use a plain GNU tar format. PAX headers can carry
# host extended attributes such as macOS com.apple.* metadata, which dpkg/tar
# may warn about during install.
set(CPACK_DEBIAN_ARCHIVE_TYPE "gnutar")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "${_deb_deps}")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(_deb_shlib_private_dirs "")
foreach(_sdl_dir IN ITEMS "${SDL2_DIR}" "${SDL2_IMAGE_DIR}")
    if(_sdl_dir)
        # get_filename_component instead of cmake_path: Debian bullseye
        # ships CMake 3.18, where cmake_path does not exist.
        get_filename_component(_sdl_lib_dir "${_sdl_dir}" DIRECTORY)
        get_filename_component(_sdl_lib_dir "${_sdl_lib_dir}" DIRECTORY)
        if(EXISTS "${_sdl_lib_dir}")
            list(APPEND _deb_shlib_private_dirs "${_sdl_lib_dir}")
        endif()
    endif()
endforeach()
if(_deb_shlib_private_dirs)
    list(REMOVE_DUPLICATES _deb_shlib_private_dirs)
    list(JOIN _deb_shlib_private_dirs ";" CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS)
endif()
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://amiberry.com")
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
        "${CMAKE_SOURCE_DIR}/packaging/linux/scripts/postinst"
        "${CMAKE_SOURCE_DIR}/packaging/linux/scripts/postrm")

# Linux RPM settings - build dependency list conditionally based on enabled features
set(_rpm_deps "glibc, libstdc++, SDL2, SDL2_ttf, SDL2_image, flac, libpng, zlib")
if(USE_MPG123)
    string(APPEND _rpm_deps ", mpg123")
endif()
if(USE_ZSTD)
    string(APPEND _rpm_deps ", zstd")
endif()
if(USE_LIBSERIALPORT)
    string(APPEND _rpm_deps ", libserialport")
endif()
if(USE_PORTMIDI)
    string(APPEND _rpm_deps ", portmidi")
endif()
if(USE_LIBENET)
    string(APPEND _rpm_deps ", enet")
endif()
if(USE_LIBMPEG2)
    string(APPEND _rpm_deps ", libmpeg2")
endif()
set(CPACK_RPM_FILE_NAME "RPM-DEFAULT")
set(CPACK_RPM_PACKAGE_REQUIRES "${_rpm_deps}")
set(CPACK_RPM_PACKAGE_LICENSE "GPL-3.0-or-later")
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/packaging/linux/scripts/rpm-postinst.sh")
set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/packaging/linux/scripts/rpm-postrm.sh")
set(CPACK_RPM_PACKAGE_ARCHITECTURE "${_rpm_arch}")

# Package resources
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.md")

# Strip binaries
set(CPACK_STRIP_FILES TRUE)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.19)
    set(CPACK_PRE_BUILD_SCRIPTS
            "${CMAKE_SOURCE_DIR}/cmake/package_strip_macos_metadata.cmake")
endif()

# Generator selection per platform
if (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(CPACK_GENERATOR TGZ DragNDrop)
elseif (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(CPACK_GENERATOR TGZ DEB RPM)
else ()
    set(CPACK_GENERATOR TGZ)
endif ()

include(CPack)
