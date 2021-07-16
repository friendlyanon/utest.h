if(PROJECT_IS_TOP_LEVEL)
  set(CMAKE_INSTALL_INCLUDEDIR include/utest CACHE PATH "")
endif()

# Project is configured with no languages, so tell GNUInstallDirs the lib dir
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "")

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

# find_package(<package>) call for consumers to find this project
set(package utest)

install(
    DIRECTORY include/
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    COMPONENT utest_Development
)

install(
    TARGETS utest_utest
    EXPORT utestTargets
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

write_basic_package_version_file(
    "${package}ConfigVersion.cmake"
    COMPATIBILITY SameMajorVersion
    ARCH_INDEPENDENT
)

# Allow package maintainers to freely override the path for the configs
set(
    utest_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/${package}"
    CACHE PATH "CMake package config location relative to the install prefix"
)
mark_as_advanced(utest_INSTALL_CMAKEDIR)

install(
    DIRECTORY cmake/modules
    DESTINATION "${utest_INSTALL_CMAKEDIR}"
    COMPONENT utest_Development
)

install(
    FILES cmake/install-config.cmake
    DESTINATION "${utest_INSTALL_CMAKEDIR}"
    RENAME "${package}Config.cmake"
    COMPONENT utest_Development
)

install(
    FILES "${PROJECT_BINARY_DIR}/${package}ConfigVersion.cmake"
    DESTINATION "${utest_INSTALL_CMAKEDIR}"
    COMPONENT utest_Development
)

install(
    EXPORT utestTargets
    NAMESPACE utest::
    DESTINATION "${utest_INSTALL_CMAKEDIR}"
    COMPONENT utest_Development
)

if(PROJECT_IS_TOP_LEVEL)
  include(CPack)
endif()
