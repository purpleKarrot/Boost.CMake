##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


##
function(boost_add_pch name source_list)
  if(NOT MSVC)
    return()
  endif(NOT MSVC)

  set(pch_header "${CMAKE_CURRENT_BINARY_DIR}/${name}_pch.hpp")
  set(pch_source "${CMAKE_CURRENT_BINARY_DIR}/${name}_pch.cpp")
  set(pch_binary "${CMAKE_CURRENT_BINARY_DIR}/${name}.pch")

  if(MSVC_IDE)
    set(pch_binary "$(IntDir)/${name}.pch")
  endif(MSVC_IDE)

  file(WRITE ${pch_header}.in "/* ${name} precompiled header file */\n\n")
  foreach(header ${ARGN})
    if(header MATCHES "^<.*>$")
      file(APPEND ${pch_header}.in "#include ${header}\n")
    else()
      get_filename_component(header ${header} ABSOLUTE)
      file(APPEND ${pch_header}.in "#include \"${header}\"\n")
    endif()
  endforeach(header)
  configure_file(${pch_header}.in ${pch_header} COPYONLY)

  file(WRITE ${pch_source}.in "#include \"${pch_header}\"\n")
  configure_file(${pch_source}.in ${pch_source} COPYONLY)

  set_source_files_properties(${pch_source} PROPERTIES
    COMPILE_FLAGS "/Yc\"${pch_header}\" /Fp\"${pch_binary}\""
    OBJECT_OUTPUTS "${pch_binary}"
    )

  set_source_files_properties(${${source_list}} PROPERTIES
    COMPILE_FLAGS "/Yu\"${pch_header}\" /FI\"${pch_header}\" /Fp\"${pch_binary}\""
    OBJECT_DEPENDS "${pch_binary}"
    )

  set(${source_list} ${pch_source} ${${source_list}} PARENT_SCOPE)
endfunction(boost_add_pch)
