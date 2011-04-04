##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include_directories("${Boost_INCLUDE_DIRS}")

## this function is like 'target_link_libraries, except only for boost libs
function(boost_link_libraries target)
  cmake_parse_arguments(LIBS "SHARED;STATIC" "" "" ${ARGN})
  set(compile_definitions)
  set(link_libraries)

  foreach(lib ${LIBS_UNPARSED_ARGUMENTS})
    if(LIBS_STATIC)
      list(APPEND link_libraries "${BOOST_NAMESPACE}${lib}-static")
    else()
      string(TOUPPER "BOOST_${lib}_DYN_LINK" def)
      list(APPEND compile_definitions "${def}=1")
      list(APPEND link_libraries "${BOOST_NAMESPACE}${lib}-shared")
    endif()
  endforeach(lib)

  set_property(TARGET ${target} APPEND PROPERTY
    COMPILE_DEFINITIONS "${compile_definitions}"
    )

  #if(NOT MSVC) #AUTOLINK
    target_link_libraries(${target} ${link_libraries})
  #endif(NOT MSVC)
endfunction(boost_link_libraries)
