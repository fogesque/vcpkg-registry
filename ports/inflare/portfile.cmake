vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fogesque/inflare
    REF v${VERSION}
    SHA512 0
    HEAD_REF main
    AUTHORIZATION_TOKEN "$ENV{INFLARE_GITHUB_TOKEN}"
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
