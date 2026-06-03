if(NOT DEFINED ENV{INFLARE_GITHUB_TOKEN} OR "$ENV{INFLARE_GITHUB_TOKEN}" STREQUAL "")
    message(FATAL_ERROR "inflare is private; set INFLARE_GITHUB_TOKEN to a GitHub token with read access to fogesque/inflare.")
endif()

set(_inflare_git_askpass "${CURRENT_BUILDTREES_DIR}/inflare-git-askpass.sh")
file(WRITE "${_inflare_git_askpass}" [=[
#!/bin/sh
case "$1" in
    *Username*) printf '%s\n' x-access-token ;;
    *Password*) printf '%s\n' "$INFLARE_GITHUB_TOKEN" ;;
    *) printf '\n' ;;
esac
]=])
file(CHMOD "${_inflare_git_askpass}"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)
set(ENV{GIT_ASKPASS} "${_inflare_git_askpass}")
set(ENV{GIT_TERMINAL_PROMPT} "0")

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://github.com/fogesque/inflare"
    REF 72dbad5ffe2e3258af9241826399e2478399fae3
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS                                                                                                                                                                                                    
    FEATURES
        gpunetio BUILD_GPUNETIO                                                                                                                                                                                                                             
) 

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/inflare)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
