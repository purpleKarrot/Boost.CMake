##########################################################################
# Copyright (C) 2007-2008 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  return()
endif()

list(SORT BOOST_PROJECTS_ALL)
list(REMOVE_DUPLICATES BOOST_PROJECTS_ALL)

# function to set CPACK_COMPONENT_*
function(set_cpack_component name)
  string(TOUPPER "CPACK_COMPONENT_${name}" variable)
  set(${variable} ${ARGN} PARENT_SCOPE)
endfunction(set_cpack_component)

set(CPACK_COMPONENTS_ALL)

foreach(project ${BOOST_PROJECTS_ALL})
  set(is_tool     ${BOOST_${project}_IS_TOOL})
  set(header_only ${BOOST_${project}_HEADER_ONLY})
  set(name        "${BOOST_${project}_NAME}")
  set(description "${BOOST_${project}_DESCRIPTION}")
  set(group       "boost_${project}")

  if(NOT is_tool)
    set(name "The Boost ${name} Library")
  endif()

  set_cpack_component(GROUP_${group}_DISPLAY_NAME "${name}")
  set_cpack_component(GROUP_${group}_DESCRIPTION "${description}")

  set_cpack_component(${project}_DEVELOP_GROUP "${group}")
  set_cpack_component(${project}_RUNTIME_GROUP "${group}")
  set_cpack_component(${project}_MANUAL_GROUP  "${group}")
  set_cpack_component(${project}_DEBUG_GROUP   "${group}")

  set_cpack_component(${project}_DEVELOP_DISPLAY_NAME "${name} development files")
  set_cpack_component(${project}_RUNTIME_DISPLAY_NAME "${name}")
  set_cpack_component(${project}_MANUAL_DISPLAY_NAME  "${name} documentation")
  set_cpack_component(${project}_DEBUG_DISPLAY_NAME   "${name} debug symbols")

  set_cpack_component(${project}_DEVELOP_DESCRIPTION "${description}")
  set_cpack_component(${project}_RUNTIME_DESCRIPTION "${description}")
  set_cpack_component(${project}_MANUAL_DESCRIPTION  "${description}")
  set_cpack_component(${project}_DEBUG_DESCRIPTION   "${description}")

  # Debian
  string(REPLACE "_" "-" debian_name "${project}")
  if(is_tool)
    set(prefix "boost-")
  else()
    set(prefix "libboost-")
  endif()

  set_cpack_component(${project}_DEVELOP_DEB_PACKAGE "${prefix}${debian_name}-dev")
  set_cpack_component(${project}_RUNTIME_DEB_PACKAGE "${prefix}${debian_name}")
  set_cpack_component(${project}_MANUAL_DEB_PACKAGE  "${prefix}${debian_name}-doc")
  set_cpack_component(${project}_DEBUG_DEB_PACKAGE   "${prefix}${debian_name}-dbg")

  cmake_parse_arguments(DEB "" "" "DEV;LIB" ${BOOST_${project}_DEB_DEPENDS})
  list(APPEND CPACK_DEBIAN_BUILD_DEPENDS ${DEB_DEV} ${DEB_UNPARSED_ARGUMENTS})

  set_cpack_component(${project}_DEVELOP_DEBIAN_DEPENDS ${DEB_DEV})
  set_cpack_component(${project}_RUNTIME_DEBIAN_DEPENDS ${DEB_LIB} ${DEB_UNPARSED_ARGUMENTS})

  if(header_only)
    set_cpack_component(${project}_DEVELOP_BINARY_INDEP 1)
  endif(header_only)
  set_cpack_component(${project}_MANUAL_BINARY_INDEP 1)

  # dependencies
  set(develop_depends)
  set(runtime_depends)
  set(debug_depends)

  if(NOT header_only)
    list(APPEND develop_depends ${project}_runtime)
  endif(NOT header_only)

  foreach(dependancy ${BOOST_${project}_DEPENDS})
    if(NOT is_tool AND NOT BOOST_${dependancy}_IS_TOOL)
      list(APPEND develop_depends ${dependancy}_develop)
    endif(NOT is_tool AND NOT BOOST_${dependancy}_IS_TOOL)
    if(NOT header_only AND NOT BOOST_${dependancy}_HEADER_ONLY)
      list(APPEND runtime_depends ${dependancy}_runtime)
      list(APPEND debug_depends ${dependancy}_debug)
    endif(NOT header_only AND NOT BOOST_${dependancy}_HEADER_ONLY)
  endforeach(dependancy)

  set_cpack_component(${project}_DEVELOP_DEPENDS "${develop_depends}")
  set_cpack_component(${project}_RUNTIME_DEPENDS "${runtime_depends}")
  set_cpack_component(${project}_DEBUG_DEPENDS "${debug_depends}")

  if(is_tool)
    list(APPEND CPACK_COMPONENTS_ALL ${project}_runtime)
  else(is_tool)
    list(APPEND CPACK_COMPONENTS_ALL ${project}_develop)
  endif(is_tool)

  if(NOT header_only AND NOT is_tool)
    list(APPEND CPACK_COMPONENTS_ALL
      ${project}_runtime
      ${project}_debug
      )
  endif(NOT header_only AND NOT is_tool)

  list(APPEND CPACK_COMPONENTS_ALL ${project}_manual)
endforeach(project)

list(SORT CPACK_COMPONENTS_ALL)
list(REMOVE_DUPLICATES CPACK_COMPONENTS_ALL)

if(NOT DEFINED CPACK_RESOURCE_FILE_LICENSE)
  set(CPACK_RESOURCE_FILE_LICENSE "${Boost_RESOURCE_PATH}/LICENSE_1_0.txt")
endif(NOT DEFINED CPACK_RESOURCE_FILE_LICENSE)

##########################################################################
# Icons and Images                                                       #
##########################################################################

set(CPACK_NSIS_INSTALLER_MUI_ICON_CODE "
!define MUI_ICON \\\"${Boost_RESOURCE_PATH}/boost.ico\\\"
!define MUI_UNICON \\\"${Boost_RESOURCE_PATH}/boost.ico\\\"
!define MUI_HEADERIMAGE_BITMAP \\\"${Boost_RESOURCE_PATH}\\\\boost.bmp\\\"
!define MUI_WELCOMEFINISHPAGE_BITMAP \\\"${Boost_RESOURCE_PATH}\\\\sidebar.bmp\\\"
")

set(CPACK_NSIS_INSTALLED_ICON_NAME "Uninstall.exe")

##########################################################################
#                                                                        #
##########################################################################

include(CPack)

include(BoostDebian)
#include(BoostRPM)
