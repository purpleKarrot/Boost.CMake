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

# wrapper to set CPACK_COMPONENT_* globally
function(set_cpack_component name value)
  string(TOUPPER "CPACK_COMPONENT_${name}" variable)
  set(${variable} ${value} CACHE INTERNAL "" FORCE)
endfunction(set_cpack_component)

# wrapper to get a CPACK_COMPONENT_* value
function(get_cpack_component destvar name)
  string(TOUPPER "CPACK_COMPONENT_${name}" variable)
  set(${destvar} ${${variable}} PARENT_SCOPE)
endfunction(get_cpack_component)

function(boost_add_cpack_component name)
  set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL}
    "${BOOST_PROJECT_NAME}_${name}"
    CACHE INTERNAL "" FORCE
    )
endfunction(boost_add_cpack_component)

##########################################################################

# use this function as a replacement for 'project' in boost projects.
function(boost_project name)
  cmake_parse_arguments(PROJ "" "" "AUTHORS;DESCRIPTION;DEPENDS" ${ARGN})
  
  set(BOOST_PROJECT_DISPLAY_NAME "${name}" PARENT_SCOPE)

  string(REPLACE " " "_" project_name "${name}")
  string(TOLOWER "${project_name}" project_name)
  set(BOOST_PROJECT_NAME "${project_name}" PARENT_SCOPE)
  project(${project_name})

  string(REPLACE ";" " " description "${PROJ_DESCRIPTION}")

  set_cpack_component(GROUP_${project_name}_GROUP_DISPLAY_NAME "${name}")
  set_cpack_component(GROUP_${project_name}_GROUP_DESCRIPTION "${description}")

  set_cpack_component(${project_name}_DEV_GROUP "${project_name}_group")
  set_cpack_component(${project_name}_LIB_GROUP "${project_name}_group")
  set_cpack_component(${project_name}_EXE_GROUP "${project_name}_group")

  set(lib_depends)
  set(dev_depends) # "${project_name}_lib")
  foreach(dep ${PROJ_DEPENDS})
#   list(APPEND lib_depends "${project_name}_lib")
#   list(APPEND dev_depends "${project_name}_dev")
  endforeach(dep)

  set_cpack_component(${project_name}_LIB_DEPENDS "${lib_depends}")
  set_cpack_component(${project_name}_DEV_DEPENDS "${dev_depends}")

  set_cpack_component(${project_name}_LIB_DISPLAY_NAME "${name}: Shared Libraries")
  set_cpack_component(${project_name}_DEV_DISPLAY_NAME "${name}: Static and import Libraries")
  set_cpack_component(${project_name}_EXE_DISPLAY_NAME "${name}: Tools")

  set_cpack_component(${project_name}_LIB_DESCRIPTION "${description}")
  set_cpack_component(${project_name}_DEV_DESCRIPTION "${description}")
  set_cpack_component(${project_name}_EXE_DESCRIPTION "${description}")

  # Debian  
  string(REPLACE "_" "-" debian_name "${project_name}")
  set_cpack_component(${project_name}_LIB_DEB_PACKAGE "libboost-${debian_name}")
  set_cpack_component(${project_name}_DEV_DEB_PACKAGE "libboost-${debian_name}-dev")
  set_cpack_component(${project_name}_EXE_DEB_PACKAGE "boost-${debian_name}")
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
      COMPONENT ${BOOST_PROJECT_NAME}_dev
      )
  endforeach(header)

  boost_add_cpack_component(dev)
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
function(boost_add_library name)
  cmake_parse_arguments(LIB
    "SHARED;STATIC" #;SINGLE_THREAD;MULTI_THREAD"
    "PCH"
    "SOURCES;LINK_BOOST_LIBRARIES;LINK_LIBRARIES"
    ${ARGN}
    )

  string(TOUPPER ${name} upper_name)

  if(NOT LIB_SOURCES)
    set(LIB_SOURCES ${LIB_UNPARSED_ARGUMENTS})
  endif(NOT LIB_SOURCES)

  if(NOT LIB_SHARED AND NOT LIB_STATIC)
    set(LIB_SHARED ON)
    set(LIB_STATIC ON)
  endif(NOT LIB_SHARED AND NOT LIB_STATIC)

