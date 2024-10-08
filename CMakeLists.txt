cmake_minimum_required(VERSION 3.16)
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    message(FATAL_ERROR "Prevented in-tree build. Please create a build directory outside of the amiberry source code and run \"cmake -S ${CMAKE_SOURCE_DIR} -B .\" from there")
endif ()
project(amiberry-lite VERSION 5.7.5)
enable_language(C CXX ASM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS_RELEASE "-O3 -pipe -fno-pie -no-pie")
set(CMAKE_C_FLAGS_DEBUG "-Og -g -funwind-tables -DDEBUG -pipe -fno-pie -no-pie")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}")
set(CMAKE_ASM_COMPILER_ARG1 "${CMAKE_C_COMPILER_ARG1}")

# Use libgpiod to control GPIO LEDs?
option(USE_GPIOD "Use GPIOD" OFF)
# Use DBUS to control the emulator?
option(USE_DBUS "Use DBus" OFF)
# Use OpenGL for rendering?
option(USE_OPENGL "Use OpenGL" OFF)
# Enable Link Time Optimization?
option(WITH_LTO "Enable Link Time Optimization" OFF)

# Set build type to "Release" if user did not specify any build type yet
# Other possible values: Debug, Release, RelWithDebInfo and MinSizeRel
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif (NOT CMAKE_BUILD_TYPE)

if (WITH_LTO)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif ()

# Needed so that cmake uses our find modules.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(MACOS TRUE)
    message(STATUS "macOS platform detected")
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
        include_directories("/opt/homebrew/include")
        set(CMAKE_EXE_LINKER_FLAGS "-L/opt/homebrew/lib -framework IOKit -framework Foundation -liconv")
    else ()
        include_directories("/usr/local/include")
        set(CMAKE_EXE_LINKER_FLAGS "-L/usr/local/lib -framework IOKit -framework Foundation -liconv")
    endif ()
endif ()

