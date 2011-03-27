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
  set(parameters "AUTHORS;DESCRIPTION;DEPENDS;DEB_DEPENDS;RPM_DEPENDS")
  cmake_parse_arguments(PROJ "TOOL" "" "${parameters}" ${ARGN})

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
  set_boost_project("${project}_TOOL" "${PROJ_TOOL}")
  foreach(param ${parameters})
    set_boost_project("${project}_${param}" "${PROJ_${param}}")
  endforeach(param)

  #
  foreach(component debug develop runtime manual)
    string(TOUPPER "${component}" upper)
    set(BOOST_${upper}_COMPONENT "${project}_${component}" PARENT_SCOPE)
  endforeach(component)

  set(header_only "${project}_HEADER_ONLY")
  set_boost_project(${header_only} ON)
  set(BOOST_HEADER_ONLY "${header_only}" PARENT_SCOPE)

  # this will be obsolete once CMake supports the FOLDER property on directories
  set(BOOST_CURRENT_FOLDER "${name}" PARENT_SCOPE)

  # export file
  set(export_file "${CMAKE_CURRENT_BINARY_DIR}/exports.txt")
  file(WRITE "${export_file}" "")
  set(BOOST_EXPORT_FILE "${export_file}" PARENT_SCOPE)

  # target list file
  set(target_list_file "${CMAKE_CURRENT_BINARY_DIR}/target_list.txt")
  file(WRITE "${target_list_file}" "")
  set(BOOST_TARGET_LIST_FILE "${target_list_file}" PARENT_SCOPE)

  if(PROJ_TOOL)
    set(export_component "${project}_runtime")
  else()
    set(export_component "${project}_develop")
  endif()

  install(CODE
  "set(BOOST_PROJECT ${project})
  set(BOOST_DEPENDS ${PROJ_DEPENDS})
  set(BOOST_TARGETS \"${target_list_file}\")
  set(BOOST_EXPORTS \"${export_file}\")
  set(BOOST_IS_TOOL ${PROJ_TOOL})
  set(BOOST_BINARY_DIR \"${CMAKE_BINARY_DIR}\")
  include(\"${Boost_MODULE_PATH}/BoostInstallComponent.cmake\")"
    COMPONENT "${export_component}"
    )
endfunction(boost_project)