# if(NOT LIB_SINGLE_THREAD AND NOT LIB_MULTI_THREAD)
#   set(LIB_SINGLE_THREAD ON)
#   set(LIB_MULTI_THREAD  ON)
# endif(NOT LIB_SINGLE_THREAD AND NOT LIB_MULTI_THREAD)

  if(LIB_PCH)
    # TODO: support precompiled headers
  endif(LIB_PCH)

  set(targets)

  if(LIB_SHARED)
    set(target ${name}-shared)
    add_library(${target} SHARED ${LIB_SOURCES})
    boost_link_libraries(${target} ${LIB_LINK_BOOST_LIBRARIES} SHARED)
    target_link_libraries(${target} ${LIB_LINK_LIBRARIES})
	set_property(TARGET ${target}
	  APPEND PROPERTY COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1")
	set_target_properties(${target} PROPERTIES
      PROJECT_LABEL "${name} (shared library)"
      )
    list(APPEND targets ${target})
  endif(LIB_SHARED)

  if(LIB_STATIC)
    set(target ${name}-static)
    add_library(${name}-static STATIC ${LIB_SOURCES})
    boost_link_libraries(${target} ${LIB_LINK_BOOST_LIBRARIES} STATIC)
    target_link_libraries(${target} ${LIB_LINK_LIBRARIES})
	set_target_properties(${target} PROPERTIES
      PROJECT_LABEL "${name} (static library)"
      PREFIX "lib"
      )
    list(APPEND targets ${target})
  endif(LIB_STATIC)

  set_target_properties(${targets} PROPERTIES
    DEFINE_SYMBOL "BOOST_${upper_name}_SOURCE"
    OUTPUT_NAME "boost_${name}"
    FOLDER "${BOOST_PROJECT_DISPLAY_NAME}"
    )

  install(TARGETS ${targets}
    ARCHIVE DESTINATION lib COMPONENT ${BOOST_PROJECT_NAME}_dev
    LIBRARY DESTINATION lib COMPONENT ${BOOST_PROJECT_NAME}_lib
    RUNTIME DESTINATION bin COMPONENT ${BOOST_PROJECT_NAME}_lib
    )

  boost_add_cpack_component(dev)
  if(LIB_SHARED)
    boost_add_cpack_component(lib)
  endif(LIB_SHARED)
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
function(boost_add_executable name)
  cmake_parse_arguments(EXE "" ""
    "SOURCES;LINK_BOOST_LIBRARIES;LINK_LIBRARIES" ${ARGN})

  set(rc_file ${Boost_SOURCE_DIR}/src/exe.rc)

  add_executable(${name} ${EXE_SOURCES} ${rc_file})
  boost_link_libraries(${name} ${EXE_LINK_BOOST_LIBRARIES})
  target_link_libraries(${name} ${EXE_LINK_LIBRARIES})
  set_property(TARGET ${name} PROPERTY FOLDER "${BOOST_PROJECT_DISPLAY_NAME}")
  set_property(TARGET ${name} PROPERTY PROJECT_LABEL "${name} (executable)")

  install(TARGETS ${name}
    RUNTIME DESTINATION bin COMPONENT ${BOOST_PROJECT_NAME}_exe
    )
  boost_add_cpack_component(exe)
endfunction(boost_add_executable)


#
#  Macro for building boost.python extensions
#
macro(boost_python_extension MODULE_NAME)
  parse_arguments(BPL_EXT  "" "" ${ARGN})

  if (WIN32)
    set(extlibtype SHARED)
  else()
    set(extlibtype MODULE)
  endif()

  boost_add_single_library(${MODULE_NAME}
    ${BPL_EXT_DEFAULT_ARGS}
    ${extlibtype}
    LINK_LIBS ${PYTHON_LIBRARIES}
    DEPENDS boost_python
    SHARED
    MULTI_THREADED
    )

  if(WIN32)
    set_target_properties(${VARIANT_LIBNAME} PROPERTIES
      OUTPUT_NAME "${MODULE_NAME}"
      PREFIX ""
      SUFFIX .pyd
      IMPORT_SUFFIX .pyd
      )
  else()
    set_target_properties(${VARIANT_LIBNAME} PROPERTIES
      OUTPUT_NAME "${MODULE_NAME}"
      PREFIX ""
      )
  endif()
endmacro(boost_python_extension)

function(boost_add_python_extension)
endfunction(boost_add_python_extension)
