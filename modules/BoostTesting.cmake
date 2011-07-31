################################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>                   #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

## include("${CMAKE_CURRENT_LIST_DIR}/boost_detail/test_impl_ctest.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/boost_detail/test_impl_cmake.cmake")

# This function creates a Boost regression test. If the test can be built,
# executed, and exits with a return code of zero, it will be considered to have
# passed.
#
#   boost_add_test(name [COMPILE|LINK|RUN] [FAIL]
#     [source1 source2 ...]
#     [LINK_BOOST_LIBRARIES boostlib1 boostlib2 ...]
#     [LINK_LIBRARIES linklibs ...]
#     [ARGS arg1 arg2... ]
#     )
#
# 'name' is the name of the test. source1, source2, etc. are the
# source files that will be built and linked into the test
# executable. If no source files are provided, the file "name.cpp"
# will be used instead.
#
# There are several optional arguments to control how the regression
# test is built and executed:
#
# LINK_BOOST_LIBRARIES: States that this test executable depends on and links
# against another Boost library.
#
# LINK_LIBRARIES: Provides additional libraries against which the test
# executable will be linked. For example, one might provide "expat"
# as options to LINK_LIBRARIES, to state that this executable should be
# linked against the external "expat" library. Use LINK_LIBRARIES for
# libraries external to Boost; for Boost libraries, use LINK_BOOST_LIBRARIES.
#
# ARGS: Provides additional arguments that will be passed to the
# test executable when it is run.
#
function(boost_add_test name)
  if(NOT BOOST_CURRENT_TEST_ENABLED)
    return()
  endif()

  if(NOT MSVC_IDE)
    boost_test_impl_cmake(${name} ${ARGN})
  endif(NOT MSVC_IDE)
  #boost_test_impl_ctest(${name} ${ARGN})
endfunction(boost_add_test)


# This function is used to add multiple tests at once.
#
#   boost_add_multiple_tests(
#     [COMPILE <list of source files>]
#     [COMPILE_FAIL <list of source files>]
#     [LINK <list of source files>]
#     [LINK_FAIL <list of source files>]
#     [RUN <list of source files>]
#     [RUN_FAIL <list of source files>]
#     [LINK_BOOST_LIBRARIES <list of boost libraries to link>]
#     [LINK_LIBRARIES <list of third party libraries to link>]
#     )
#
# Each file listed after COMPILE, LINK, RUN or their _FAIL conterparts creates
# one test case.
#
#   boost_add_multiple_tests(
#     COMPILE
#       foo
#       bar
#     LINK
#       baz
#     LINK_BOOST_LIBRARIES
#       unit_test_framework
#     )
#
# Is identical to:
#
#   boost_add_test(foo COMPILE foo.cpp LINK_BOOST_LIBRARIES unit_test_framework)
#   boost_add_test(bar COMPILE bar.cpp LINK_BOOST_LIBRARIES unit_test_framework)
#   boost_add_test(baz LINK    baz.cpp LINK_BOOST_LIBRARIES unit_test_framework)
#
function(boost_add_multiple_tests)
  if(NOT BOOST_CURRENT_TEST_ENABLED)
    return()
  endif()

  set(args COMPILE COMPILE_FAIL LINK LINK_FAIL MODULE MODULE_FAIL RUN RUN_FAIL
    PYTHON PYTHON_FAIL LINK_BOOST_LIBRARIES LINK_LIBRARIES)
  cmake_parse_arguments(TEST "" "" "${args}" ${ARGN})

  foreach(type COMPILE LINK MODULE RUN PYTHON)
    foreach(test ${TEST_${type}})
      boost_add_test(${test} ${type}
        LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
        LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
        )
    endforeach(test)
    foreach(test ${TEST_${type}_FAIL})
      boost_add_test(${test} ${type} FAIL
        LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
        LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
        )
    endforeach(test)
  endforeach(type)
endfunction(boost_add_multiple_tests)

macro(boost_test_suite)
  boost_add_multiple_tests(${ARGN})
endmacro(boost_test_suite)