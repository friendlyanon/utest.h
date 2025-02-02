# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
utest.h
-------

This module defines a function to help use the utest test framework.

The :command:`utest_discover_tests` discovers tests by asking the compiled test
executable to enumerate its tests.  This does not require CMake to be re-run
when tests change.  However, it may not work in a cross-compiling environment,
and setting test properties is less convenient.

This command is intended to replace use of :command:`add_test` to register
tests, and will create a separate CTest test for each utest test case.  Note
that this is in some cases less efficient, as common set-up and tear-down logic
cannot be shared by multiple test cases executing in the same instance.
However, it provides more fine-grained pass/fail information to CTest, which is
usually considered as more beneficial.  By default, the CTest test name is the
same as the utest name; see also ``TEST_PREFIX`` and ``TEST_SUFFIX``.

.. command:: utest_discover_tests

  Automatically add tests with CTest by querying the compiled test executable
  for available tests::

    utest_discover_tests(target
                        [EXTRA_ARGS arg1...]
                        [WORKING_DIRECTORY dir]
                        [TEST_PREFIX prefix]
                        [TEST_SUFFIX suffix]
                        [PROPERTIES name1 value1...]
                        [TEST_LIST var]
                        [XUNIT_OUTPUT_DIR dir]
                        [DEPENDS target1...]
    )

  ``utest_discover_tests`` sets up a post-build command on the test executable
  that generates the list of tests by parsing the output from running the test
  with the ``--list-tests`` argument.  This ensures that the full list of tests
  is obtained.  Since test discovery occurs at build time, it is not necessary
  to re-run CMake when the list of tests changes.
  However, it requires that :prop_tgt:`CROSSCOMPILING_EMULATOR` is properly set
  in order to function in a cross-compiling environment.

  Additionally, setting properties on tests is somewhat less convenient, since
  the tests are not available at CMake time.  Additional test properties may be
  assigned to the set of tests as a whole using the ``PROPERTIES`` option.  If
  more fine-grained test control is needed, custom content may be provided
  through an external CTest script using the :prop_dir:`TEST_INCLUDE_FILES`
  directory property.  The set of discovered tests is made accessible to such a
  script via the ``<target>_TESTS`` variable.

  The options are:

  ``target``
    Specifies the utest executable, which must be a known CMake executable
    target.  CMake will substitute the location of the built executable when
    running the test.

  ``EXTRA_ARGS arg1...``
    Any extra arguments to pass on the command line to each test case.

  ``WORKING_DIRECTORY dir``
    Specifies the directory in which to run the discovered test cases.  If this
    option is not provided, the current binary directory is used.  The property
    :prop_tgt:`VS_DEBUGGER_WORKING_DIRECTORY` will be set to this value.

  ``TEST_PREFIX prefix``
    Specifies a ``prefix`` to be prepended to the name of each discovered test
    case.  This can be useful when the same test executable is being used in
    multiple calls to ``utest_discover_tests`` but with different
    ``EXTRA_ARGS``.

  ``TEST_SUFFIX suffix``
    Similar to ``TEST_PREFIX`` except the ``suffix`` is appended to the name of
    every discovered test case.  Both ``TEST_PREFIX`` and ``TEST_SUFFIX`` may
    be specified.

  ``PROPERTIES name1 value1...``
    Specifies additional properties to be set on all tests discovered by this
    invocation of ``utest_discover_tests``.

  ``TEST_LIST var``
    Make the list of tests available in the variable ``var``, rather than the
    default ``<target>_TESTS``.  This can be useful when the same test
    executable is being used in multiple calls to ``utest_discover_tests``.
    Note that this variable is only available in CTest.

  ``XUNIT_OUTPUT_DIR dir``
    If specified, the parameter ``--output=`` is passed to the test executable.
    The actual file name is the same as the test target, including prefix and
    suffix.  This should be used instead of ``EXTRA_ARGS`` to avoid race
    conditions writing the XML result output when using parallel test
    execution.

  ``DEPENDS target1...``
    This argument can be used to append paths of shared library dependencies to
    the ``PATH`` environment variable on Windows systems before executing the
    test executable, so the DLLs can be loaded.  Make sure the targets are not
    wrapped in generator expressions, because they are queried for their
    properties.  Pass those targets as well which are otherwise conditionally
    linked to.

    If this argument is used, then make sure the
    :prop_tgt:`VS_DEBUGGER_ENVIRONMENT` and :prop_test:`ENVIRONMENT` properties
    are not completely overwritten.  See :prop_dir:`TEST_INCLUDE_FILES` for
    providing your own scripts with custom content that could handle the
    latter one.

#]=======================================================================]

