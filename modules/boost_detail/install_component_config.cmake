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

if(NOT targets)
  return()
endif(NOT targets)

if(WIN32)
  set(components_dir "components")
  set(boost_root_dir "\${CMAKE_CURRENT_LIST_DIR}/..")
else(WIN32)
  set(components_dir "share/boost/components")
  set(boost_root_dir "\${CMAKE_CURRENT_LIST_DIR}/../../..")
endif(WIN32)

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
