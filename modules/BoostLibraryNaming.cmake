##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

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
  message(STATUS "Boost toolset: ${BOOST_TOOLSET}")
endif (NOT BOOST_TOOLSET)

# Set the build name 
# set(BUILDNAME "${BOOST_COMPILER}-${BOOST_COMPILER_VERSION}-${BOOST_PLATFORM}")
# boost_report_pretty("Build name" BUILDNAME)


# Append the Boost version number to the versioned name
set(boost_version "${BOOST_VERSION_MAJOR}_${BOOST_VERSION_MINOR}")
if(BOOST_VERSION_SUBMINOR GREATER 0)
  set(boost_version "${boost_version}_${BOOST_VERSION_SUBMINOR}")
endif(BOOST_VERSION_SUBMINOR GREATER 0)

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
