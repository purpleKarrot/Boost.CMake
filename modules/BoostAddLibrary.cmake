##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostParseTargetArguments)
include(BoostPrecompileHeader)
include(BoostExport)

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
#     [LINK_BOOST_LIBRARIES <list of boost libraries to link>]
#     [LINK_LIBRARIES <list of third party libraries to link>]
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
  boost_parse_target_arguments(${ARGN})

  set(targets)

  if(TARGET_SHARED)
    set(target ${TARGET_NAME}-shared)
    add_library(${target} SHARED ${TARGET_SOURCES})
    boost_link_libraries(${target} ${TARGET_LINK_BOOST_LIBRARIES} SHARED)
    target_link_libraries(${target} ${TARGET_LINK_LIBRARIES})
#   string(TOUPPER "BOOST_${TARGET_NAME}_DYN_LINK=1" shared_definition)
    set_property(TARGET ${target} APPEND PROPERTY
#     COMPILE_DEFINITIONS "${shared_definition};BOOST_ALL_NO_LIB=1"
      COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1;BOOST_ALL_NO_LIB=1"
      )
    set_target_properties(${target} PROPERTIES
      PROJECT_LABEL "${TARGET_NAME} (shared library)"
      )
    boost_add_pch_to_target(${target} ${TARGET_PCH})
    boost_export(${target} ${TARGET_LINK_BOOST_LIBRARIES})      
    list(APPEND targets ${target})
  endif(TARGET_SHARED)

  if(TARGET_STATIC)
    set(target ${TARGET_NAME}-static)
    add_library(${target} STATIC ${TARGET_SOURCES})
    boost_link_libraries(${target} ${TARGET_LINK_BOOST_LIBRARIES} STATIC)
    target_link_libraries(${target} ${TARGET_LINK_LIBRARIES})
    set_target_properties(${target} PROPERTIES
      PROJECT_LABEL "${TARGET_NAME} (static library)"
      PREFIX "lib"
      )
    boost_add_pch_to_target(${target} ${TARGET_PCH})
    boost_export(${target} ${TARGET_LINK_BOOST_LIBRARIES})      
    list(APPEND targets ${target})
  endif(TARGET_STATIC)

  set_target_properties(${targets} PROPERTIES
    DEFINE_SYMBOL "${TARGET_DEFINE_SYMBOL}"
    OUTPUT_NAME "boost_${TARGET_NAME}"
    FOLDER "${BOOST_CURRENT_FOLDER}"
    VERSION "${Boost_VERSION}"
    )

  boost_install_libraries(${targets})
endfunction(boost_add_library)


##
function(boost_install_libraries)
  install(TARGETS ${ARGN}
    ARCHIVE
      DESTINATION lib
      COMPONENT "${BOOST_DEVELOP_COMPONENT}"
      CONFIGURATIONS "Release"
    LIBRARY
      DESTINATION lib
      COMPONENT "${BOOST_RUNTIME_COMPONENT}"
      CONFIGURATIONS "Release"
    RUNTIME
      DESTINATION bin
      COMPONENT "${BOOST_RUNTIME_COMPONENT}"
      CONFIGURATIONS "Release"
    )
  install(TARGETS ${ARGN}
    ARCHIVE
      DESTINATION lib
      COMPONENT "${BOOST_DEBUG_COMPONENT}"
      CONFIGURATIONS "Debug"
    LIBRARY
      DESTINATION lib
      COMPONENT "${BOOST_DEBUG_COMPONENT}"
      CONFIGURATIONS "Debug"
    RUNTIME
      DESTINATION bin
      COMPONENT "${BOOST_DEBUG_COMPONENT}"
      CONFIGURATIONS "Debug"
    )
  set_boost_project("${BOOST_HEADER_ONLY}" OFF)
endfunction(boost_install_libraries)
