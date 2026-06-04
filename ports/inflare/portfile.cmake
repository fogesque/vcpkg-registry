set(INFLARE_REF "b60e1ff7a15e5cb05c9c6e3068a1c4eccc339e35")

if(DEFINED ENV{INFLARE_GITHUB_TOKEN} AND NOT "$ENV{INFLARE_GITHUB_TOKEN}" STREQUAL "")
    message(STATUS "inflare: INFLARE_GITHUB_TOKEN set, fetching from GitHub via git clone")

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
        REF "${INFLARE_REF}"
        HEAD_REF main
    )
else()
    message(STATUS "inflare: INFLARE_GITHUB_TOKEN not set, falling back to GitLab Package Registry")

    if(DEFINED ENV{GITLAB_PAT} AND NOT "$ENV{GITLAB_PAT}" STREQUAL "")
        set(_inflare_auth "PRIVATE-TOKEN: $ENV{GITLAB_PAT}")
    else()
        set(_inflare_auth "JOB-TOKEN: $ENV{CI_JOB_TOKEN}")
    endif()

    vcpkg_download_distfile(
        ARCHIVE
        URLS "https://lab-1.spb.rdi-kvant.ru/api/v4/projects/dsp%2Fkanon%2Fkanon-sw%2Fexamples%2Fladle/packages/generic/inflare/${INFLARE_REF}/inflare-${INFLARE_REF}.tar.gz"
        FILENAME "inflare-${INFLARE_REF}.tar.gz"
        SHA512 393b716e984b87ea0f1d94bbb1d85ad50b065c4fb5974091f4df9ccb66ebc439d835917c3cf35760b44efc1d3dd323904d699443c1041c35250a9b4df9967624
        HEADERS "${_inflare_auth}"
    )
    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        logging ENABLE_LOGGING
        gpunetio BUILD_GPUNETIO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LOGGING=OFF
        -DENABLE_DATAPATH_LOGGING=OFF
        -DBUILD_GPUNETIO=OFF
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
