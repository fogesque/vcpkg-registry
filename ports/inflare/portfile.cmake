# Inflare CMake Portfile 

# Fetch Inflare repository contents: GitHub / GitLab origins

# Find GitHub read token
if(DEFINED ENV{INFLARE_GITHUB_TOKEN} AND NOT "$ENV{INFLARE_GITHUB_TOKEN}" STREQUAL "")
    message(STATUS "Inflare: fetching from GitHub...")
    set(_inflare_url "https://github.com/fogesque/inflare")
    set(_inflare_askpass [=[
#!/bin/sh
case "$1" in
    *Username*) printf '%s\n' x-access-token ;;
    *Password*) printf '%s\n' "$INFLARE_GITHUB_TOKEN" ;;
    *) printf '\n' ;;
esac
]=])
elseif((DEFINED ENV{INFLARE_GITLAB_TOKEN} AND NOT "$ENV{INFLARE_GITLAB_TOKEN}" STREQUAL "") OR
       (DEFINED ENV{CI_JOB_TOKEN} AND NOT "$ENV{CI_JOB_TOKEN}" STREQUAL ""))
    message(STATUS "Inflare: fetching from GitLab mirror repository...")
    set(_inflare_url "https://lab-1.spb.rdi-kvant.ru/dsp/kanon/kanon-sw/inflare.git")
    set(_inflare_askpass [=[
#!/bin/sh
case "$1" in
    *Username*)
        if [ -n "$INFLARE_GITLAB_TOKEN" ]; then printf '%s\n' oauth2
        else printf '%s\n' gitlab-ci-token
        fi
        ;;
    *Password*)
        if [ -n "$INFLARE_GITLAB_TOKEN" ]; then printf '%s\n' "$INFLARE_GITLAB_TOKEN"
        else printf '%s\n' "$CI_JOB_TOKEN"
        fi
        ;;
    *) printf '\n' ;;
esac
]=])
else()
    message(FATAL_ERROR
        "Inflare: no credentials available. Set INFLARE_GITHUB_TOKEN (GitHub) or INFLARE_GITLAB_TOKEN / CI_JOB_TOKEN (GitLab) before configuring.")
endif()

set(_inflare_askpass_file "${CURRENT_BUILDTREES_DIR}/inflare-git-askpass.sh")
file(WRITE "${_inflare_askpass_file}" "${_inflare_askpass}")
file(CHMOD "${_inflare_askpass_file}"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)
set(ENV{GIT_ASKPASS} "${_inflare_askpass_file}")
set(ENV{GIT_TERMINAL_PROMPT} "0")

set(_inflare_ref "b286557d76e2701e1ae1ad4c79b4f8d9d2dc3b1a")

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "${_inflare_url}"
    REF "${_inflare_ref}"
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        logging ENABLE_LOGGING
        gpunetio BUILD_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LOGGING=OFF
        -DENABLE_DATAPATH_LOGGING=OFF
        -DBUILD_CUDA=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_build(TARGET inflare)

file(INSTALL "${SOURCE_PATH}/inflare/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

set(_inflare_release_library "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libinflare.a")
set(_inflare_debug_library "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libinflare.a")

if(EXISTS "${_inflare_release_library}")
    file(INSTALL "${_inflare_release_library}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(NOT VCPKG_BUILD_TYPE AND EXISTS "${_inflare_debug_library}")
    file(INSTALL "${_inflare_debug_library}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
elseif(VCPKG_BUILD_TYPE STREQUAL "debug" AND EXISTS "${_inflare_debug_library}")
    file(INSTALL "${_inflare_debug_library}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/lib/libinflare.a" AND
   NOT EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libinflare.a")
    message(FATAL_ERROR "Inflare library archive was not produced by the build")
endif()

set(_inflare_optional_find_dependencies "")
set(_inflare_optional_link_libraries "")
set(_inflare_optional_compile_definitions "")

if("logging" IN_LIST FEATURES)
    string(APPEND _inflare_optional_find_dependencies "find_dependency(kvalog CONFIG REQUIRED)\n")
    string(APPEND _inflare_optional_link_libraries " kvalog::kvalog")
    string(APPEND _inflare_optional_compile_definitions " INFLARE_ENABLE_LOGGING")
endif()

if("gpunetio" IN_LIST FEATURES)
    string(APPEND _inflare_optional_find_dependencies "find_dependency(CUDAToolkit REQUIRED)\n")
    string(APPEND _inflare_optional_link_libraries " CUDA::cudart")
    string(APPEND _inflare_optional_compile_definitions " INFLARE_ENABLE_CUDA")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(_inflare_config_in "${CURRENT_BUILDTREES_DIR}/inflareConfig.cmake.in")
file(WRITE "${_inflare_config_in}" [=[
include(CMakeFindDependencyMacro)

find_dependency(asio CONFIG REQUIRED)
find_dependency(errors CONFIG REQUIRED)
@_inflare_optional_find_dependencies@
find_library(IBVERBS_LIBRARY ibverbs REQUIRED)

get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

if(NOT TARGET inflare::inflare)
    add_library(inflare::inflare STATIC IMPORTED)

    set(_inflare_link_libraries asio::asio errors::errors "${IBVERBS_LIBRARY}"@_inflare_optional_link_libraries@)
    set(_inflare_compile_definitions@_inflare_optional_compile_definitions@)

    set_target_properties(inflare::inflare PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
        INTERFACE_LINK_LIBRARIES "${_inflare_link_libraries}"
        INTERFACE_COMPILE_FEATURES cxx_std_23
    )

    if(_inflare_compile_definitions)
        set_property(TARGET inflare::inflare PROPERTY INTERFACE_COMPILE_DEFINITIONS "${_inflare_compile_definitions}")
    endif()

    if(EXISTS "${_IMPORT_PREFIX}/lib/libinflare.a")
        set_property(TARGET inflare::inflare APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(inflare::inflare PROPERTIES
            IMPORTED_LOCATION "${_IMPORT_PREFIX}/lib/libinflare.a"
            IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libinflare.a"
        )
    endif()

    if(EXISTS "${_IMPORT_PREFIX}/debug/lib/libinflare.a")
        set_property(TARGET inflare::inflare APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(inflare::inflare PROPERTIES
            IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libinflare.a"
        )
    endif()
endif()
]=])

configure_file(
    "${_inflare_config_in}"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/inflareConfig.cmake"
    @ONLY
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/inflareConfigVersion.cmake"
    VERSION "0.3.2"
    COMPATIBILITY SameMajorVersion
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
