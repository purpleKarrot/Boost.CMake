################################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>               #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>                #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>              #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

include("${CMAKE_CURRENT_LIST_DIR}/BoostProject.cmake")
boost_get_component_vars()

if(NOT BOOST_CURRENT)
  message(FATAL_ERROR
    "invalid boost_module.cmake in ${CMAKE_CURRENT_SOURCE_DIR}"
    )
  return()
endif()

#
foreach(component debug develop runtime manual)
  string(TOUPPER "${component}" upper)
  set(BOOST_${upper}_COMPONENT "${BOOST_CURRENT}_${component}")
endforeach(component)

set(BOOST_HEADER_ONLY_VAR BOOST_${BOOST_CURRENT}_HEADER_ONLY)
if(BOOST_CURRENT_IS_TOOL)
  set(${BOOST_HEADER_ONLY_VAR} OFF CACHE INTERNAL "" FORCE)
else(BOOST_CURRENT_IS_TOOL)
  set(${BOOST_HEADER_ONLY_VAR} ON CACHE INTERNAL "" FORCE)
endif(BOOST_CURRENT_IS_TOOL)

################################################################################
# Export of CMake components                                                   #
################################################################################

set(BOOST_EXPORTS_FILE "${CMAKE_CURRENT_BINARY_DIR}/exports.txt")
file(WRITE "${BOOST_EXPORTS_FILE}" "")

set(BOOST_TARGETS_FILE "${CMAKE_CURRENT_BINARY_DIR}/targets.txt")
file(WRITE "${BOOST_TARGETS_FILE}" "")

