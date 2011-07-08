##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

find_program(XSLTPROC_EXECUTABLE
  NAMES
    xsltproc
  DOC
    "the xsltproc tool"
  )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(XSLTPROC DEFAULT_MSG XSLTPROC_EXECUTABLE)

if(XSLTPROC_FOUND)
  set(XSLTPROC_USE_FILE "${CMAKE_CURRENT_LIST_DIR}/UseXsltproc.cmake")
endif(XSLTPROC_FOUND)