# Define the list of source files
set(SOURCE_FILES
    src/a2065.cpp
    src/a2091.cpp
    src/akiko.cpp
    src/amax.cpp
    src/ar.cpp
    src/arcadia.cpp
    src/audio.cpp
    src/autoconf.cpp
    src/blitfunc.cpp
    src/blittable.cpp
    src/blitter.cpp
    src/blkdev.cpp
    src/blkdev_cdimage.cpp
    src/bsdsocket.cpp
    src/calc.cpp
    src/cd32_fmv.cpp
    src/cd32_fmv_genlock.cpp
    src/cdrom.cpp
    src/cdtv.cpp
    src/cdtvcr.cpp
    src/cfgfile.cpp
    src/cia.cpp
    src/consolehook.cpp
    src/cpuboard.cpp
    src/crc32.cpp
    src/custom.cpp
    src/debug.cpp
    src/def_icons.cpp
    src/devices.cpp
    src/disk.cpp
    src/diskutil.cpp
    src/dlopen.cpp
    src/dongle.cpp
    src/draco.cpp
    src/drawing.cpp
    src/driveclick.cpp
    src/ethernet.cpp
    src/events.cpp
    src/expansion.cpp
    src/fdi2raw.cpp
    src/filesys.cpp
    src/flashrom.cpp
    src/fpp.cpp
    src/fsdb.cpp
    src/fsusage.cpp
    src/gayle.cpp
    src/gfxboard.cpp
    src/gfxutil.cpp
    src/hardfile.cpp
    src/hrtmon.rom.cpp
    src/ide.cpp
    src/idecontrollers.cpp
    src/identify.cpp
    src/ini.cpp
    src/inputdevice.cpp
    src/inputrecord.cpp
    src/isofs.cpp
    src/keybuf.cpp
    src/main.cpp
    src/memory.cpp
    src/midiemu.cpp
    src/native2amiga.cpp
    src/ncr9x_scsi.cpp
    src/ncr_scsi.cpp
    src/parser.cpp
    src/rommgr.cpp
    src/rtc.cpp
    src/sampler.cpp
    src/savestate.cpp
    src/scp.cpp
    src/scsi.cpp
    src/scsiemul.cpp
    src/scsitape.cpp
    src/specialmonitors.cpp
    src/statusline.cpp
    src/tabletlibrary.cpp
    src/test_card.cpp
    src/tinyxml2.cpp
    src/traps.cpp
    src/uaeexe.cpp
    src/uaelib.cpp
    src/uaenative.cpp
    src/uaeresource.cpp
    src/uaeserial.cpp
    src/zfile.cpp
    src/zfile_archive.cpp
    src/archivers/7z/7zAlloc.c
    src/archivers/7z/7zArcIn.c
    src/archivers/7z/7zBuf.c
    src/archivers/7z/7zBuf2.c
    src/archivers/7z/7zCrc.c
    src/archivers/7z/7zCrcOpt.c
    src/archivers/7z/7zDec.c
    src/archivers/7z/7zFile.c
    src/archivers/7z/7zStream.c
    src/archivers/7z/Aes.c
    src/archivers/7z/AesOpt.c
    src/archivers/7z/Alloc.c
    src/archivers/7z/Bcj2.c
    src/archivers/7z/Bra.c
    src/archivers/7z/Bra86.c
    src/archivers/7z/BraIA64.c
    src/archivers/7z/CpuArch.c
    src/archivers/7z/Delta.c
    src/archivers/7z/LzFind.c
    src/archivers/7z/Lzma2Dec.c
    src/archivers/7z/Lzma2Enc.c
    src/archivers/7z/Lzma86Dec.c
    src/archivers/7z/Lzma86Enc.c
    src/archivers/7z/LzmaDec.c
    src/archivers/7z/LzmaEnc.c
    src/archivers/7z/LzmaLib.c
    src/archivers/7z/Ppmd7.c
    src/archivers/7z/Ppmd7Dec.c
    src/archivers/7z/Ppmd7Enc.c
    src/archivers/7z/Sha256.c
    src/archivers/7z/Sort.c
    src/archivers/7z/Xz.c
    src/archivers/7z/XzCrc64.c
    src/archivers/7z/XzCrc64Opt.c
    src/archivers/7z/XzDec.c
    src/archivers/7z/XzEnc.c
    src/archivers/7z/XzIn.c
    src/archivers/chd/avhuff.cpp
    src/archivers/chd/bitmap.cpp
    src/archivers/chd/cdrom.cpp
    src/archivers/chd/chd.cpp
    src/archivers/chd/chdcd.cpp
    src/archivers/chd/chdcodec.cpp
    src/archivers/chd/corealloc.cpp
    src/archivers/chd/corefile.cpp
    src/archivers/chd/corestr.cpp
    src/archivers/chd/flac.cpp
    src/archivers/chd/harddisk.cpp
    src/archivers/chd/hashing.cpp
    src/archivers/chd/huffman.cpp
    src/archivers/chd/md5.cpp
    src/archivers/chd/osdcore.cpp
    src/archivers/chd/osdlib_unix.cpp
    src/archivers/chd/osdsync.cpp
    src/archivers/chd/palette.cpp
    src/archivers/chd/posixdir.cpp
    src/archivers/chd/posixfile.cpp
    src/archivers/chd/posixptty.cpp
    src/archivers/chd/posixsocket.cpp
    src/archivers/chd/strconv.cpp
    src/archivers/chd/strformat.cpp
    src/archivers/chd/unicode.cpp
    src/archivers/chd/vecstream.cpp
    src/archivers/chd/utf8proc.c
    src/archivers/dms/crc_csum.cpp
    src/archivers/dms/getbits.cpp
    src/archivers/dms/maketbl.cpp
    src/archivers/dms/pfile.cpp
    src/archivers/dms/tables.cpp
    src/archivers/dms/u_deep.cpp
    src/archivers/dms/u_heavy.cpp
    src/archivers/dms/u_init.cpp
    src/archivers/dms/u_medium.cpp
    src/archivers/dms/u_quick.cpp
    src/archivers/dms/u_rle.cpp
    src/archivers/lha/crcio.cpp
    src/archivers/lha/dhuf.cpp
    src/archivers/lha/header.cpp
    src/archivers/lha/huf.cpp
    src/archivers/lha/larc.cpp
    src/archivers/lha/lhamaketbl.cpp
    src/archivers/lha/lharc.cpp
    src/archivers/lha/shuf.cpp
    src/archivers/lha/shuf.cpp
    src/archivers/lha/slide.cpp
    src/archivers/lha/uae_lha.cpp
    src/archivers/lha/util.cpp
    src/archivers/lzx/unlzx.cpp
    src/archivers/mp2/kjmp2.cpp
    src/archivers/wrp/warp.cpp
    src/archivers/zip/unzip.cpp
    src/caps/caps_amiberry.cpp
    src/machdep/support.cpp
    external/floppybridge/src/floppybridge_lib.cpp
    src/osdep/ahi_v1.cpp
    src/osdep/bsdsocket_host.cpp
    src/osdep/cda_play.cpp
    src/osdep/charset.cpp
    src/osdep/fsdb_host.cpp
    src/osdep/clipboard.cpp
    src/osdep/amiberry_hardfile.cpp
    src/osdep/keyboard.cpp
    src/osdep/midi.cpp
    src/osdep/mp3decoder.cpp
    src/osdep/picasso96.cpp
    src/osdep/writelog.cpp
    src/osdep/amiberry.cpp
    src/osdep/ahi_v2.cpp
    src/osdep/amiberry_dbus.cpp
    src/osdep/amiberry_filesys.cpp
    src/osdep/amiberry_input.cpp
    src/osdep/amiberry_gfx.cpp
    src/osdep/amiberry_gui.cpp
    src/osdep/amiberry_mem.cpp
    src/osdep/amiberry_serial.cpp
    src/osdep/amiberry_uaenet.cpp
    src/osdep/amiberry_whdbooter.cpp
    src/osdep/ioport.cpp
    src/osdep/sigsegv_handler.cpp
    src/osdep/socket.cpp
    src/osdep/retroarch.cpp
    src/osdep/vpar.cpp
    src/sounddep/sound.cpp
    src/threaddep/threading.cpp
    src/osdep/gui/ControllerMap.cpp
    src/osdep/gui/CreateFolder.cpp
    src/osdep/gui/SelectorEntry.cpp
    src/osdep/gui/ShowCustomFields.cpp
    src/osdep/gui/ShowHelp.cpp
    src/osdep/gui/ShowMessage.cpp
    src/osdep/gui/ShowDiskInfo.cpp
    src/osdep/gui/SelectFolder.cpp
    src/osdep/gui/SelectFile.cpp
    src/osdep/gui/CreateFilesysHardfile.cpp
    src/osdep/gui/EditFilesysVirtual.cpp
    src/osdep/gui/EditFilesysHardfile.cpp
    src/osdep/gui/EditFilesysHardDrive.cpp
    src/osdep/gui/EditTapeDrive.cpp
    src/osdep/gui/PanelAbout.cpp
    src/osdep/gui/PanelPaths.cpp
    src/osdep/gui/PanelQuickstart.cpp
    src/osdep/gui/PanelConfig.cpp
    src/osdep/gui/PanelCPU.cpp
    src/osdep/gui/PanelChipset.cpp
    src/osdep/gui/PanelCustom.cpp
    src/osdep/gui/PanelROM.cpp
    src/osdep/gui/PanelRAM.cpp
    src/osdep/gui/PanelFloppy.cpp
    src/osdep/gui/PanelExpansions.cpp
    src/osdep/gui/PanelHD.cpp
    src/osdep/gui/PanelRTG.cpp
    src/osdep/gui/PanelHWInfo.cpp
    src/osdep/gui/PanelInput.cpp
    src/osdep/gui/PanelIOPorts.cpp
    src/osdep/gui/PanelDisplay.cpp
    src/osdep/gui/PanelSound.cpp
    src/osdep/gui/PanelDiskSwapper.cpp
    src/osdep/gui/PanelMisc.cpp
    src/osdep/gui/PanelPrio.cpp
    src/osdep/gui/PanelSavestate.cpp
    src/osdep/gui/PanelVirtualKeyboard.cpp
    src/osdep/gui/PanelWHDLoad.cpp
    src/osdep/gui/main_window.cpp
    src/osdep/gui/Navigation.cpp
    src/osdep/vkbd/vkbd.cpp
    src/newcpu.cpp
    src/newcpu_common.cpp
    src/readcpu.cpp
    src/cpudefs.cpp
    src/cpustbl.cpp
    src/cpuemu_0.cpp
    src/cpuemu_4.cpp
    src/cpuemu_11.cpp
    src/cpuemu_13.cpp
    src/cpuemu_40.cpp
    src/cpuemu_44.cpp
)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SOURCE_FILES})
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist
    )
