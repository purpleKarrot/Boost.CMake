##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)

##########################################################################

# function to set global project variables
function(set_boost_project name value)
  set(BOOST_PROJECT_${name} "${value}" CACHE INTERNAL "" FORCE)
endfunction(set_boost_project)

##########################################################################

# use this function as a replacement for 'project' in boost projects.
function(boost_project name)
  set(parameters "AUTHORS;DESCRIPTION;DEPENDS")
  cmake_parse_arguments(PROJ "" "" "${parameters}" ${ARGN})

  string(REPLACE " " "_" project "${name}")
  string(TOLOWER "${project}" project)
  set(BOOST_CURRENT_PROJECT "${project}" PARENT_SCOPE)
  project("${project}")
  
  list(APPEND BOOST_PROJECTS_ALL ${project})
  set(BOOST_PROJECTS_ALL ${BOOST_PROJECTS_ALL} CACHE INTERNAL "" FORCE)

  # join description to a single string
  string(REPLACE ";" " " PROJ_DESCRIPTION "${PROJ_DESCRIPTION}")

  # set global variables
  set_boost_project("${project}_NAME" "${name}")
  foreach(param ${parameters})
    set_boost_project("${project}_${param}" "${PROJ_${param}}")
  endforeach(param)

  #
  foreach(component dev doc exe lib)
    string(TOUPPER "${component}" upper)
    set(BOOST_${upper}_COMPONENT "${project}_${component}" PARENT_SCOPE)
    set(has_var "${project}_HAS_${upper}")
    set_boost_project(${has_var} OFF)
    set(BOOST_HAS_${upper}_VAR "${has_var}" PARENT_SCOPE)
  endforeach(component)

  # this will be obsolete once CMake supports the FOLDER property on directories
  set(BOOST_CURRENT_FOLDER "${name}" PARENT_SCOPE)
endfunction(boost_project)


# I might change the interface of this function (don't like the prefix param)...
function(boost_add_headers prefix)
  set(fwd_prefix "${BOOST_INCLUDE_DIR}/${prefix}")

  foreach(header ${ARGN})
    # create forwarding header
    get_filename_component(absolute ${header} ABSOLUTE)
    file(RELATIVE_PATH relative ${CMAKE_CURRENT_SOURCE_DIR} ${absolute})
    set(fwdfile "${fwd_prefix}/${relative}")
    if(NOT EXISTS "${fwdfile}")
      get_filename_component(path ${relative} PATH)
      get_filename_component(fwd_absolute "${fwd_prefix}/${path}" ABSOLUTE)
      file(RELATIVE_PATH include "${fwd_absolute}" "${absolute}")
      file(WRITE ${fwdfile} "#include \"${include}\"\n")
    endif(NOT EXISTS "${fwdfile}")

    # install definition
    string(REGEX MATCH "(.*)[/\\]" directory ${relative})
    install(FILES ${header}
      DESTINATION include/${prefix}/${directory}
      COMPONENT "${BOOST_DEV_COMPONENT}"
      )
  endforeach(header)

  set_boost_project("${BOOST_HAS_DEV_VAR}" ON)
endfunction(boost_add_headers)


# this function is like 'target_link_libraries, except only for boost libs
function(boost_link_libraries target)
  cmake_parse_arguments(LIBS "SHARED;STATIC" "" "" ${ARGN})
  set(link_libs)

  foreach(lib ${LIBS_UNPARSED_ARGUMENTS})
    if(LIBS_STATIC)
      list(APPEND link_libs "${lib}-static")
    else()
      list(APPEND link_libs "${lib}-shared")
    endif()
  endforeach(lib)

  target_link_libraries(${target} ${link_libs})
endfunction(boost_link_libraries)


