vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fogesque/inflare
    REF v${VERSION}
    SHA512 aee6951c9348c99ce7971facfb04ed3ccc472f3dad2c17b764470ab8a4409cf64789b00d0317ecc7f2aefaf97455f61f1e8a31327abe4dc558db8d44a007f7c1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/inflare)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
