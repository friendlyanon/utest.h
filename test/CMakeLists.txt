cmake_minimum_required(VERSION 3.14)

project(utest)

include(../cmake/project-is-top-level.cmake)

if(PROJECT_IS_TOP_LEVEL)
  find_package(utest REQUIRED)
  enable_testing()
endif()

function(set_std target lang version)
  set(feature "${version}")
  if(feature STREQUAL "89")
    set(feature 90)
  endif()
  string(TOUPPER "${lang}" ucase)
  target_compile_features("${target}" PRIVATE "${lang}_std_${feature}")
  # CMake does not add the flag for C standard
  if(lang STREQUAL "c" AND "${CMAKE_${ucase}_COMPILER_ID}" MATCHES "^GNU$|Clang")
    if(version STREQUAL "89")
      # C89 doesn't support the inline keyword
      set(lang gnu)
    endif()
    target_compile_options("${target}" PRIVATE "-std=${lang}${version}")
  endif()
endfunction()

link_libraries(utest::utest)
include(utest_discover_tests)

add_library(c90_lib OBJECT test.c)
set_std(c90_lib c 89)

add_library(c99_lib OBJECT test99.c)
set_std(c99_lib c 99)

if("c_std_11" IN_LIST CMAKE_C_COMPILE_FEATURES)
  add_library(c11_lib OBJECT test11.c type_printers.c)
  set_std(c11_lib c 11)
endif()

add_library(cxx98_lib OBJECT test.cpp)
set_std(cxx98_lib cxx 98)

add_library(cxx11_lib OBJECT test11.cpp)
set_std(cxx11_lib cxx 11)

# Compile the main() function as C++, because there are C++ files in this test
set_property(SOURCE main.c PROPERTY LANGUAGE CXX)

add_executable(utest_test main.c stdint_include.c type_printers.cpp)
target_link_libraries(utest_test PRIVATE c90_lib c99_lib cxx98_lib cxx11_lib)

if(TARGET c11_lib)
  target_link_libraries(utest_test PRIVATE c11_lib)
endif()

utest_discover_tests(utest_test)
