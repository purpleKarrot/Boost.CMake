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
    file(APPEND "${BOOST_EXPORTS_FILE}" "\n"
      "add_executable(\${BOOST_NAMESPACE}${target} IMPORTED)\n"
      )
  elseif(type STREQUAL "SHARED_LIBRARY" OR type STREQUAL "STATIC_LIBRARY")
    if(type STREQUAL "SHARED_LIBRARY")
      set(lower shared)
      set(upper SHARED)
    else()
      set(lower static)
      set(upper STATIC)
    endif()
    set(interface_libraries)
    foreach(lib ${ARGN})
      list(APPEND interface_libraries "\${BOOST_NAMESPACE}${lib}-${lower}")
    endforeach(lib)
    file(APPEND "${BOOST_EXPORTS_FILE}" "\n"
      "add_library(\${BOOST_NAMESPACE}${target} ${upper} IMPORTED)\n"
      "set_target_properties(\${BOOST_NAMESPACE}${target} PROPERTIES\n"
      "  IMPORTED_LINK_INTERFACE_LANGUAGES \"CXX\"\n"
      "  IMPORTED_LINK_INTERFACE_LIBRARIES \"${interface_libraries}\"\n"
      "  )\n"
      )
  endif()

  if(type STREQUAL "EXECUTABLE" OR (type STREQUAL "SHARED_LIBRARY" AND WIN32))
    set(locdir bin)
  else()
    set(locdir lib)
  endif()

  set(export_dir "${CMAKE_BINARY_DIR}/export/$<CONFIGURATION>")
  set(location "${locdir}/$<TARGET_FILE_NAME:${target}>")
  set(location_file "${export_dir}/${target}.location")

  add_custom_command(TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${export_dir}
    COMMAND ${CMAKE_COMMAND} -E echo_append ${location} >${location_file}
    )

  if(NOT type STREQUAL "EXECUTABLE")
    set(implib "lib/$<TARGET_LINKER_FILE_NAME:${target}>")
    set(implib_file "${export_dir}/${target}.implib")
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo_append ${implib} >${implib_file}
      )
  endif(NOT type STREQUAL "EXECUTABLE")

  if(type STREQUAL "SHARED_LIBRARY" AND NOT WIN32)
    set(soname "lib/$<TARGET_SONAME_FILE_NAME:${target}>")
    set(soname_file "${export_dir}/${target}.soname")
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo_append ${soname} >${soname_file}
      )
  endif(type STREQUAL "SHARED_LIBRARY" AND NOT WIN32)

  file(APPEND "${BOOST_TARGETS_FILE}" "${target}\n")
endfunction(boost_export)