else ()
    add_executable(${PROJECT_NAME} ${SOURCE_FILES})
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE _FILE_OFFSET_BITS=64)

if (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
    target_compile_definitions(${PROJECT_NAME} PRIVATE CPU_AARCH64)
    target_sources(${PROJECT_NAME} PRIVATE
            src/osdep/aarch64_helper.s
            src/jit/compemu.cpp
            src/jit/compstbl.cpp
            src/jit/compemu_fpp.cpp
            src/jit/compemu_support.cpp
    )
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    set(CMAKE_ASM_COMPILER_ARG1 "-mfpu=neon-fp-armv8")
    target_compile_definitions(${PROJECT_NAME} PRIVATE CPU_arm ARMV6_ASSEMBLY ARMV6T2 USE_ARMNEON ARM_HAS_DIV)
    target_sources(${PROJECT_NAME} PRIVATE
            src/osdep/neon_helper.s
            src/jit/compemu.cpp
            src/jit/compstbl.cpp
            src/jit/compemu_fpp.cpp
            src/jit/compemu_support.cpp
    )
endif ()

find_package(SDL2 CONFIG REQUIRED)
find_package(SDL2_image MODULE REQUIRED)
find_package(SDL2_ttf MODULE REQUIRED)
include_directories(${SDL2_INCLUDE_DIR} ${SDL2_IMAGE_INCLUDE_DIR} ${SDL2_TTF_INCLUDE_DIR})

if (USE_GPIOD)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_GPIOD)
    find_library(LIBGPIOD_LIBRARIES gpiod REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBGPIOD_LIBRARIES})
