##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

add_definitions(${Boost_DEFINITIONS})
include_directories(${Boost_INCLUDE_DIRS})
list(APPEND CMAKE_MODULE_PATH ${Boost_MODULE_PATH})

## if xsltproc is not found on Windows, use the one from Boost.CMake
find_package(Xsltproc QUIET)
if(CMAKE_HOST_WIN32 AND NOT XSLTPROC_FOUND)
  set(XSLTPROC_EXECUTABLE "$<TARGET_FILE:${BOOST_NAMESPACE}xsltproc>"
    CACHE INTERNAL "" FORCE)
endif(CMAKE_HOST_WIN32 AND NOT XSLTPROC_FOUND)

## this function is like 'target_link_libraries, except only for boost libs
function(boost_link_libraries target)
  cmake_parse_arguments(LIBS "SHARED;STATIC" "" "" ${ARGN})

  if(LIBS_STATIC)
    set(default_variant "static")
  else(LIBS_STATIC)
    set(default_variant "shared")
  endif(LIBS_STATIC)

  set(compile_definitions)
  set(link_libraries)

  set(arg0)
  foreach(arg1 ${LIBS_UNPARSED_ARGUMENTS})
    set(variant)
    set(library)
    if(arg0 MATCHES "^(shared|static)$")
      set(variant "${arg0}")
      set(library "${arg1}")
    elseif(NOT arg1 MATCHES "^(shared|static)$")
      set(variant "${default_variant}")
      set(library "${arg1}")
    endif()

    if(library)
      if(variant STREQUAL "static")
        list(APPEND link_libraries "${BOOST_NAMESPACE}${library}-static")
      else()
        string(TOUPPER "BOOST_${library}_DYN_LINK" def)
        list(APPEND compile_definitions "${def}=1")
        list(APPEND link_libraries "${BOOST_NAMESPACE}${library}-shared")
      endif()
    endif(library)
    set(arg0 ${arg1})
  endforeach(arg1)

  set_property(TARGET ${target} APPEND PROPERTY
    COMPILE_DEFINITIONS "${compile_definitions}"
    )

  #if(NOT MSVC) #AUTOLINK
    target_link_libraries(${target} ${link_libraries})
  #endif(NOT MSVC)
endfunction(boost_link_libraries)
