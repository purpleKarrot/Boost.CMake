##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

function(boost_export target)
  get_target_property(type ${target} TYPE)

  if(type STREQUAL "EXECUTABLE")
    file(APPEND ${BOOST_EXPORT_FILE} "\n"
      "add_executable(\${BOOST_NAMESPACE}${target} IMPORTED)\n"
      )
    set(output "bin/$<TARGET_FILE_NAME:${target}>")
  elseif(type STREQUAL "SHARED_LIBRARY")
    set(interface_libraries)
    foreach(lib ${ARGN})
      list(APPEND interface_libraries "\${BOOST_NAMESPACE}${lib}-shared")
    endforeach(lib)
    file(APPEND ${BOOST_EXPORT_FILE} "\n"
      "add_library(\${BOOST_NAMESPACE}${target} SHARED IMPORTED)\n"
      "set_target_properties(\${BOOST_NAMESPACE}${target} PROPERTIES\n"
      "  IMPORTED_LINK_INTERFACE_LANGUAGES \"CXX\"\n"
      "  IMPORTED_LINK_INTERFACE_LIBRARIES \"${interface_libraries}\"\n"
      "  )\n"
      )
    set(output "lib/$<TARGET_LINKER_FILE_NAME:${target}>")
  elseif(type STREQUAL "STATIC_LIBRARY")
    set(interface_libraries)
    foreach(lib ${ARGN})
      list(APPEND interface_libraries "\${BOOST_NAMESPACE}${lib}-static")
    endforeach(lib)
    file(APPEND ${BOOST_EXPORT_FILE} "\n"
      "add_library(\${BOOST_NAMESPACE}${target} STATIC IMPORTED)\n"
      "set_target_properties(\${BOOST_NAMESPACE}${target} PROPERTIES\n"
      "  IMPORTED_LINK_INTERFACE_LANGUAGES \"CXX\"\n"
      "  IMPORTED_LINK_INTERFACE_LIBRARIES \"${interface_libraries}\"\n"
      "  )\n"
      )
    set(output "lib/$<TARGET_LINKER_FILE_NAME:${target}>")
  endif()

  set(export_dir "${CMAKE_BINARY_DIR}/export/$<CONFIGURATION>")
  set(export_file "${export_dir}/${target}.txt")
  add_custom_command(TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${export_dir}
    COMMAND ${CMAKE_COMMAND} -E echo_append ${output} >${export_file}
    )

  file(APPEND ${BOOST_TARGET_LIST_FILE} "${target}\n")
endfunction(boost_export)
