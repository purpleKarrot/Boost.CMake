##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostForwardFile)
include(CMakeParseArguments)


# this function is deprecated, use INCLUDE_DIRECTORIES in boost_module instead
function(boost_add_headers)
  cmake_parse_arguments(HDR "" "LOCATION" "" ${ARGN})

  set(destination "include/boost")
  if(HDR_LOCATION)
    set(destination "${destination}/${HDR_LOCATION}")
  endif()

  set(fwd_location "${CMAKE_BINARY_DIR}/${destination}")

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
      DESTINATION "${destination}"
      COMPONENT "${BOOST_DEVELOP_COMPONENT}"
      CONFIGURATIONS "Release"
      )
  endforeach(header)
endfunction(boost_add_headers)