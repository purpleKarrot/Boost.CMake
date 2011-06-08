##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostForwardFile)
include(CMakeParseArguments)


#
#   boost_add_headers(
#     <list of header files and folders>
#     [LOCATION <location>]
#     )
#
function(boost_add_headers)
  cmake_parse_arguments(HDR "" "LOCATION" "" ${ARGN})
  set(fwd_location "${CMAKE_BINARY_DIR}/include/boost/${HDR_LOCATION}")

  foreach(header ${HDR_UNPARSED_ARGUMENTS})
    get_filename_component(absolute "${header}" ABSOLUTE)
    get_filename_component(name "${header}" NAME)
    boost_forward("${absolute}" "${fwd_location}/${name}")

    if(IS_DIRECTORY "${absolute}")
      set(signature DIRECTORY)
      string(REGEX REPLACE "/$" "" header "${header}") # remove trailing slash
    else(IS_DIRECTORY "${absolute}")
      set(signature FILES)
    endif(IS_DIRECTORY "${absolute}")

    install(${signature} ${header}
      DESTINATION "include/boost/${HDR_LOCATION}/"
      COMPONENT "${BOOST_DEVELOP_COMPONENT}"
      CONFIGURATIONS "Release"
      )
  endforeach(header)
endfunction(boost_add_headers)


function(boost_add_headers_this_function_is_deprecated)
  cmake_parse_arguments(HDR "" "PREFIX" "" ${ARGN})

  if(HDR_PREFIX MATCHES "^!(.*)!(.*)!$")
    get_filename_component(rootdir "${CMAKE_MATCH_1}" ABSOLUTE)
    set(prefix "${CMAKE_MATCH_2}")
  else()
    set(rootdir "${CMAKE_CURRENT_SOURCE_DIR}")
    set(prefix "${HDR_PREFIX}")
  endif()

  foreach(header ${HDR_UNPARSED_ARGUMENTS})
    get_filename_component(absolute "${header}" ABSOLUTE)
    get_filename_component(path "${absolute}" PATH)
    file(RELATIVE_PATH location "${rootdir}" "${path}")
    string(REGEX REPLACE "^/*boost/*" "" location "${prefix}/${location}")
    boost_add_headers("${absolute}" LOCATION "${location}")
  endforeach(header)
endfunction(boost_add_headers_this_function_is_deprecated)
