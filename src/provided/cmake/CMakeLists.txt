# Distributed under the Boost Software License, Version 1.0.
# See http://www.boost.org/LICENSE_1_0.txt

include(BoostProject)
include(BoostDocs)

boost_project(CMake
  AUTHORS
    "Daniel Pfeifer <daniel -at- pfeifer-mail.de>"
  DESCRIPTION
    "An approach to a modularized build of the Boost C++ Libraries with CMake."
  )

install(DIRECTORY ${CMAKE_SOURCE_DIR}/CMake
  DESTINATION share/Boost
# CONFIGURATIONS
  COMPONENT cmake_exe
  )

#
set_boost_project("${BOOST_HAS_EXE_VAR}" ON)

#
boost_documentation(cmake.qbk reference.xml reference.qbk)
