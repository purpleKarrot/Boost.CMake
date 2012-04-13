##########################################################################
# Copyright (C) 2010-2012 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)

##
function(boost_parse_target_arguments name)
  cmake_parse_arguments(TARGET
    "SHARED;STATIC;SINGLE_THREADED;MULTI_THREADED"
    ""
    "PRECOMPILE;SOURCES;LINK_LIBRARIES"
    ${ARGN}
    )

  set(TARGET_NAME ${name} PARENT_SCOPE)

  if(NOT TARGET_SHARED AND NOT TARGET_STATIC)
    set(TARGET_SHARED ON)
    set(TARGET_STATIC ON)
  endif(NOT TARGET_SHARED AND NOT TARGET_STATIC)
  set(TARGET_SHARED ${TARGET_SHARED} PARENT_SCOPE)
  set(TARGET_STATIC ${TARGET_STATIC} PARENT_SCOPE)

  set(sources ${TARGET_SOURCES} ${TARGET_UNPARSED_ARGUMENTS})
  set(TARGET_SOURCES ${sources} PARENT_SCOPE)

  set(shared_libraries)
  set(static_libraries)
  foreach(library ${TARGET_LINK_LIBRARIES})
    if("${library}" MATCHES "(.+)-(shared|static)$")
      list(APPEND shared_libraries "${CMAKE_MATCH_1}-shared")
      list(APPEND static_libraries "${CMAKE_MATCH_1}-static")
    else()
      list(APPEND shared_libraries "${library}")
      list(APPEND static_libraries "${library}")
    endif()
  endforeach(library)
  set(TARGET_SHARED_LIBRARIES ${shared_libraries} PARENT_SCOPE)
  set(TARGET_STATIC_LIBRARIES ${static_libraries} PARENT_SCOPE)
  set(TARGET_LINK_LIBRARIES ${TARGET_LINK_LIBRARIES} PARENT_SCOPE)
endfunction(boost_parse_target_arguments)
