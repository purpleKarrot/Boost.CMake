##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

cmake_minimum_required(VERSION 2.8)

include(BoostProject)

boost_project(CMake
  AUTHORS
    "Daniel Pfeifer <daniel -at- pfeifer-mail.de>"
  DESCRIPTION
    "A collection of CMake modules to simplify the development of Boost libraries."
  )

add_subdirectory(doc)

if(WIN32)
  set(cmake_install_dir "CMake")
else(WIN32)
  set(cmake_install_dir "share/Boost/CMake")
endif(WIN32)

set(BOOST_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include")
set(BOOST_LIB_DIR      "${CMAKE_INSTALL_PREFIX}/lib")
set(BOOST_CMAKE_DIR    "${CMAKE_INSTALL_PREFIX}/${cmake_install_dir}")

set(config_file ${PROJECT_BINARY_DIR}/InstallFiles/BoostConfig.cmake)
set(version_file ${PROJECT_BINARY_DIR}/InstallFiles/BoostVersion.cmake)

configure_file(BoostConfig.cmake ${config_file} @ONLY)
configure_file(BoostVersion.cmake ${version_file} @ONLY)

install(FILES ${config_file} ${version_file}
  DESTINATION "${BOOST_CMAKE_DIR}"
  COMPONENT cmake_exe
  )

install(DIRECTORY modules resources
  DESTINATION "${BOOST_CMAKE_DIR}"
  COMPONENT cmake_exe
  )

#
set_boost_project("${BOOST_HAS_EXE_VAR}" ON)

#
if(APPLE)
  set(package_icon "${CMAKE_CURRENT_SOURCE_DIR}/resources/boost.icns")
else(APPLE)
  set(package_icon "${CMAKE_CURRENT_SOURCE_DIR}/resources\\\\boost.bmp")
endif(APPLE)

set(mui_icon "${CMAKE_CURRENT_SOURCE_DIR}/resources/boost.ico")

set(CPACK_PACKAGE_ICON ${package_icon} CACHE INTERNAL "")
set(CPACK_NSIS_MUI_ICON ${mui_icon} CACHE INTERNAL "")
set(CPACK_NSIS_MUI_UNIICON ${mui_icon} CACHE INTERNAL "")
