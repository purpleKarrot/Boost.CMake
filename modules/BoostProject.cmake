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

set(boost_private_module_dir "${CMAKE_CURRENT_LIST_DIR}/boost_detail")

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
  execute_process(COMMAND
    ${CMAKE_COMMAND} -E cmake_echo_color --blue "++ Boost.${name}"
    )

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
  if(PROJ_TOOL)
    set_boost_project(${header_only} OFF)
  else(PROJ_TOOL)
    set_boost_project(${header_only} ON)
  endif(PROJ_TOOL)
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

  set(install_code "set(BOOST_PROJECT ${project})
    set(BOOST_DEPENDS ${PROJ_DEPENDS})
    set(BOOST_TARGETS \"${target_list_file}\")
    set(BOOST_EXPORTS \"${export_file}\")
    set(BOOST_IS_TOOL ${PROJ_TOOL})
    set(BOOST_BINARY_DIR \"${CMAKE_BINARY_DIR}\")"
    )

  # istall(CODE) seems to ignore CONFIGURATIONS...
  set(debug_match
    "\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Dd][Ee][Bb][Uu][Gg])$\""
    )
  set(release_match
    "\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$\""
    )

  if(PROJ_TOOL)
    install(CODE "if(${release_match})
    ${install_code}
    include(\"${boost_private_module_dir}/install_component.cmake\")
    include(\"${boost_private_module_dir}/install_component_config.cmake\")
  endif(${release_match})"
      COMPONENT "${project}_runtime"
      )
  else(PROJ_TOOL)
    install(CODE "if(${debug_match})
    ${install_code}
    include(\"${boost_private_module_dir}/install_component_config.cmake\")
  endif(${debug_match})"
      COMPONENT "${project}_debug"
      )
    install(CODE "if(${release_match})
    ${install_code}
    include(\"${boost_private_module_dir}/install_component.cmake\")
    include(\"${boost_private_module_dir}/install_component_config.cmake\")
  endif(${release_match})"
      COMPONENT "${project}_develop"
      )
  endif(PROJ_TOOL)
endfunction(boost_project)
