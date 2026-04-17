vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fogesque/kvalog
    REF v${VERSION}
    SHA512 96018b58f7fb75dc4945c404f5e32593901c78e0c59b505746faa3b77c46d8b4a3dc9e6696133218154d61c94b438555dedc2bc8cfcd9b36c56b1a5cfabca708
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION
"${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
