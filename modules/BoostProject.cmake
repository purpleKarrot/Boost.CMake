##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)

##########################################################################

## function to set global project variables
function(set_boost_project name value)
  set(BOOST_PROJECT_${name} "${value}" CACHE INTERNAL "" FORCE)
endfunction(set_boost_project)

##########################################################################

# use this function as a replacement for 'project' in boost projects.
#
#   boost_project(<name>
#     [AUTHORS <authors>]
#     [DESCRIPTION <description>]
#     [DEPENDS <depends>]
#     )
#
function(boost_project name)
  set(parameters "AUTHORS;DESCRIPTION;DEPENDS")
  cmake_parse_arguments(PROJ "" "" "${parameters}" ${ARGN})

# if(NOT _BOOST_MONOLITHIC_BUILD)
#   # TODO: check for existence of DEPENDS header files.
#   # Currently this is impossible. It will be possible once all
#   # libraries will provide a <boost/lib/lib.hpp> file.
#   find_package(Boost)
#   include_directories(${Boost_INCLUDE_DIRS})
#   link_directories(${Boost_LIBRARY_DIRS})
# endif(NOT _BOOST_MONOLITHIC_BUILD)

  string(REPLACE " " "_" project "${name}")
  string(TOLOWER "${project}" project)
  set(BOOST_CURRENT_PROJECT "${project}" PARENT_SCOPE)
  project("${project}")
  
  list(APPEND BOOST_PROJECTS_ALL ${project})
  set(BOOST_PROJECTS_ALL ${BOOST_PROJECTS_ALL} CACHE INTERNAL "" FORCE)

  # join description to a single string
  string(REPLACE ";" " " PROJ_DESCRIPTION "${PROJ_DESCRIPTION}")

  # set global variables
  set_boost_project("${project}_NAME" "${name}")
  foreach(param ${parameters})
    set_boost_project("${project}_${param}" "${PROJ_${param}}")
  endforeach(param)

  #
  foreach(component dev doc exe lib)
    string(TOUPPER "${component}" upper)
    set(BOOST_${upper}_COMPONENT "${project}_${component}" PARENT_SCOPE)
    set(has_var "${project}_HAS_${upper}")
    set_boost_project(${has_var} OFF)
    set(BOOST_HAS_${upper}_VAR "${has_var}" PARENT_SCOPE)
  endforeach(component)

  # this will be obsolete once CMake supports the FOLDER property on directories
  set(BOOST_CURRENT_FOLDER "${name}" PARENT_SCOPE)
endfunction(boost_project)
