##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

cmake_minimum_required(VERSION 2.8)

find_package(Boost 1.45 REQUIRED COMPONENTS quickbook NO_MODULE)
include("${Boost_DEV_FILE}")

boost_project(CMake
  AUTHORS
    "Daniel Pfeifer <daniel -at- pfeifer-mail.de>"
  DESCRIPTION
    "A collection of CMake modules to simplify the use and development of Boost libraries."
  )

add_subdirectory(doc)

if(WIN32)
  set(cmake_install_dir "CMake")
else(WIN32)
  set(cmake_install_dir "share/Boost/CMake")
endif(WIN32)

set(BOOST_INCLUDE   "${CMAKE_INSTALL_PREFIX}/include")
set(BOOST_LIBRARIES "${CMAKE_INSTALL_PREFIX}/lib")
set(BOOST_MODULES   "${CMAKE_INSTALL_PREFIX}/${cmake_install_dir}/modules")
set(BOOST_RESOURCES "${CMAKE_INSTALL_PREFIX}/${cmake_install_dir}/resources")

foreach(config Config ConfigVersion)
  set(source_file "${CMAKE_CURRENT_SOURCE_DIR}/Boost${config}.cmake.in")
  set(binary_file "${CMAKE_CURRENT_BINARY_DIR}/Boost${config}.cmake")
  configure_file("${source_file}" "${binary_file}" @ONLY)
  install(FILES "${binary_file}"
    DESTINATION "${cmake_install_dir}"
    COMPONENT cmake_exe
    )
endforeach(config)

install(DIRECTORY modules resources
  DESTINATION "${cmake_install_dir}"
  COMPONENT cmake_exe
  )

#
set_boost_project("${BOOST_HAS_EXE_VAR}" ON)
