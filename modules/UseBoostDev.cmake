##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include("${Boost_USE_FILE}")

include(BoostProject)
include(BoostAddHeaders)
include(BoostAddLibrary)
include(BoostAddExecutable)
include(BoostAddPythonExtension)
include(BoostAddReference)
include(BoostDocumentation)
include(BoostTesting)
include(BoostTestSuite)

#
if(APPLE)
  set(CPACK_PACKAGE_ICON "${Boost_RESOURCE_PATH}/boost.icns")
else(APPLE)
  set(CPACK_PACKAGE_ICON "${Boost_RESOURCE_PATH}\\\\boost.bmp")
endif(APPLE)

set(CPACK_NSIS_MUI_ICON    "${Boost_RESOURCE_PATH}/boost.ico")
set(CPACK_NSIS_MUI_UNIICON "${Boost_RESOURCE_PATH}/boost.ico")

##########################################################################

# make universal binaries on OS X
set(CMAKE_OSX_ARCHITECTURES "i386;x86_64" CACHE STRING "Architectures for OS X")

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


# Append the Boost version number to the versioned name
set(boost_version "${Boost_VERSION_MAJOR}_${Boost_VERSION_MINOR}")
if(Boost_VERSION_PATCH GREATER 0)
  set(boost_version "${boost_version}_${Boost_VERSION_PATCH}")
endif(Boost_VERSION_PATCH GREATER 0)

# The versioned name starts with the full Boost toolset
if(WIN32)
  set(tag_toolset "-${BOOST_TOOLSET}")
  set(tag_version "-${boost_version}")
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
set(CMAKE_DEBUG_POSTFIX   "${tag_toolset}${tag_mt}-${tag_rtdebug}d${tag_version}")
set(CMAKE_RELEASE_POSTFIX "${tag_toolset}${tag_mt}${tag_version}")

# Linking statically to the runtime library
set(CMAKE_DEBUGSTATICRUNTIME_POSTFIX   "${tag_toolset}${tag_mt}-s${tag_rtdebug}d${tag_version}")
set(CMAKE_RELEASESTATICRUNTIME_POSTFIX "${tag_toolset}${tag_mt}-s${tag_version}")
