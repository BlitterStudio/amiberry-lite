# Bundle libSDL3.dylib when libSDL2 is sdl2-compat.
# BUNDLE_DIR   - the app bundle's Contents/Frameworks directory
# APP_BINARY   - the main executable inside the app bundle
# SDL2_LIBRARY - the SDL2 library the executable was linked against
#
# Homebrew's sdl2 formula ships sdl2-compat (2.32+), which dlopens
# libSDL3.dylib at runtime (first candidate: @loader_path/libSDL3.dylib).
# dylibbundler only walks LC_LOAD_DYLIB entries, so the SDL3 dependency
# never lands in the bundle and the app aborts with
# "Failed loading SDL3 library." on launch.

set(bundled_sdl2 "${BUNDLE_DIR}/libSDL2-2.0.0.dylib")
if(NOT EXISTS "${bundled_sdl2}")
    # Static or monolithic SDL2 build: nothing to do.
    return()
endif()

# sdl2-compat embeds the literal name "libSDL3.dylib" in its dlopen
# search list; real SDL2 does not.
execute_process(
    COMMAND grep -q libSDL3.dylib "${bundled_sdl2}"
    RESULT_VARIABLE is_sdl2_compat
    OUTPUT_QUIET ERROR_QUIET)
if(NOT is_sdl2_compat EQUAL 0)
    # Real SDL2: no runtime SDL3 dependency.
    return()
endif()

get_filename_component(sdl2_lib_dir "${SDL2_LIBRARY}" DIRECTORY)
find_library(SDL3_LIBRARY
    NAMES SDL3 libSDL3
    HINTS "${sdl2_lib_dir}" /opt/homebrew/lib /usr/local/lib)

if(NOT SDL3_LIBRARY)
    message(WARNING
        "libSDL2 is sdl2-compat but libSDL3.dylib was not found; "
        "the bundled app will fail to launch with "
        "'Failed loading SDL3 library.' Install SDL3 (brew install sdl3) "
        "and rebuild.")
    return()
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${SDL3_LIBRARY}" "${BUNDLE_DIR}/libSDL3.dylib"
    RESULT_VARIABLE copy_result)
if(NOT copy_result EQUAL 0)
    message(WARNING "failed to copy ${SDL3_LIBRARY} into ${BUNDLE_DIR}")
    return()
endif()

# Re-point the dylib's install ID at the bundle so otool -L no longer
# references the Homebrew prefix it was copied from.
execute_process(
    COMMAND install_name_tool -id @rpath/libSDL3.dylib "${BUNDLE_DIR}/libSDL3.dylib"
    RESULT_VARIABLE id_result)
if(NOT id_result EQUAL 0)
    message(WARNING "failed to set install name for bundled libSDL3.dylib")
endif()
execute_process(
    COMMAND codesign --force --sign - "${BUNDLE_DIR}/libSDL3.dylib"
    RESULT_VARIABLE codesign_result)
if(NOT codesign_result EQUAL 0)
    message(WARNING "codesign failed for bundled libSDL3.dylib")
endif()

# libSDL3.dylib was added after dylibbundler signed the bundle. Nested code
# must be signed before the enclosing bundle, so sign libSDL3.dylib first
# (above), then re-seal the whole .app bundle.
get_filename_component(app_bundle "${APP_BINARY}/../../.." ABSOLUTE)
execute_process(
    COMMAND codesign --force --deep --sign - "${app_bundle}"
    RESULT_VARIABLE app_codesign_result)
if(NOT app_codesign_result EQUAL 0)
    message(WARNING "codesign failed for ${app_bundle}")
endif()
message(STATUS "Bundled ${SDL3_LIBRARY} for sdl2-compat")