endif ()

if (USE_DBUS)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_DBUS)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(DBUS REQUIRED dbus-1)
    target_include_directories(${PROJECT_NAME} PRIVATE ${DBUS_INCLUDE_DIRS})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${DBUS_LIBRARIES})
endif ()

find_package(FLAC REQUIRED)
find_package(mpg123 REQUIRED)
find_package(PNG REQUIRED)
find_package(ZLIB REQUIRED)
find_library(LIBSERIALPORT_LIBRARIES serialport REQUIRED)
find_library(PORTMIDI_LIBRARIES portmidi REQUIRED)
find_library(LIBMPEG2 mpeg2 REQUIRED)

set(libmt32emu_SHARED FALSE)
add_subdirectory(external/mt32emu)
add_subdirectory(external/floppybridge)
add_subdirectory(external/capsimage)
add_subdirectory(external/libguisan)

# Add dependencies to ensure external libraries are built
add_dependencies(${PROJECT_NAME} mt32emu floppybridge capsimage guisan)

target_include_directories(${PROJECT_NAME} PRIVATE src src/osdep src/include src/threaddep src/archivers src/ppc/pearpc external/libguisan/include external/mt32emu/src external/floppybridge/src)
target_link_libraries(${PROJECT_NAME} PRIVATE SDL2 SDL2_image SDL2_ttf guisan mt32emu ${DBUS_LIBRARIES} FLAC portmidi png MPG123::libmpg123 mpeg2convert mpeg2 serialport z pthread dl)

if (USE_OPENGL)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_OPENGL)
    find_package(OpenGL REQUIRED)
    find_package(GLEW REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${TARGET_LINK_LIBRARIES} GLEW OpenGL::GL)
