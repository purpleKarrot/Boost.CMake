################################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>              #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

include(CMakeParseArguments)
include(BoostTesting)

# This function is used to add multiple tests at once.
#
#   boost_test_suite(
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
#   boost_test_suite(
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
function(boost_test_suite)
  if(NOT BOOST_CURRENT_TEST_ENABLED)
    return()
  endif()

  set(args COMPILE COMPILE_FAIL LINK LINK_FAIL RUN RUN_FAIL
    LINK_BOOST_LIBRARIES LINK_LIBRARIES)
  cmake_parse_arguments(TEST "" "" "${args}" ${ARGN})

  foreach(test ${TEST_COMPILE})
    boost_add_test(${test} COMPILE)
  endforeach(test)

  foreach(test ${TEST_COMPILE_FAIL})
    boost_add_test(${test} COMPILE FAIL)
  endforeach(test)

  foreach(test ${TEST_LINK})
    boost_add_test(${test} LINK
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)

  foreach(test ${TEST_LINK_FAIL})
    boost_add_test(${test} LINK FAIL
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)

  foreach(test ${TEST_RUN})
    boost_add_test(${test} RUN
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)

  foreach(test ${TEST_RUN_FAIL})
    boost_add_test(${test} RUN FAIL
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)
endfunction(boost_test_suite)
