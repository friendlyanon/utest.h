cmake_minimum_required(VERSION 3.14)

include(cmake/in-source-guard.cmake)

project(
    utest
    VERSION 0.1.0
    DESCRIPTION "Single header unit testing framework for C and C++"
    HOMEPAGE_URL "https://github.com/sheredom/utest.h"
    LANGUAGES NONE # Speeds up configure
)

include(cmake/project-is-top-level.cmake)
include(cmake/variables.cmake)

# ---- Declare library ----

add_library(utest_utest INTERFACE)
add_library(utest::utest ALIAS utest_utest)

set_property(TARGET utest_utest PROPERTY EXPORT_NAME utest)

target_include_directories(
    utest_utest ${utest_warning_guard}
    INTERFACE
    "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
)

if(UTEST_USE_OLD_QPC)
  target_compile_definitions(
      utest_utest INTERFACE
      "$<BUILD_INTERFACE:UTEST_USE_OLD_QPC>"
  )
endif()

# ---- Install rules ----

include(cmake/install-rules.cmake)

# ---- Developer mode ----

if(NOT utest_DEVELOPER_MODE)
  return()
elseif(NOT PROJECT_IS_TOP_LEVEL)
  message(
      AUTHOR_WARNING
      "Developer mode is intended for developers of utest"
  )
endif()

include(CTest)
if(BUILD_TESTING)
  add_subdirectory(test)
endif()

option(ENABLE_COVERAGE "Enable coverage support separate from CTest's" OFF)
if(ENABLE_COVERAGE)
  include(cmake/coverage.cmake)
endif()

include(cmake/lint-targets.cmake)
include(cmake/spell-targets.cmake)
