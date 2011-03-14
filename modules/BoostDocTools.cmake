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

find_package(XSLTPROC)
if(NOT XSLTPROC_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT XSLTPROC_FOUND)

find_package(DocBook)
if(NOT DOCBOOK_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT DOCBOOK_FOUND)

find_package(HTMLHelp QUIET)
find_package(DBLATEX QUIET)
find_package(FOP QUIET)

set(BOOST_BUILD_DOCUMENTATION ${BOOST_BUILD_DOCUMENTATION}
  CACHE BOOL "Whether documentation should be built" FORCE)

if(NOT BOOST_BUILD_DOCUMENTATION)
  message(STATUS "Documentation will not be built!")
endif(NOT BOOST_BUILD_DOCUMENTATION)