endif ()

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/cdroms $<TARGET_FILE_DIR:${PROJECT_NAME}>/cdroms)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/conf $<TARGET_FILE_DIR:${PROJECT_NAME}>/conf)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/controllers $<TARGET_FILE_DIR:${PROJECT_NAME}>/controllers)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/data $<TARGET_FILE_DIR:${PROJECT_NAME}>/data)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/floppies $<TARGET_FILE_DIR:${PROJECT_NAME}>/floppies)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/harddrives $<TARGET_FILE_DIR:${PROJECT_NAME}>/harddrives)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/inputrecordings $<TARGET_FILE_DIR:${PROJECT_NAME}>/inputrecordings)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/kickstarts $<TARGET_FILE_DIR:${PROJECT_NAME}>/kickstarts)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/lha $<TARGET_FILE_DIR:${PROJECT_NAME}>/lha)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/nvram $<TARGET_FILE_DIR:${PROJECT_NAME}>/nvram)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/plugins $<TARGET_FILE_DIR:${PROJECT_NAME}>/plugins)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/savestates $<TARGET_FILE_DIR:${PROJECT_NAME}>/savestates)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/screenshots $<TARGET_FILE_DIR:${PROJECT_NAME}>/screenshots)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/whdboot $<TARGET_FILE_DIR:${PROJECT_NAME}>/whdboot)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_BINARY_DIR}/external/floppybridge/libfloppybridge.so $<TARGET_FILE_DIR:${PROJECT_NAME}>/plugins/
        DEPENDS external/floppybridge)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_BINARY_DIR}/external/capsimage/libcapsimage.so $<TARGET_FILE_DIR:${PROJECT_NAME}>/plugins/
        DEPENDS external/capsimage)

# Install the executable
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    install(TARGETS ${PROJECT_NAME} BUNDLE DESTINATION .)
else ()
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
    # Install additional directories
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/cdroms
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/conf
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/controllers
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/data
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/floppies
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/harddrives
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/inputrecordings
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/kickstarts
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/lha
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/nvram
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/plugins
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/savestates
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/screenshots
        DESTINATION share/${PROJECT_NAME}
    )
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/whdboot
        DESTINATION share/${PROJECT_NAME}
    )

    # Install shared libraries
    install(FILES ${CMAKE_BINARY_DIR}/external/floppybridge/libfloppybridge.so
        DESTINATION share/${PROJECT_NAME}/plugins
    )
    install(FILES ${CMAKE_BINARY_DIR}/external/capsimage/libcapsimage.so
        DESTINATION share/${PROJECT_NAME}/plugins
    )

    # Install desktop file
    install(FILES ${CMAKE_SOURCE_DIR}/data/Amiberry.desktop
        DESTINATION share/applications
    )
endif ()

include(InstallRequiredSystemLibraries)

if(APPLE)
    set(CPACK_GENERATOR "Bundle")
    set(CPACK_BUNDLE_NAME "Amiberry-Lite")
    set(CPACK_BUNDLE_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    set(CPACK_BUNDLE_APPLE_ENTITLEMENTS ${CMAKE_SOURCE_DIR}/Entitlements.plist)
    set(CPACK_BUNDLE_ICON ${CMAKE_SOURCE_DIR}/data/amiberry.png)
else()
    set(CPACK_GENERATOR "DEB")
    set(CPACK_SOURCE_IGNORE_FILES .git/ .github/ .vscode/ _CPack_Packages/)
    SET(CPACK_PACKAGE_NAME ${CMAKE_PROJECT_NAME})
    SET(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    SET(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    SET(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
    SET(CPACK_PACKAGE_VENDOR "BlitterStudio")
    SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
    SET(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/docs/README.md")
    SET(CPACK_DEBIAN_PACKAGE_NAME ${CMAKE_PROJECT_NAME})
    set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://amiberry.com")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Dimitris Panokostas <midwan@gmail.com>") # Required
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.27), libstdc++6 (>= 8.3.0), libsdl2-2.0-0, libsdl2-image-2.0-0, libsdl2-ttf-2.0-0, flac, libmpg123-0, libpng16-16, zlib1g, libserialport0, libportmidi0, libmpeg2-4") # Adjust dependencies as needed
    set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Amiberry-Lite is an optimized Amiga emulator various platforms.")
    set(CPACK_DEBIAN_PACKAGE_SECTION "games")
    set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
endif()

include(CPack)