function(boost_add_pch name source_list)
  if(NOT MSVC)
    return()
  endif(NOT MSVC)

  set(pch_header "${CMAKE_CURRENT_BINARY_DIR}/${name}_pch.hpp")
  set(pch_source "${CMAKE_CURRENT_BINARY_DIR}/${name}_pch.cpp")
  set(pch_binary "${CMAKE_CURRENT_BINARY_DIR}/${name}.pch")

  if(MSVC_IDE)
    set(pch_binary "$(IntDir)/${name}.pch")
  endif(MSVC_IDE)

  file(WRITE ${pch_header}.in "/* ${name} precompiled header file */\n\n")
  foreach(header ${ARGN})
    if(header MATCHES "^<.*>$")
      file(APPEND ${pch_header}.in "#include ${header}\n")
    else()
      get_filename_component(header ${header} ABSOLUTE)
      file(APPEND ${pch_header}.in "#include \"${header}\"\n")
    endif()
  endforeach(header)
  configure_file(${pch_header}.in ${pch_header} COPYONLY)

  file(WRITE ${pch_source}.in "#include \"${pch_header}\"\n")
  configure_file(${pch_source}.in ${pch_source} COPYONLY)

  set_source_files_properties(${pch_source} PROPERTIES
    COMPILE_FLAGS "/Yc\"${pch_header}\" /Fp\"${pch_binary}\""
    OBJECT_OUTPUTS "${pch_binary}"
    )

  set_source_files_properties(${${source_list}} PROPERTIES
    COMPILE_FLAGS "/Yu\"${pch_header}\" /FI\"${pch_header}\" /Fp\"${pch_binary}\""
    OBJECT_DEPENDS "${pch_binary}"
    )

  set(${source_list} ${pch_source} ${${source_list}} PARENT_SCOPE)
endfunction(boost_add_pch)


function(boost_parse_target_arguments name)
  cmake_parse_arguments(TARGET
    "SHARED;STATIC;SINGLE_THREADED;MULTI_THREADED"
    ""
    "PRECOMPILE;SOURCES;LINK_BOOST_LIBRARIES;LINK_LIBRARIES"
    ${ARGN}
    )

  set(TARGET_NAME ${name} PARENT_SCOPE)

  string(TOUPPER "BOOST_${name}_SOURCE" define_symbol)
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


function(boost_install_libraries shared static)
  install(TARGETS ${ARGN}
    ARCHIVE
      DESTINATION lib
      COMPONENT "${BOOST_DEV_COMPONENT}"
    LIBRARY
      DESTINATION lib
      COMPONENT "${BOOST_LIB_COMPONENT}"
    RUNTIME
      DESTINATION bin
      COMPONENT "${BOOST_LIB_COMPONENT}"
    )

  set_boost_project("${BOOST_HAS_DEV_VAR}" ON)
  if(shared)
    set_boost_project("${BOOST_HAS_LIB_VAR}" ON)
  endif(shared)
endfunction(boost_install_libraries)