function(utest_discover_tests TARGET)
  set(oneArgs WORKING_DIRECTORY TEST_PREFIX TEST_SUFFIX TEST_LIST XUNIT_OUTPUT_DIR)
  set(multiArgs EXTRA_ARGS PROPERTIES DEPENDS)
  cmake_parse_arguments(PARSE_ARGV 1 "" "" "${oneArgs}" "${multiArgs}")

  set(bin_dir "${CMAKE_CURRENT_BINARY_DIR}")

  if(NOT _WORKING_DIRECTORY)
    set(_WORKING_DIRECTORY "${bin_dir}")
  endif()

  set_property(
      TARGET "${TARGET}" PROPERTY
      VS_DEBUGGER_WORKING_DIRECTORY "${_WORKING_DIRECTORY}"
  )

  if(NOT _TEST_LIST)
    set(_TEST_LIST "${TARGET}_TESTS")
  endif()

  # Collect paths of DLL dependencies when the target system is Windows
  set(dependency_paths "")
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND DEFINED _DEPENDS)
    foreach(dep IN LISTS _DEPENDS)
      if(TARGET "${dep}")
        get_target_property(type "${dep}" TYPE)
        if(type STREQUAL "SHARED_LIBRARY")
          list(APPEND dependency_paths "$<TARGET_FILE_DIR:${dep}>")
        endif()
      endif()
    endforeach()
    if(NOT dependency_paths STREQUAL "")
      set_property(
          TARGET "${TARGET}" PROPERTY
          VS_DEBUGGER_ENVIRONMENT "PATH=%PATH%;${dependency_paths}"
      )
    endif()
  endif()

  # Generate a unique name based on the extra arguments
  string(SHA1 args_hash "${_EXTRA_ARGS}")
  string(SUBSTRING "${args_hash}" 0 7 args_hash)

  # Define rule to generate test list for aforementioned test executable
  set(ctest_include_file "${bin_dir}/${TARGET}_include-${args_hash}.cmake")
  set(ctest_tests_file "${bin_dir}/${TARGET}_tests-${args_hash}.cmake")
  get_property(
      crosscompiling_emulator
      TARGET "${TARGET}"
      PROPERTY CROSSCOMPILING_EMULATOR
  )
  add_custom_command(
      TARGET "${TARGET}" POST_BUILD
      BYPRODUCTS "${ctest_tests_file}"
      COMMAND "${CMAKE_COMMAND}"
      -D "TEST_EXECUTABLE=$<TARGET_FILE:${TARGET}>"
      -D "TEST_EXECUTOR=${crosscompiling_emulator}"
      -D "TEST_WORKING_DIR=${_WORKING_DIRECTORY}"
      -D "TEST_EXTRA_ARGS=${_EXTRA_ARGS}"
      -D "TEST_PROPERTIES=${_PROPERTIES}"
      -D "TEST_PREFIX=${_TEST_PREFIX}"
      -D "TEST_SUFFIX=${_TEST_SUFFIX}"
      -D "TEST_LIST=${_TEST_LIST}"
      -D "TEST_ENV_PATH=${dependency_paths}"
      -D "TEST_XUNIT_OUTPUT_DIR=${_XUNIT_OUTPUT_DIR}"
      -D "CTEST_FILE=${ctest_tests_file}"
      -P "${_UTEST_DISCOVER_TESTS_SCRIPT}"
      VERBATIM
  )

  file(
      WRITE "${ctest_include_file}"
      "if(EXISTS \"${ctest_tests_file}\")\n"
      "  include(\"${ctest_tests_file}\")\n"
      "else()\n"
      "  add_test(${TARGET}_NOT_BUILT-${args_hash} ${TARGET}_NOT_BUILT-${args_hash})\n"
      "endif()\n"
  )

  if(NOT CMAKE_VERSION VERSION_LESS 3.10)
    # Add discovered tests to directory TEST_INCLUDE_FILES
    set_property(
        DIRECTORY APPEND PROPERTY
        TEST_INCLUDE_FILES "${ctest_include_file}"
    )
  else()
    # Add discovered tests as directory TEST_INCLUDE_FILE if possible
    get_property(test_include_file_set DIRECTORY PROPERTY TEST_INCLUDE_FILE SET)
    if(NOT test_include_file_set)
      set_property(
          DIRECTORY PROPERTY
          TEST_INCLUDE_FILE "${ctest_include_file}"
      )
    else()
      message(FATAL_ERROR "Cannot set more than one TEST_INCLUDE_FILE")
    endif()
  endif()
endfunction()

set(
    _UTEST_DISCOVER_TESTS_SCRIPT
    "${CMAKE_CURRENT_LIST_DIR}/utest_add_tests.cmake"
)
