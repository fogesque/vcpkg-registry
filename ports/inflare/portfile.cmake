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

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/inflare)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
