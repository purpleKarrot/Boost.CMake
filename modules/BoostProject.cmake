##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)

set(_boost_component_params
  AUTHORS
  DESCRIPTION
  DEPENDS
  RECOMMENDS
  SUGGESTS
  DEB_DEPENDS
  RPM_DEPENDS
  DOC_DIRECTORIES
  TEST_DIRECTORIES
  EXAMPLE_DIRECTORIES
  INCLUDE_DIRECTORIES
  )

function(boost_get_component_vars)
  if(ARGV0)
    set(BOOST_CURRENT_SOURCE_DIR "${Boost_SOURCE_DIR}/libs/${ARGV0}")
    set(BOOST_CURRENT_BINARY_DIR "${Boost_BINARY_DIR}/libs/${ARGV0}")
  else()
    set(BOOST_CURRENT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    set(BOOST_CURRENT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  include("${BOOST_CURRENT_SOURCE_DIR}/boost_module.cmake")

  # put variables into parent scope
  set(BOOST_CURRENT "${MODULE}" PARENT_SCOPE)
  set(BOOST_CURRENT_NAME "${MODULE_NAME}" PARENT_SCOPE)
  set(BOOST_CURRENT_IS_TOOL "${MODULE_TOOL}" PARENT_SCOPE)
  foreach(param ${_boost_component_params})
    set(BOOST_CURRENT_${param} "${MODULE_${param}}" PARENT_SCOPE)
  endforeach(param)

  #
  if(ARGV0)
    return()
  endif()

  # put variables into cache
  list(APPEND BOOST_PROJECTS_ALL ${MODULE})
  set(BOOST_PROJECTS_ALL ${BOOST_PROJECTS_ALL} CACHE INTERNAL "" FORCE)
  set(BOOST_${MODULE}_NAME "${MODULE_NAME}" CACHE INTERNAL "" FORCE)
  set(BOOST_${MODULE}_IS_TOOL "${MODULE_TOOL}" CACHE INTERNAL "" FORCE)
  foreach(param ${_boost_component_params})
    set(BOOST_${MODULE}_${param} "${MODULE_${param}}" CACHE INTERNAL "" FORCE)
  endforeach(param)
endfunction(boost_get_component_vars)

##########################################################################

#   boost_module(<name>
#     [AUTHORS <authors>]
#     [DESCRIPTION <description>]
#     [DEPENDS <depends>]
#     )
#
macro(boost_module name)
  set(MODULE_NAME ${name})
  string(REPLACE " " "_" MODULE "${name}")
  string(TOLOWER "${MODULE}" MODULE)
  cmake_parse_arguments(MODULE "TOOL" "" "${_boost_component_params}" ${ARGN})
endmacro(boost_module)
