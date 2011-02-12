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
    "An approach to a modularized build of the Boost C++ Libraries with CMake."
  )

file(GLOB modules modules/*.cmake)
install(FILES ${modules}
  DESTINATION share/Boost/CMake
# CONFIGURATIONS
  COMPONENT cmake_exe
  )

#
set_boost_project("${BOOST_HAS_EXE_VAR}" ON)

add_subdirectory(doc)
