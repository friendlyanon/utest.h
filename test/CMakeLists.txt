cmake_minimum_required(VERSION 3.14)

project(utest)

include(../cmake/project-is-top-level.cmake)

if(PROJECT_IS_TOP_LEVEL)
  find_package(utest REQUIRED)
  enable_testing()
endif()

function(target_concrete_std target lang version)
  set(extensions NO)
  if(ARGC GREATER "3")
    set(extensions "${ARGV3}")
  endif()
  set_target_properties(
      "${target}" PROPERTIES
      "${lang}_STANDARD" "${version}"
      "${lang}_STANDARD_REQUIRED" YES
      "${lang}_EXTENSIONS" "${extensions}"
  )
endfunction()

link_libraries(utest::utest)
include(utest_discover_tests)

add_library(c90_lib OBJECT test.c)
target_concrete_std(c90_lib C 90 YES)

add_library(c99_lib OBJECT test99.c)
target_concrete_std(c99_lib C 99)

if("c_std_11" IN_LIST CMAKE_C_COMPILE_FEATURES)
  add_library(c11_lib OBJECT test11.c type_printers.c)
  target_concrete_std(c11_lib C 11)
endif()

add_library(cxx98_lib OBJECT test.cpp)
target_concrete_std(cxx98_lib CXX 98 YES)

add_library(cxx11_lib OBJECT test11.cpp)
target_concrete_std(cxx11_lib CXX 11)

# Compile the main() function as C++, because there are C++ files in this test
set_property(SOURCE main.c PROPERTY LANGUAGE CXX)

add_executable(utest_test main.c stdint_include.c type_printers.cpp)
target_link_libraries(utest_test PRIVATE c90_lib c99_lib cxx98_lib cxx11_lib)

if(TARGET c11_lib)
  target_link_libraries(utest_test PRIVATE c11_lib)
endif()

utest_discover_tests(utest_test)
