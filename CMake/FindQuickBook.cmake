##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

if(QUICKBOOK_FOUND)
  return()
endif(QUICKBOOK_FOUND)

find_program(QUICKBOOK_EXECUTABLE quickbook)

if(QUICKBOOK_EXECUTABLE)
  execute_process(COMMAND ${QUICKBOOK_EXECUTABLE} --version
    OUTPUT_VARIABLE QUICKBOOK_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REGEX REPLACE "^Quickbook Version (.+)$" "\\1"
    QUICKBOOK_VERSION "${QUICKBOOK_VERSION}")
endif(QUICKBOOK_EXECUTABLE)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(QuickBook
  REQUIRED_VARS QUICKBOOK_EXECUTABLE
  VERSION_VAR QUICKBOOK_VERSION
  )

mark_as_advanced(QUICKBOOK_EXECUTABLE)
set(QUICKBOOK_FOUND ${QUICKBOOK_FOUND} CACHE INTERNAL "")
