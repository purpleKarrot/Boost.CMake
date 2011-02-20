##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


##
function(boost_install_pdb target)
  if(MSVC)
    get_target_property(location "${target}" LOCATION)
    if(NOT CMAKE_CFG_INTDIR STREQUAL ".")	
      string(REPLACE "${CMAKE_CFG_INTDIR}" "\${CMAKE_INSTALL_CONFIG_NAME}" location "${location}")
    endif()
    get_filename_component(extension "${location}" EXT)
    string(REGEX REPLACE "${extension}$" ".pdb" pdb_file "${location}")
    install(FILES "${pdb_file}" CONFIGURATIONS Debug RelWithDebInfo ${ARGN})
  endif(MSVC)
endfunction(boost_install_pdb)


##
function(boost_parse_target_arguments name)
  cmake_parse_arguments(TARGET
    "SHARED;STATIC;SINGLE_THREADED;MULTI_THREADED;NO_SYMBOL"
    ""
    "PRECOMPILE;SOURCES;LINK_BOOST_LIBRARIES;LINK_LIBRARIES"
    ${ARGN}
    )

  set(TARGET_NAME ${name} PARENT_SCOPE)

  if(NOT TARGET_NO_SYMBOL)
    string(TOUPPER "BOOST_${name}_SOURCE" define_symbol)
  else()
    set(define_symbol)
  endif()
  set(TARGET_DEFINE_SYMBOL ${define_symbol} PARENT_SCOPE)

  if(NOT TARGET_SHARED AND NOT TARGET_STATIC)
    set(TARGET_SHARED ON)
    set(TARGET_STATIC ON)
  endif(NOT TARGET_SHARED AND NOT TARGET_STATIC)
  set(TARGET_SHARED ${TARGET_SHARED} PARENT_SCOPE)
  set(TARGET_STATIC ${TARGET_STATIC} PARENT_SCOPE)

# if(NOT LIB_SINGLE_THREAD AND NOT LIB_MULTI_THREAD)
#   set(LIB_SINGLE_THREAD ON)
#   set(LIB_MULTI_THREAD  ON)
# endif(NOT LIB_SINGLE_THREAD AND NOT LIB_MULTI_THREAD)

  set(sources ${TARGET_SOURCES} ${TARGET_UNPARSED_ARGUMENTS})
  if(TARGET_PRECOMPILE)
    boost_add_pch(${name} sources ${TARGET_PRECOMPILE})
  endif(TARGET_PRECOMPILE)
  set(TARGET_SOURCES ${sources} PARENT_SCOPE)

  set(TARGET_LINK_BOOST_LIBRARIES ${TARGET_LINK_BOOST_LIBRARIES} PARENT_SCOPE)
  set(TARGET_LINK_LIBRARIES ${TARGET_LINK_LIBRARIES} PARENT_SCOPE)
endfunction(boost_parse_target_arguments)
