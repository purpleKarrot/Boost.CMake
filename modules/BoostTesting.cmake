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
  if(NOT Boost_BUILD_TESTS)
    return()
  endif()

  if(NOT MSVC_IDE)
    boost_test_impl_cmake(${name} ${ARGN})
  endif(NOT MSVC_IDE)
  #boost_test_impl_ctest(${name} ${ARGN})
endfunction(boost_add_test)
