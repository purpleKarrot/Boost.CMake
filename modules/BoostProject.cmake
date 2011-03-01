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
  foreach(component doc develop runtime)
    string(TOUPPER "${component}" upper)
    set(BOOST_${upper}_COMPONENT "${project}_${component}" PARENT_SCOPE)
    set(has_var "${project}_HAS_${upper}")
    set_boost_project(${has_var} OFF)
    set(BOOST_HAS_${upper}_VAR "${has_var}" PARENT_SCOPE)
  endforeach(component)

  # this will be obsolete once CMake supports the FOLDER property on directories
  set(BOOST_CURRENT_FOLDER "${name}" PARENT_SCOPE)

  # write component file
  set(config_file_prefix "${CMAKE_CURRENT_BINARY_DIR}/${project}")
  set(component_file "${config_file_prefix}.cmake")
  set(BOOST_COMPONENT_FILE "${component_file}.in" PARENT_SCOPE)
  set(include_guard "_boost_${project}_component_included")
  file(WRITE "${component_file}.in"
    "#\n\n"
    "if(${include_guard})\n"
    "  return()\n"
    "endif(${include_guard})\n"
    "set(${include_guard} TRUE)\n\n"
    "get_filename_component(_DIR \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\n\n"
    )
  foreach(depend ${PROJ_DEPENDS})
    file(APPEND "${component_file}.in" "include(\${_DIR}/${depend}.cmake)\n")
  endforeach(depend)

  install(CODE
  "configure_file(\"${component_file}.in\" \"${component_file}\" COPYONLY)
  file(APPEND \"${component_file}\" \"
file(GLOB config_files \\\"\\\${_DIR}/${project}-*.cmake\\\")
foreach(file \\\${config_files})
  include(\"\\\${file}\")
endforeach(file)
\")"
    COMPONENT "${project}_develop"
    )

  install(FILES "${component_file}"
    DESTINATION "share/boost/CMake/components"
    COMPONENT "${project}_develop"
    )

  # write config file
  set(config_file "${config_file_prefix}-config.cmake.in")
  set(BOOST_CONFIG_FILE "${config_file}" PARENT_SCOPE)

  file(WRITE "${config_file}"
    "#\n"
    )

  install(CODE
  "string(TOLOWER \"\${CMAKE_INSTALL_CONFIG_NAME}\" config)
  string(TOUPPER \"\${CMAKE_INSTALL_CONFIG_NAME}\" CONFIG)
  set(config_file \"${config_file_prefix}-\${config}.cmake\")
  configure_file(\"${config_file}\" \"\${config_file}\" @ONLY)
  file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/share/boost/CMake/components\" TYPE FILE FILES \"\${config_file}\")"
    COMPONENT "${project}_develop"
    )
endfunction(boost_project)
