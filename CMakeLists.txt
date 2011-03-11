##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)

find_package(Boost 1.45 REQUIRED COMPONENTS quickbook boostbook NO_MODULE)
include("${Boost_DEV_FILE}")

boost_project(CMake TOOL
  AUTHORS
    "Daniel Pfeifer <daniel -at- pfeifer-mail.de>"
  DESCRIPTION
    "A collection of CMake modules to simplify the use and development of Boost libraries."
  DEPENDS
    boostbook
    quickbook
  DEB_DEPENDS
    doxygen
    xsltproc
  )

add_subdirectory(doc)

file(WRITE ${BOOST_EXPORT_FILE} "\n"
  "include(\${CMAKE_CURRENT_LIST_DIR}/boostbook.cmake)\n"
  "include(\${CMAKE_CURRENT_LIST_DIR}/quickbook.cmake)\n"
  )

if(WIN32)
  set(BOOST_CMAKE_DIR "CMake")
else(WIN32)
  set(BOOST_CMAKE_DIR "share/boost/CMake")
endif(WIN32)

set(BOOST_INCLUDE   "${CMAKE_INSTALL_PREFIX}/include")
set(BOOST_LIBRARIES "${CMAKE_INSTALL_PREFIX}/lib")
set(BOOST_MODULES   "${CMAKE_INSTALL_PREFIX}/${BOOST_CMAKE_DIR}/modules")
set(BOOST_RESOURCES "${CMAKE_INSTALL_PREFIX}/${BOOST_CMAKE_DIR}/resources")

foreach(config Config ConfigVersion)
  set(source_file "${CMAKE_CURRENT_SOURCE_DIR}/Boost${config}.cmake.in")
  set(binary_file "${CMAKE_CURRENT_BINARY_DIR}/Boost${config}.cmake")
  configure_file("${source_file}" "${binary_file}" @ONLY)
  install(FILES "${binary_file}"
    DESTINATION "${BOOST_CMAKE_DIR}"
    COMPONENT cmake_runtime
    )
endforeach(config)

install(DIRECTORY modules resources
  DESTINATION "${BOOST_CMAKE_DIR}"
  COMPONENT cmake_runtime
  )

#
set_boost_project("${BOOST_HAS_RUNTIME_VAR}" ON)

if(WIN32)
  add_subdirectory(xsltproc)
endif(WIN32)
