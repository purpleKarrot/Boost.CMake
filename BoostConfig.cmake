##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

# - Config file for the Boost package
# It defines the following variables
#  BOOST_INCLUDE_DIRS - include directories for Boost
#  BOOST_LIBRARY_DIRS - library directories for Boost (normally not used!)
#  BOOST_LIBRARIES    - libraries to link against
#  BOOST_USE_FILE     -

set(BOOST_INCLUDE_DIRS "@BOOST_INCLUDE_DIRS@")
set(BOOST_LIBRARY_DIRS "@BOOST_LIB_DIR@")

foreach(component ${Boost_FIND_COMPONENTS})
  message(STATUS "Looking for Boost component: ${component}")
  set(component_file "@BOOST_CMAKE_DIR@/${component}.cmake")
  if(EXISTS "${component_file}")
    include("${component_file}")
    set(Boost_${component}_FOUND TRUE)
  else()
    set(Boost_${component}_FOUND FALSE)
    set(Boost_FOUND FALSE)
  endif()
foreach(component)
