##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


if(CMAKE_HOST_WIN32 AND NOT DEFINED MKLINK_WORKING)
  set(test_file ${CMAKE_CURRENT_BINARY_DIR}/symlinktest)
  file(TO_NATIVE_PATH ${CMAKE_CURRENT_LIST_DIR} file)
  file(TO_NATIVE_PATH ${test_file} target)
  execute_process(COMMAND cmd /C mklink ${target} ${file} OUTPUT_QUIET)
  if(EXISTS ${test_file})
    set(MKLINK_WORKING TRUE CACHE INTERNAL "")
  else(EXISTS ${test_file})
    set(MKLINK_WORKING FALSE CACHE INTERNAL "")
    message(STATUS "Symlinks are NOT supported.")
  endif(EXISTS ${test_file})
endif(CMAKE_HOST_WIN32 AND NOT DEFINED MKLINK_WORKING)


# Create a symbolic link (new -> old) to a file or directory.
#
#   boost_create_symlink(<old> <new>)
#
# On Windows, symlinks are available since Vista, but they require the
# /Create Symbolic Link/ privilege, which only administrators have by default.
function(boost_create_symlink old new)
  if(NOT CMAKE_HOST_WIN32)
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${old} ${new})
  elseif(MKLINK_WORKING)
    file(TO_NATIVE_PATH "${new}" native_new)
    file(TO_NATIVE_PATH "${old}" native_old)
    if(IS_DIRECTORY "${old}")
      execute_process(COMMAND cmd /C mklink /D ${native_new} ${native_old} OUTPUT_QUIET)
    else(IS_DIRECTORY "${old}")
      execute_process(COMMAND cmd /C mklink ${native_new} ${native_old} OUTPUT_QUIET)
    endif(IS_DIRECTORY "${old}")
  else()
    message(FATAL_ERROR "Unable to create symbolic link: '${new}' -> '${old}'")
  endif()
endfunction(boost_create_symlink)


# Make a header file available from another path.
#
#   boost_forward_header(<file> <target>)
#
# Where <file> is a path to an existing file that you want to include as if
# it were located at <target>.
function(boost_forward_header file target)
  set(file_content)
  if(EXISTS "${target}")
    file(READ "${target}" file_content)
  endif(EXISTS "${target}")
  if(NOT file_content STREQUAL "#include \"${file}\"\n")
    file(WRITE "${target}" "#include \"${file}\"\n")
  endif(NOT file_content STREQUAL "#include \"${file}\"\n")
endfunction(boost_forward_header)


#
#   boost_forward(<file> <target>)
#
# This function creates symlinks where available. As a fallback it simply creates
# a file at the target position that [c++] `#include`s the appropriate file.
function(boost_forward file target)
  get_filename_component(directory ${target} PATH)
  file(MAKE_DIRECTORY ${directory})

  if(EXISTS "${target}")
    return()
  endif(EXISTS "${target}")

  if(NOT CMAKE_HOST_WIN32 OR MKLINK_WORKING)
    boost_create_symlink(${file} ${target})
  else()
    # create forwarding headers
    if(IS_DIRECTORY "${file}")
      # TODO
      message(STATUS "TODO: forward directory: ${file} -> ${target}")
    else(IS_DIRECTORY "${file}")
      boost_forward_header("${file}" "${target}")
    endif(IS_DIRECTORY "${file}")
  endif()
endfunction(boost_forward)
