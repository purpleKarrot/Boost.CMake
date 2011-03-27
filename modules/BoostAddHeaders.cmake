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
#     <list of header files>
#     [PREFIX <prefix>]
#     )
#
function(boost_add_headers)
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
    file(RELATIVE_PATH relative "${rootdir}" "${absolute}")
    boost_forward_file("${absolute}"
      "${CMAKE_BINARY_DIR}/include/${prefix}/${relative}")

    # install definition
    string(REGEX MATCH "(.*)[/\\]" directory "${relative}")
    install(FILES ${header}
      DESTINATION "include/${prefix}/${directory}"
      COMPONENT "${BOOST_DEVELOP_COMPONENT}"
      CONFIGURATIONS "Release"
      )
  endforeach(header)

  set_boost_project("${BOOST_HAS_DEVELOP_VAR}" ON)
endfunction(boost_add_headers)
