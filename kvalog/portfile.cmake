vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fogesque/kvalog
    REF v${VERSION}
    SHA512 c69b1a0a7c123c858fa63118cc32a7fbeaa85c3ba837f47dabab485aa5289dd89a459b6c40ad54bca3ca65441918c51aed1c0faac21c62b020c22eb518673322
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kvalog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION
"${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
