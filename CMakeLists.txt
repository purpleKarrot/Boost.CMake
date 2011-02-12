##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostProject)
include(BoostDocs)

boost_project(CMake
  AUTHORS
    "Daniel Pfeifer <daniel -at- pfeifer-mail.de>"
  DESCRIPTION
    "A collection of CMake modules to simplify the development of Boost libraries."
  )

install(DIRECTORY modules resources
  DESTINATION share/Boost/CMake
# CONFIGURATIONS
  COMPONENT cmake_exe
  )

#
set_boost_project("${BOOST_HAS_EXE_VAR}" ON)

add_subdirectory(doc)


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
