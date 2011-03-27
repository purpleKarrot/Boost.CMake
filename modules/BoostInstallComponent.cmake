##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

string(TOLOWER ${CMAKE_INSTALL_CONFIG_NAME} config)
string(TOUPPER ${CMAKE_INSTALL_CONFIG_NAME} CONFIG)
set(export_dir "${BOOST_BINARY_DIR}/export/${CMAKE_INSTALL_CONFIG_NAME}")
file(STRINGS ${BOOST_TARGETS} targets)

if(WIN32)
  set(components_dir "components")
  set(boost_root_dir "\${CMAKE_CURRENT_LIST_DIR}/..")
else(WIN32)
  set(components_dir "share/boost/components")
  set(boost_root_dir "\${CMAKE_CURRENT_LIST_DIR}/../../..")
endif(WIN32)

##########################################################################

set(install_component_file OFF)
set(install_config_file OFF)

if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
  if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "${BOOST_PROJECT}_debug")
    set(install_config_file ON)
  endif()
elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
  if(BOOST_IS_TOOL)
    if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "${BOOST_PROJECT}_runtime")
      set(install_component_file ON)
      set(install_config_file ON)
    endif()
  else()
    if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "${BOOST_PROJECT}_develop")
      set(install_component_file ON)
      set(install_config_file ON)
    endif()
  endif()
endif()

if(NOT targets)
  set(install_config_file OFF)
endif(NOT targets)

##########################################################################
# write component file

if(install_component_file)
  set(component_file "${BOOST_BINARY_DIR}/${BOOST_PROJECT}.cmake")
  set(include_guard "_boost_${BOOST_PROJECT}_component_included")

  file(WRITE ${component_file}
    "#\n\n"
    "if(${include_guard})\n"
    "  return()\n"
    "endif(${include_guard})\n"
    "set(${include_guard} TRUE)\n\n"
    )

  if(NOT BOOST_IS_TOOL)
    foreach(depend ${BOOST_DEPENDS})
      file(APPEND ${component_file}
        "include(\${CMAKE_CURRENT_LIST_DIR}/${depend}.cmake)\n"
        )
    endforeach(depend)
  endif(NOT BOOST_IS_TOOL)

  file(READ ${BOOST_EXPORTS} exports)
  file(APPEND ${component_file} "${exports}")

  if(targets)
    file(APPEND ${component_file} "\n"
      "file(GLOB config_files \"\${CMAKE_CURRENT_LIST_DIR}/${BOOST_PROJECT}-*.cmake\")\n"
      "foreach(file \${config_files})\n"
      "  include(\"\${file}\")\n"
      "endforeach(file)\n"
      )
  endif(targets)

  file(INSTALL
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${components_dir}"
    TYPE FILE
    FILES "${component_file}"
    )

  file(REMOVE "${component_file}")
endif(install_component_file)

##########################################################################
# write config file

if(install_config_file)
  set(config_file "${BOOST_BINARY_DIR}/${BOOST_PROJECT}-${config}.cmake")

  file(WRITE "${config_file}"
    "#\n"
    )

  foreach(target ${targets})
    file(READ "${export_dir}/${target}.location" location)
    file(APPEND ${config_file} "\n"
      "set_property(TARGET \${BOOST_NAMESPACE}${target} APPEND PROPERTY\n"
      "  IMPORTED_CONFIGURATIONS ${CONFIG}\n"
      "  )\n"
      "set_target_properties(\${BOOST_NAMESPACE}${target} PROPERTIES\n"
      "  IMPORTED_LOCATION_${CONFIG} \"${boost_root_dir}/${location}\"\n"
      )

    if(EXISTS "${export_dir}/${target}.implib")
      file(READ "${export_dir}/${target}.implib" implib)
      file(APPEND ${config_file}
        "  IMPORTED_IMPLIB_${CONFIG} \"${boost_root_dir}/${implib}\"\n"
        )
    endif(EXISTS "${export_dir}/${target}.implib")

    if(EXISTS "${export_dir}/${target}.soname")
      file(READ "${export_dir}/${target}.soname" soname)
      file(APPEND ${config_file}
        "  IMPORTED_SONAME_${CONFIG} \"${boost_root_dir}/${soname}\"\n"
        )
    endif(EXISTS "${export_dir}/${target}.soname")

    file(APPEND ${config_file} "  )\n")
  endforeach(target)

  file(INSTALL
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${components_dir}"
    TYPE FILE
    FILES "${config_file}"
    )

  file(REMOVE "${config_file}")
endif(install_config_file)
