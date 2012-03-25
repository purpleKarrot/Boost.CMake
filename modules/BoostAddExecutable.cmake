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
include("${CMAKE_CURRENT_LIST_DIR}/boost_detail/precompile_header.cmake")

# Creates a new executable from source files.
#
#   boost_add_executable(<name> [SHARED|STATIC]
#     <list of source files>
#     )
#
#   boost_add_executable(<name> [SHARED|STATIC]
#     [PRECOMPILE <list of headers to precompile>]
#     [SOURCES <list of source files>]
#     [LINK_LIBRARIES <list of libraries to link>]
#     )
#
# where exename is the name of the executable (e.g., "wave").  source1,
# source2, etc. are the source files used to build the executable, e.g.,
# cpp.cpp. If no source files are provided, "exename.cpp" will be
# used.
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
# LINK_LIBS: Provides additional libraries against which the
# executable will be linked. For example, one might provide "expat"
# as options to LINK_LIBS, to state that the executable will link
# against the expat library binary. Use LINK_LIBS for libraries
# external to Boost; for Boost libraries, use DEPENDS.
#
# DEPENDS: States that this executable depends on and links against
# a Boostlibrary. The arguments to DEPENDS should be the unversioned
# name of the Boost library, such as "boost_filesystem". Like
# LINK_LIBS, this option states that the executable will link
# against the stated libraries. Unlike LINK_LIBS, however, DEPENDS
# takes particular library variants into account, always linking to
# the appropriate variant of a Boost library. For example, if the
# MULTI_THREADED feature was requested in the call to
# boost_add_executable, DEPENDS will ensure that we only link
# against multi-threaded libraries.
#
# Example:
#   boost_add_executable(wave cpp.cpp 
#     DEPENDS boost_wave boost_program_options boost_filesystem 
#             boost_serialization
#     )
function(boost_add_executable)
  boost_parse_target_arguments(${ARGN})
  add_executable(${TARGET_NAME}
    ${TARGET_SOURCES}
    #${Boost_RESOURCE_PATH}/exe.rc
    )
  target_link_libraries(${TARGET_NAME}
    ${TARGET_LINK_LIBRARIES}
    )
  set_target_properties(${TARGET_NAME} PROPERTIES
    FOLDER "${PROJECT_NAME}"
    PROJECT_LABEL "${TARGET_NAME} (executable)"
    )
  boost_add_pch_to_target(${TARGET_NAME} ${TARGET_PCH})
endfunction(boost_add_executable)
