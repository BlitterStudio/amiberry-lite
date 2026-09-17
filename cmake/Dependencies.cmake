include(FindHelper)

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

if (USE_OPENGL)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_OPENGL)
    find_package(OpenGL REQUIRED)
    find_package(GLEW REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE GLEW OpenGL::GL)
endif ()

find_package(SDL2 CONFIG REQUIRED)
find_package(SDL2_image MODULE REQUIRED)
find_package(SDL2_ttf MODULE REQUIRED)
find_package(FLAC REQUIRED)
find_package(PNG REQUIRED)
if(USE_MPG123)
    find_package(mpg123 REQUIRED)
    target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_MPG123)
endif()

if (USE_ZSTD)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_ZSTD)
    find_helper(ZSTD libzstd zstd.h zstd)
    if(NOT ZSTD_FOUND)
        message(STATUS "ZSTD library not found - CHD compressed disk images will not be supported")
    else()
        target_include_directories(${PROJECT_NAME} PRIVATE ${ZSTD_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} PRIVATE ${ZSTD_LIBRARIES})
    endif()
endif ()

if (USE_LIBSERIALPORT)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_LIBSERIALPORT)
    find_helper(LIBSERIALPORT libserialport libserialport.h serialport)
    if(LIBSERIALPORT_FOUND AND LIBSERIALPORT_LIBRARIES)
        target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBSERIALPORT_LIBRARIES})
    else()
        message(STATUS "LibSerialPort enabled but library was not found")
    endif()
endif ()

if (USE_PORTMIDI)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_PORTMIDI)
    find_helper(PORTMIDI portmidi portmidi.h portmidi)
    if(PORTMIDI_FOUND AND PORTMIDI_LIBRARIES)
        target_link_libraries(${PROJECT_NAME} PRIVATE ${PORTMIDI_LIBRARIES})
    else()
        message(STATUS "PortMidi enabled but library was not found")
    endif()
endif ()

if (USE_LIBMPEG2)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_LIBMPEG2)
    find_helper(LIBMPEG2_CONVERT libmpeg2convert mpeg2convert.h mpeg2convert)
    find_helper(LIBMPEG2 libmpeg2 mpeg2.h mpeg2)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBMPEG2_LIBRARIES} ${LIBMPEG2_CONVERT_LIBRARIES})
endif ()

if (USE_LIBENET)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_LIBENET)
    find_helper(LIBENET libenet enet/enet.h enet)
    if(NOT LIBENET_FOUND)
        message(STATUS "LibENET library not found - network emulation will not be supported")
    else()
        target_include_directories(${PROJECT_NAME} PRIVATE ${LIBENET_INCLUDE_DIRS})
        target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBENET_LIBRARIES})
    endif()
endif ()

if (USE_PCEM)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_PCEM)
endif ()

# Add libpcap for uaenet (Linux/macOS)
if (USE_UAENET_PCAP)
    find_path(PCAP_INCLUDE_DIR pcap.h)
    find_library(PCAP_LIBRARY pcap)
    if (PCAP_INCLUDE_DIR AND PCAP_LIBRARY)
        message(STATUS "Found libpcap: ${PCAP_LIBRARY}")
        target_include_directories(${PROJECT_NAME} PRIVATE ${PCAP_INCLUDE_DIR})
        target_link_libraries(${PROJECT_NAME} PRIVATE ${PCAP_LIBRARY})
        target_compile_definitions(${PROJECT_NAME} PRIVATE WITH_UAENET_PCAP)
    else()
        message(FATAL_ERROR "libpcap not found. Please install libpcap-dev (Linux) or brew install libpcap (macOS)")
    endif()
endif()

# SDL2 include dirs: propagate them to the amiberry-lite target explicitly,
# since the SDL2_image/SDL2_ttf MODULE finders only expose variables.
get_target_property(SDL2_INCLUDE_DIRS SDL2::SDL2 INTERFACE_INCLUDE_DIRECTORIES)
target_include_directories(${PROJECT_NAME} PRIVATE ${SDL2_INCLUDE_DIRS} ${SDL2_IMAGE_INCLUDE_DIR} ${SDL2_TTF_INCLUDE_DIR})

set(libmt32emu_SHARED FALSE)
add_subdirectory(external/mt32emu)
add_subdirectory(external/floppybridge)
add_subdirectory(external/capsimage)
add_subdirectory(external/libguisan)

target_include_directories(guisan PRIVATE ${SDL2_INCLUDE_DIRS} ${SDL2_IMAGE_INCLUDE_DIR} ${SDL2_TTF_INCLUDE_DIR})

# Direct target linking preserves transitive includes and compile definitions.
# SDL2, SDL2_ttf and SDL2_image are linked transitively through guisan.
target_link_libraries(${PROJECT_NAME} PRIVATE
        guisan
        mt32emu
)
# mpg123 is optional at build time (HAVE_MPG123 guards the decoder).
if(USE_MPG123)
    if(TARGET MPG123::libmpg123)
        target_link_libraries(${PROJECT_NAME} PRIVATE MPG123::libmpg123)
    elseif(MPG123_FOUND)
        target_link_libraries(${PROJECT_NAME} PRIVATE ${MPG123_LIBRARIES})
    endif()
endif()

if(TARGET FLAC::FLAC)
    target_link_libraries(${PROJECT_NAME} PRIVATE FLAC::FLAC)
elseif(TARGET FLAC)
    target_link_libraries(${PROJECT_NAME} PRIVATE FLAC)
elseif(FLAC_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${FLAC_LIBRARIES})
endif()

if(TARGET PNG::PNG)
    target_link_libraries(${PROJECT_NAME} PRIVATE PNG::PNG)
elseif(TARGET png_static)
    target_link_libraries(${PROJECT_NAME} PRIVATE png_static)
elseif(TARGET png)
    target_link_libraries(${PROJECT_NAME} PRIVATE png)
elseif(PNG_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${PNG_LIBRARIES})
endif()


if(TARGET libzstd_static)
    target_link_libraries(${PROJECT_NAME} PRIVATE libzstd_static)
elseif(TARGET zstd)
    target_link_libraries(${PROJECT_NAME} PRIVATE zstd)
elseif(ZSTD_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${ZSTD_LIBRARIES})
endif()

if(TARGET ZLIB::ZLIB)
    target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB)
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE z)
endif()

# capsimage and floppybridge are plugins (not linked into amiberry-lite) but
# are copied by post-build commands. Explicit dependencies ensure they are
# built.
add_dependencies(${PROJECT_NAME} mt32emu floppybridge capsimage guisan)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_library(UTIL_LIBRARY util)
    if(UTIL_LIBRARY)
        target_link_libraries(${PROJECT_NAME} PRIVATE ${UTIL_LIBRARY})
    endif()
    target_link_libraries(${PROJECT_NAME} PRIVATE rt)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    find_library(UTIL_LIBRARY util REQUIRED)
    # REQUIRED will make sure the build fails earlier if libutil isn't found
    find_library(ICONV_LIB iconv PATHS /usr/local/lib REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${UTIL_LIBRARY} ${ICONV_LIB})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBUSB_LIBRARY})
elseif(CMAKE_SYSTEM_NAME STREQUAL "Haiku")
    target_link_libraries(${PROJECT_NAME} PRIVATE network iconv bsd)
endif()

# Platform system libraries must come AFTER all other dependencies so that
# static libs (enet, etc.) can resolve their system library references.
if(AMIBERRY_PLATFORM_LIBS)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${AMIBERRY_PLATFORM_LIBS})
endif()
