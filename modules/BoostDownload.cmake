##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

function(boost_download file url md5)
  if(NOT IS_ABSOLUTE "${file}")
    set(file "${CMAKE_CURRENT_BINARY_DIR}/${file}")
  endif()

  if(EXISTS "${file}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E md5sum "${file}"
      OUTPUT_VARIABLE output
      )
    if("${output}" MATCHES "^${md5} ")
      return()
    endif()
  endif()

  message(STATUS "Downloading '${url}'")
  file(DOWNLOAD "${url}" "${file}" SHOW_PROGRESS EXPECTED_MD5 "${md5}")
endfunction(boost_download)
