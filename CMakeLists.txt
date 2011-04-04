##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/modules")

find_package(Boost REQUIRED COMPONENTS boostbook quickbook NO_MODULE)
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
add_subdirectory(test)

file(WRITE ${BOOST_EXPORT_FILE}
  "include(\${CMAKE_CURRENT_LIST_DIR}/boostbook.cmake)\n"
  "include(\${CMAKE_CURRENT_LIST_DIR}/quickbook.cmake)\n"
  )

if(WIN32)
  set(boost_data_dir  ".")
  set(BOOST_INCLUDE   "\${CMAKE_CURRENT_LIST_DIR}/include")
  set(BOOST_LIBRARIES "\${CMAKE_CURRENT_LIST_DIR}/lib")
else(WIN32)
  set(boost_data_dir  "share/boost")
  set(BOOST_INCLUDE   "\${CMAKE_CURRENT_LIST_DIR}/../../include")
  set(BOOST_LIBRARIES "\${CMAKE_CURRENT_LIST_DIR}/../../lib")
endif(WIN32)

set(config_file "${CMAKE_CURRENT_BINARY_DIR}/boost-config.cmake")
set(version_file "${CMAKE_CURRENT_BINARY_DIR}/boost-config-version.cmake")

configure_file(boost-config.cmake.in "${config_file}" @ONLY)
configure_file(boost-config-version.cmake.in "${version_file}" @ONLY)

install(FILES "${config_file}" "${version_file}"
  DESTINATION "${boost_data_dir}"
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  )

install(DIRECTORY modules resources
  DESTINATION "${boost_data_dir}"
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  )

if(WIN32)
  add_subdirectory(xsltproc)
endif(WIN32)
