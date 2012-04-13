##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2012 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include("${CMAKE_CURRENT_LIST_DIR}/boost_detail/parse_target_arguments.cmake")

# Creates a Boost library target that generates a compiled library
# (.a, .lib, .dll, .so, etc) from source files.
#
#   boost_add_library(<name> [SHARED|STATIC]
#     <list of source files>
#     )
#
#   boost_add_library(<name> [SHARED|STATIC]
#     [PRECOMPILE  <list of headers to precompile>]
#     [SOURCES <list of source files>]
#     [LINK_LIBRARIES <list of libraries to link>]
#     )
#
# where "name" is the name of library (e.g. "regex", not "boost_regex")
# and source1, source2, etc. are the source files used
# to build the library, e.g., cregex.cpp.
#
# This macro has a variety of options that affect its behavior. In
# several cases, we use the placeholder "feature" in the option name
# to indicate that there are actually several different kinds of
# options, each referring to a different build feature, e.g., shared
# libraries, multi-threaded, debug build, etc. For a complete listing
# of these features, please refer to the CMakeLists.txt file in the
# root of the Boost distribution, which defines the set of features
# that will be used to build Boost libraries by default.
#
# The options that affect this macro's behavior are:
#
# LINK_LIBS: Provides additional libraries against which each of the
# library variants will be linked. For example, one might provide
# "expat" as options to LINK_LIBS, to state that each of the library
# variants will link against the expat library binary. Use LINK_LIBS
# for libraries external to Boost; for Boost libraries, use DEPENDS.
#
# DEPENDS: States that this Boost library depends on and links
# against another Boost library. The arguments to DEPENDS should be
# the unversioned name of the Boost library, such as
# "boost_filesystem". Like LINK_LIBS, this option states that all
# variants of the library being built will link against the stated
# libraries. Unlike LINK_LIBS, however, DEPENDS takes particular
# library variants into account, always linking the variant of one
# Boost library against the same variant of the other Boost
# library. For example, if the boost_mpi_python library DEPENDS on
# boost_python, multi-threaded variants of boost_mpi_python will
# link against multi-threaded variants of boost_python.
#
function(boost_add_library)
  message(STATUS "library ${ARGV0}")
  boost_parse_target_arguments(${ARGN})

  set(targets)

  if(TARGET_SHARED)
    set(target ${TARGET_NAME}-shared)
    add_library(${target} SHARED
      ${TARGET_SOURCES}
      )
    target_link_libraries(${target}
      ${TARGET_SHARED_LIBRARIES}
      )
    set_property(TARGET ${target} APPEND PROPERTY
      COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1;BOOST_ALL_NO_LIB=1"
      )
    list(APPEND targets ${target})
  endif(TARGET_SHARED)

  if(TARGET_STATIC)
    set(target ${TARGET_NAME}-static)
    add_library(${target} STATIC
      ${TARGET_SOURCES}
      )
    target_link_libraries(${target}
      ${TARGET_STATIC_LIBRARIES}
      )
    set_target_properties(${target} PROPERTIES
      PROJECT_LABEL "${TARGET_NAME} (static library)"
      PREFIX "lib"
      )
    list(APPEND targets ${target})
  endif(TARGET_STATIC)

  set_target_properties(${targets} PROPERTIES
    OUTPUT_NAME "boost_${TARGET_NAME}"
#   FOLDER "${PROJECT_NAME}"
#   VERSION "${Boost_VERSION}"
#   DEBUG_POSTFIX "${BOOST_DEBUG_POSTFIX}"
#   RELEASE_POSTFIX "${BOOST_RELEASE_POSTFIX}"
    )
endfunction(boost_add_library)
