##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

if(DEFINED BOOST_BUILD_DOCUMENTATION AND NOT BOOST_BUILD_DOCUMENTATION)
  return()
endif(DEFINED BOOST_BUILD_DOCUMENTATION AND NOT BOOST_BUILD_DOCUMENTATION)

set(BOOST_BUILD_DOCUMENTATION ON)

set(DOXYGEN_SKIP_DOT ON)
find_package(Doxygen)
if(NOT DOXYGEN_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT DOXYGEN_FOUND)

if(CMAKE_HOST_WIN32)
  set(XSLTPROC_EXECUTABLE "$<TARGET_FILE:${BOOST_NAMESPACE}xsltproc>")
else(CMAKE_HOST_WIN32)
  find_program(XSLTPROC_EXECUTABLE xsltproc)
  if(NOT XSLTPROC_EXECUTABLE)
    set(BOOST_BUILD_DOCUMENTATION OFF)
  endif(NOT XSLTPROC_EXECUTABLE)
endif(CMAKE_HOST_WIN32)

find_package(HTMLHelp QUIET)
find_package(DBLATEX QUIET)
find_package(FOProcessor QUIET)

set(BOOST_BUILD_DOCUMENTATION ${BOOST_BUILD_DOCUMENTATION}
  CACHE BOOL "Whether documentation should be built" FORCE)

if(NOT BOOST_BUILD_DOCUMENTATION)
  message(STATUS "Documentation will not be built!")
endif(NOT BOOST_BUILD_DOCUMENTATION)
