vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fogesque/kvalog
    REF v${VERSION}
    SHA512 a0c28f9a63fa997e37ae19732343c6a7d249fe36f4710d273a7ffb1da3f64cdb90a7c270e85228143395be6e476cb284b9524639f592c294755026525eea0bd0
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
