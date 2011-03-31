##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

function(boost_extract archive destination)
  if(NOT IS_ABSOLUTE "${archive}")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${archive}")
      set(archive "${CMAKE_CURRENT_SOURCE_DIR}/${archive}")
    else
      set(archive "${CMAKE_CURRENT_BINARY_DIR}/${archive}")
    endif()
  endif()

  if(NOT IS_ABSOLUTE "${destination}")
    set(destination "${CMAKE_CURRENT_BINARY_DIR}/${destination}")
  endif()

  if(EXISTS "${destination}" AND NOT "${archive}" IS_NEWER_THAN "${destination}")
    return()
  endif()

  # Extract it
  set(tempdir "${destination}-tmp")
  file(MAKE_DIRECTORY "${tempdir}")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz "${archive}"
    WORKING_DIRECTORY "${tempdir}"
    RESULT_VARIABLE rv
    )
  if(NOT rv EQUAL 0)
    file(REMOVE_RECURSE "${tempdir}")
    message(FATAL_ERROR "error: extract of '${archive}' failed")
  endif()

  # Analyze what came out of the tar file
  file(GLOB contents "${tempdir}/*")
  list(LENGTH contents n)
  if(NOT n EQUAL 1 OR NOT IS_DIRECTORY "${contents}")
    set(contents "${tempdir}")
  endif()

  # Move "the one" directory to the final directory
  file(REMOVE_RECURSE "${destination}")
  get_filename_component(contents "${contents}" ABSOLUTE)
  file(RENAME "${contents}" "${destination}")

  # Clean up
  file(REMOVE_RECURSE "${tempdir}")
endfunction(boost_extract)