set(install_code "set(BOOST_PROJECT ${BOOST_CURRENT})
    set(BOOST_DEPENDS ${BOOST_CURRENT_DEPENDS})
    set(BOOST_TARGETS \"${BOOST_TARGETS_FILE}\")
    set(BOOST_EXPORTS \"${BOOST_EXPORTS_FILE}\")
    set(BOOST_IS_TOOL ${BOOST_CURRENT_IS_TOOL})
    set(BOOST_BINARY_DIR \"${CMAKE_BINARY_DIR}\")"
  )

# install(CODE) seems to ignore CONFIGURATIONS...
set(debug_match
  "\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Dd][Ee][Bb][Uu][Gg])$\""
  )
set(release_match
  "\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$\""
  )

if(BOOST_CURRENT_IS_TOOL)
  install(CODE "if(${release_match})
    ${install_code}
    include(\"${CMAKE_CURRENT_LIST_DIR}/boost_detail/install_component.cmake\")
    include(\"${CMAKE_CURRENT_LIST_DIR}/boost_detail/install_component_config.cmake\")
  endif(${release_match})"
    COMPONENT "${BOOST_RUNTIME_COMPONENT}"
    )
else(BOOST_CURRENT_IS_TOOL)
  install(CODE "if(${debug_match})
    ${install_code}
    include(\"${CMAKE_CURRENT_LIST_DIR}/boost_detail/install_component_config.cmake\")
  endif(${debug_match})"
    COMPONENT "${BOOST_DEBUG_COMPONENT}"
    )
  install(CODE "if(${release_match})
    ${install_code}
    include(\"${CMAKE_CURRENT_LIST_DIR}/boost_detail/install_component.cmake\")
    include(\"${CMAKE_CURRENT_LIST_DIR}/boost_detail/install_component_config.cmake\")
  endif(${release_match})"
    COMPONENT "${BOOST_DEVELOP_COMPONENT}"
    )
endif(BOOST_CURRENT_IS_TOOL)

################################################################################
# include directories                                                          #
################################################################################

if(BOOST_CURRENT_INCLUDE_DIRECTORIES)
  install(DIRECTORY ${BOOST_CURRENT_INCLUDE_DIRECTORIES}
    DESTINATION include
    COMPONENT "${BOOST_DEVELOP_COMPONENT}"
    CONFIGURATIONS "Release"
    )
  list(APPEND Boost_INCLUDE_DIRS ${BOOST_CURRENT_INCLUDE_DIRECTORIES})
endif(BOOST_CURRENT_INCLUDE_DIRECTORIES)

################################################################################
# include common used Boost.CMake modules                                      #
################################################################################

include("${Boost_USE_FILE}")

include(BoostAddHeaders)
include(BoostAddLibrary)
include(BoostAddExecutable)
include(BoostAddPythonExtension)
include(BoostAddReference)
include(BoostDocumentation)
include(BoostTesting)
include(BoostTestSuite)

################################################################################
# set values and add subdirectories for DOC, TEST, and EXAMPLE                 #
################################################################################

macro(boost_optional_subdirectories option default)
  if(NOT DEFINED BOOST_ENABLED_${option}S)
    set(BOOST_CURRENT_${option}_ENABLED ${default})
  elseif(BOOST_ENABLED_${option}S STREQUAL "NONE")
    set(BOOST_CURRENT_${option}_ENABLED OFF)
  elseif(BOOST_ENABLED_${option}S STREQUAL "ALL")
    set(BOOST_CURRENT_${option}_ENABLED ON)
  else()
    list(FIND BOOST_ENABLED_${option}S ${BOOST_CURRENT} enabled)
    if(enabled GREATER "-1")
      set(BOOST_CURRENT_${option}_ENABLED ON)
    else()
      set(BOOST_CURRENT_${option}_ENABLED OFF)
    endif()
  endif()
  if(BOOST_CURRENT_${option}_ENABLED AND BOOST_CURRENT_${option}_DIRECTORIES)
    foreach(directory ${BOOST_CURRENT_${option}_DIRECTORIES})
      add_subdirectory(${directory})
    endforeach(directory)
  endif()
endmacro(boost_optional_subdirectories)

boost_optional_subdirectories(DOC ON)
boost_optional_subdirectories(TEST ON)
boost_optional_subdirectories(EXAMPLE OFF)

################################################################################
#                                                                              #
################################################################################

# set CMAKE_THREAD_PREFER_PTHREAD if you prefer pthread on windows
find_package(Threads)
# LINK_LIBRARIES ${CMAKE_THREAD_LIBS_INIT}

# Multi-threading support
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  set(MULTI_THREADED_COMPILE_FLAGS "-pthreads")
  set(MULTI_THREADED_LINK_LIBS rt)
elseif(CMAKE_SYSTEM_NAME STREQUAL "BeOS")
  # No threading options necessary for BeOS
elseif(CMAKE_SYSTEM_NAME MATCHES ".*BSD")
  set(MULTI_THREADED_COMPILE_FLAGS "-pthread")
  set(MULTI_THREADED_LINK_FLAGS "-lpthread")
elseif(CMAKE_SYSTEM_NAME STREQUAL "DragonFly")
  # DragonFly is a FreeBSD bariant
  set(MULTI_THREADED_COMPILE_FLAGS "-pthread")
elseif(CMAKE_SYSTEM_NAME STREQUAL "IRIX")
  # TODO: GCC on Irix doesn't support multi-threading?
elseif(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  # TODO: gcc on HP-UX does not support multi-threading?
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  # No threading options necessary for Mac OS X
elseif(UNIX)
  # Assume -pthread and -lrt on all other variants
  set(MULTI_THREADED_COMPILE_FLAGS "-pthread -D_REENTRANT")
  set(MULTI_THREADED_LINK_FLAGS "-lpthread -lrt")
endif()


# Limit CMAKE_CONFIGURATION_TYPES to Debug and Release
set(config_types "Debug;Release")

#if(MSVC)
#  foreach(config C_FLAGS_DEBUG CXX_FLAGS_DEBUG C_FLAGS_RELEASE CXX_FLAGS_RELEASE)
#    string(REPLACE "/MD" "/MT" flags "${CMAKE_${config}}")
#    set(CMAKE_${config}STATICRUNTIME CACHE STRING "${flags}" FORCE) 
#  endforeach(config)
#  list(APPEND config_types DebugStaticRuntime ReleaseStaticRuntime)
#
#  # these need to be set too:
#  # EXE_LINKER_FLAGS_DEBUG EXE_LINKER_FLAGS_RELEASE
#  # SHARED_LINKER_FLAGS_DEBUG SHARED_LINKER_FLAGS_RELEASE
#endif(MSVC)

# The way to identify whether a generator is multi-configuration is to
# check whether CMAKE_CONFIGURATION_TYPES is set.  The VS/XCode generators
# set it (and ignore CMAKE_BUILD_TYPE).  The Makefile generators do not
# set it (and use CMAKE_BUILD_TYPE).  If CMAKE_CONFIGURATION_TYPES is not
# already set, don't set it.                                   --Brad King

# Tweak the configuration and build types appropriately.
if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES "${config_types}" CACHE STRING
    "Semicolon-separate list of supported configuration types" FORCE)
else(CMAKE_CONFIGURATION_TYPES)
  # Build in release mode by default
  if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build (${config_types})" FORCE)
  endif (NOT CMAKE_BUILD_TYPE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${config_types})
endif(CMAKE_CONFIGURATION_TYPES)


# http://www.boost.org/doc/libs/release/more/getting_started/windows.html#library-naming

# TODO: make this an option
set(BUILD_MULTI_THREADED ON)

# Toolset detection.
if (NOT BOOST_TOOLSET)
  if (MSVC60)
    set(BOOST_TOOLSET "vc6")
  elseif(MSVC70)
    set(BOOST_TOOLSET "vc7")
  elseif(MSVC71)
    set(BOOST_TOOLSET "vc71")
  elseif(MSVC80)
    set(BOOST_TOOLSET "vc80")
  elseif(MSVC90)
    set(BOOST_TOOLSET "vc90")
  elseif(MSVC10)
    set(BOOST_TOOLSET "vc100")
  elseif(MSVC)
    set(BOOST_TOOLSET "vc")
  elseif(BORLAND)
    set(BOOST_TOOLSET "bcb")
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
    # Execute GCC with the -dumpversion option, to give us a version string
    execute_process(
      COMMAND ${CMAKE_CXX_COMPILER} "-dumpversion" 
      OUTPUT_VARIABLE GCC_VERSION_STRING)
    
    # Match only the major and minor versions of the version string
    string(REGEX MATCH "[0-9]+.[0-9]+" GCC_MAJOR_MINOR_VERSION_STRING
      "${GCC_VERSION_STRING}")

    # Strip out the period between the major and minor versions
    string(REGEX REPLACE "\\." "" BOOST_VERSIONING_GCC_VERSION
      "${GCC_MAJOR_MINOR_VERSION_STRING}")
    
    # Set the GCC versioning toolset
    set(BOOST_TOOLSET "gcc${BOOST_VERSIONING_GCC_VERSION}")
  elseif(CMAKE_CXX_COMPILER MATCHES "/icpc$" 
      OR CMAKE_CXX_COMPILER MATCHES "/icpc.exe$" 
      OR CMAKE_CXX_COMPILER MATCHES "/icl.exe$")
    set(BOOST_TOOLSET "intel")
  else()
    set(BOOST_TOOLSET "unknown")
  endif()
  
  # create cache entry
  set(BOOST_TOOLSET ${BOOST_TOOLSET} CACHE STRING "Boost toolset")
endif (NOT BOOST_TOOLSET)

# The versioned name starts with the full Boost toolset
if(WIN32)
  set(tag_toolset "-${BOOST_TOOLSET}")
  string(REPLACE "." "_" tag_version "-${Boost_VERSION}")
else(WIN32)
  set(tag_toolset "")
  set(tag_version "")
endif(WIN32)

# Add -mt for multi-threaded libraries
if(BUILD_MULTI_THREADED)
  set(tag_mt "-mt")
else(BUILD_MULTI_THREADED)
  set(tag_mt "")
endif(BUILD_MULTI_THREADED)

# Using the debug version of the runtime library.
# With Visual C++, this comes automatically with debug
if(MSVC)
  set(tag_rtdebug "g")
else(MSVC)
  set(tag_rtdebug "")
endif(MSVC)

# TODO: python debug
set(tag_pydebug "y")

# CMAKE_<CONFIG>_POSTFIX
set(BOOST_DEBUG_POSTFIX   "${tag_toolset}${tag_mt}-${tag_rtdebug}d${tag_version}")
set(BOOST_RELEASE_POSTFIX "${tag_toolset}${tag_mt}${tag_version}")

# Linking statically to the runtime library
set(BOOST_DEBUGSTATICRUNTIME_POSTFIX   "${tag_toolset}${tag_mt}-s${tag_rtdebug}d${tag_version}")
set(BOOST_RELEASESTATICRUNTIME_POSTFIX "${tag_toolset}${tag_mt}-s${tag_version}")
