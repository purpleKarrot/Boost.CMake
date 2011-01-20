##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

# Find xsltproc to transform XML documents via XSLT
find_program(XSLTPROC_EXECUTABLE xsltproc
  DOC "xsltproc transforms XML via XSLT"
  )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(XSLTPROC
  DEFAULT_MSG XSLTPROC_EXECUTABLE
  )
