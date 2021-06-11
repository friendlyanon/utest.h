# ---- Developer mode ----

# Developer mode enables targets and code paths in the CMake scripts that are
# only relevant for the developer(s) of utest
# Targets necessary to build the project must be provided unconditionally, so
# consumers can trivially build and package the project
if(PROJECT_IS_TOP_LEVEL)
  option(utest_DEVELOPER_MODE "Enable developer mode" OFF)
  option(BUILD_SHARED_LIBS "Build shared libs." OFF)
endif()

# ---- Warning guard ----

# target_include_directories with the SYSTEM modifier will request the compiler
# to omit warnings from the provided paths, if the compiler supports that
# This is to provide a user experience similar to find_package when
# add_subdirectory or FetchContent is used to consume this project
set(utest_warning_guard "")
if(NOT PROJECT_IS_TOP_LEVEL)
  option(
      utest_INCLUDES_WITH_SYSTEM
      "Use SYSTEM modifier for utest's includes, disabling warnings"
      ON
  )
  mark_as_advanced(utest_INCLUDES_WITH_SYSTEM)
  if(utest_INCLUDES_WITH_SYSTEM)
    set(utest_warning_guard SYSTEM)
  endif()
endif()

# ---- utest modules ----

# Make the discovery module available for include()
if(NOT PROJECT_IS_TOP_LEVEL)
  set(module_paths "${CMAKE_MODULE_PATH}")
  list(APPEND module_paths "${PROJECT_SOURCE_DIR}/cmake/modules")
  set(CMAKE_MODULE_PATH "${module_paths}" PARENT_SCOPE)
  unset(module_paths)
else()
  list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")
endif()

# ---- Windows QPC ----

option(UTEST_USE_OLD_QPC "Use the older QueryPerformanceCounter function on \
Windows. Note that this should be enabled when compiling on Windows 10 and \
the Windows 10 SDK is version 17763 or older, because the headers in those \
versions have bugs in them. Enabled by default, because Windows 10 LTSC is \
based on 17763" ON)