# Creates a Boost library target that generates a compiled library
# (.a, .lib, .dll, .so, etc) from source files.
#
#   boost_add_library(name [SHARED|STATIC]
#     SOURCES
#       source1
#       source2
#       ...
#     LINK_BOOST_LIBRARIES
#       system
#     LINK_LIBRARIES
#       ...
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
#   LINK_LIBS: Provides additional libraries against which each of the
#   library variants will be linked. For example, one might provide
#   "expat" as options to LINK_LIBS, to state that each of the library
#   variants will link against the expat library binary. Use LINK_LIBS
#   for libraries external to Boost; for Boost libraries, use DEPENDS.
#
#   DEPENDS: States that this Boost library depends on and links
#   against another Boost library. The arguments to DEPENDS should be
#   the unversioned name of the Boost library, such as
#   "boost_filesystem". Like LINK_LIBS, this option states that all
#   variants of the library being built will link against the stated
#   libraries. Unlike LINK_LIBS, however, DEPENDS takes particular
#   library variants into account, always linking the variant of one
#   Boost library against the same variant of the other Boost
#   library. For example, if the boost_mpi_python library DEPENDS on
#   boost_python, multi-threaded variants of boost_mpi_python will
#   link against multi-threaded variants of boost_python.
#
function(boost_add_library)
  boost_parse_target_arguments(${ARGN})

  set(targets)

  if(TARGET_SHARED)
    set(target ${TARGET_NAME}-shared)
    add_library(${target} SHARED ${TARGET_SOURCES})
    boost_link_libraries(${target} ${TARGET_LINK_BOOST_LIBRARIES} SHARED)
    target_link_libraries(${target} ${TARGET_LINK_LIBRARIES})
	set_property(TARGET ${target} APPEND PROPERTY
	  COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1;BOOST_ALL_NO_LIB=1")
	set_target_properties(${target} PROPERTIES
      PROJECT_LABEL "${TARGET_NAME} (shared library)"
      )
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
    list(APPEND targets ${target})
  endif(TARGET_STATIC)

  set_target_properties(${targets} PROPERTIES
    DEFINE_SYMBOL "${TARGET_DEFINE_SYMBOL}"
    OUTPUT_NAME "boost_${TARGET_NAME}"
    FOLDER "${BOOST_CURRENT_FOLDER}"
    VERSION "${BOOST_VERSION}"
    )

  boost_install_libraries(TARGET_SHARED TARGET_STATIC ${targets})
endfunction(boost_add_library)


# Creates a new executable from source files.
#
#   boost_add_executable(exename
#                        source1 source2 ...
#                        [LINK_LIBS linklibs]
#                        [DEPENDS libdepend1 libdepend2 ...]
#                       )
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
#   LINK_LIBS: Provides additional libraries against which the
#   executable will be linked. For example, one might provide "expat"
#   as options to LINK_LIBS, to state that the executable will link
#   against the expat library binary. Use LINK_LIBS for libraries
#   external to Boost; for Boost libraries, use DEPENDS.
#
#   DEPENDS: States that this executable depends on and links against
#   a Boostlibrary. The arguments to DEPENDS should be the unversioned
#   name of the Boost library, such as "boost_filesystem". Like
#   LINK_LIBS, this option states that the executable will link
#   against the stated libraries. Unlike LINK_LIBS, however, DEPENDS
#   takes particular library variants into account, always linking to
#   the appropriate variant of a Boost library. For example, if the
#   MULTI_THREADED feature was requested in the call to
#   boost_add_executable, DEPENDS will ensure that we only link
#   against multi-threaded libraries.
#
# Example:
#   boost_add_executable(wave cpp.cpp 
#     DEPENDS boost_wave boost_program_options boost_filesystem 
#             boost_serialization
#     )
function(boost_add_executable)
  boost_parse_target_arguments(${ARGN})

  set(rc_file ${Boost_SOURCE_DIR}/src/exe.rc)

  add_executable(${TARGET_NAME} ${TARGET_SOURCES} ${rc_file})
  boost_link_libraries(${TARGET_NAME} ${TARGET_LINK_BOOST_LIBRARIES})
  target_link_libraries(${TARGET_NAME} ${TARGET_LINK_LIBRARIES})

  set_target_properties(${TARGET_NAME} PROPERTIES
    FOLDER "${BOOST_CURRENT_FOLDER}"
    PROJECT_LABEL "${TARGET_NAME} (executable)"
    )

  set_property(TARGET ${TARGET_NAME} APPEND PROPERTY
#   COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1;BOOST_ALL_NO_LIB=1")
    COMPILE_DEFINITIONS "BOOST_ALL_NO_LIB=1")

  install(TARGETS ${TARGET_NAME}
    DESTINATION bin
    COMPONENT ${BOOST_CURRENT_PROJECT}_exe
    )
  set_boost_project("${BOOST_HAS_EXE_VAR}" ON)
endfunction(boost_add_executable)


function(boost_add_python_extension)
  boost_parse_target_arguments(${ARGN})

  set(target ${TARGET_NAME}_py)
  add_library(${target} SHARED ${TARGET_SOURCES})
  boost_link_libraries(${target} python ${TARGET_LINK_BOOST_LIBRARIES} SHARED)
  target_link_libraries(${target} ${TARGET_LINK_LIBRARIES})

  set_property(TARGET ${target} APPEND PROPERTY
    COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1;BOOST_ALL_NO_LIB=1")

  set_target_properties(${target} PROPERTIES
    DEFINE_SYMBOL "${TARGET_DEFINE_SYMBOL}"
    OUTPUT_NAME "${TARGET_NAME}"
    PREFIX ""
    FOLDER "${BOOST_CURRENT_FOLDER}"
    PROJECT_LABEL "${TARGET_NAME} (python extension)"
#   VERSION "${BOOST_VERSION}"
    )

  if(WIN32)
    set_target_properties(${target} PROPERTIES
      SUFFIX .pyd
      IMPORT_SUFFIX .pyd
      )
  endif()

  boost_install_libraries(ON OFF ${target})
endfunction(boost_add_python_extension)
