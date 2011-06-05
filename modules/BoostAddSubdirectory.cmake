################################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>                   #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################


# add this directory iff building documentation is enabled
function(boost_add_docs_directory directory)
  if(NOT DEFINED BOOST_ENABLED_DOCS OR BOOST_ENABLED_DOCS STREQUAL "NONE")
    return()
  endif(NOT DEFINED BOOST_ENABLED_DOCS OR BOOST_ENABLED_DOCS STREQUAL "NONE")
  if(BOOST_ENABLED_DOCS STREQUAL "ALL")
    set(enabled 1)
  else(BOOST_ENABLED_DOCS STREQUAL "ALL")
    list(FIND BOOST_ENABLED_DOCS ${BOOST_CURRENT_PROJECT} enabled)
  endif(BOOST_ENABLED_DOCS STREQUAL "ALL")
  if(enabled GREATER "-1")
    add_subdirectory("${directory}")
  endif(enabled GREATER "-1")
endfunction(boost_add_docs_directory)

# add this directory iff building test is enabled
function(boost_add_tests_directory directory)
  if(NOT DEFINED BOOST_ENABLED_TESTS OR BOOST_ENABLED_TESTS STREQUAL "NONE")
    return()
  endif(NOT DEFINED BOOST_ENABLED_TESTS OR BOOST_ENABLED_TESTS STREQUAL "NONE")
  if(BOOST_ENABLED_TESTS STREQUAL "ALL")
    set(enabled 1)
  else(BOOST_ENABLED_TESTS STREQUAL "ALL")
    list(FIND BOOST_ENABLED_TESTS ${BOOST_CURRENT_PROJECT} enabled)
  endif(BOOST_ENABLED_TESTS STREQUAL "ALL")
  if(enabled GREATER "-1")
    add_subdirectory("${directory}")
  endif(enabled GREATER "-1")
endfunction(boost_add_tests_directory)


# add this directory iff building examples is enabled
function(boost_add_examples_directory directory)
  if(NOT DEFINED BOOST_ENABLED_EXAMPLES OR BOOST_ENABLED_EXAMPLES STREQUAL "NONE")
    return()
  endif(NOT DEFINED BOOST_ENABLED_EXAMPLES OR BOOST_ENABLED_EXAMPLES STREQUAL "NONE")
  if(BOOST_ENABLED_EXAMPLES STREQUAL "ALL")
    set(enabled 1)
  else(BOOST_ENABLED_EXAMPLES STREQUAL "ALL")
    list(FIND BOOST_ENABLED_EXAMPLES ${BOOST_CURRENT_PROJECT} enabled)
  endif(BOOST_ENABLED_EXAMPLES STREQUAL "ALL")
  if(enabled GREATER "-1")
    add_subdirectory("${directory}")
  endif(enabled GREATER "-1")
endfunction(boost_add_examples_directory)
