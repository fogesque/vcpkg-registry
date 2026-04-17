vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fogesque/errors
    REF v${VERSION}
    SHA512 e48f9758811826e304b7bf6e86f0191361cea28cee913337e6c47de78317183df9d7674b95e81a6f4f2e474e0e628550f2944def59f5aaacb06471de9e1156c1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DERRORS_BUILD_TESTS=OFF
        -DERRORS_BUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/errors)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION
"${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
