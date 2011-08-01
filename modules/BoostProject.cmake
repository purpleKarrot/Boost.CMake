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

##
function(boost_precache dir)
  set(BOOST_CURRENT_SOURCE_DIR "${Boost_SOURCE_DIR}/${dir}")
  set(BOOST_CURRENT_BINARY_DIR "${Boost_BINARY_DIR}/${dir}")

  include("${BOOST_CURRENT_SOURCE_DIR}/boost_module.cmake")

  set(BOOST_PROJECTS_ALL ${BOOST_PROJECTS_ALL} ${MODULE} PARENT_SCOPE)

  # make sure include directories are absolute
  set(include_dirs)
  foreach(dir ${MODULE_INCLUDE_DIRECTORIES})
    if(IS_ABSOLUTE "${dir}")
      list(APPEND include_dirs "${dir}")
    else()
      list(APPEND include_dirs "${BOOST_CURRENT_SOURCE_DIR}/${dir}")
    endif()
  endforeach(dir)
  set(MODULE_INCLUDE_DIRECTORIES ${include_dirs})

  set(BOOST_${MODULE}_NAME "${MODULE_NAME}" PARENT_SCOPE)
  set(BOOST_${MODULE}_IS_TOOL "${MODULE_TOOL}" PARENT_SCOPE)

  foreach(param ${_boost_component_params})
    set(BOOST_${MODULE}_${param} "${MODULE_${param}}" PARENT_SCOPE)
  endforeach(param)
endfunction(boost_precache)

##
function(boost_get_component_vars)
  set(BOOST_CURRENT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  set(BOOST_CURRENT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")

  include("${BOOST_CURRENT_SOURCE_DIR}/boost_module.cmake")

  # make sure include directories end with /
  set(include_dirs)
  foreach(dir ${MODULE_INCLUDE_DIRECTORIES})
    list(APPEND include_dirs "${dir}/")
  endforeach(dir)
  set(MODULE_INCLUDE_DIRECTORIES ${include_dirs})

  set(BOOST_CURRENT "${MODULE}" PARENT_SCOPE)
  set(BOOST_CURRENT_NAME "${MODULE_NAME}" PARENT_SCOPE)
  set(BOOST_CURRENT_IS_TOOL "${MODULE_TOOL}" PARENT_SCOPE)

  foreach(param ${_boost_component_params})
    set(BOOST_CURRENT_${param} "${MODULE_${param}}" PARENT_SCOPE)
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
