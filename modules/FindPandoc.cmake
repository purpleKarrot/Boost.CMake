################################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>              #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

find_program(PANDOC_EXECUTABLE
  NAMES
    pandoc
  PATHS
    $ENV{PROGRAMFILES}/Pandoc/bin
  DOC
    "a universal document converter"
  )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PANDOC DEFAULT_MSG PANDOC_EXECUTABLE)

mark_as_advanced(PANDOC_EXECUTABLE)
