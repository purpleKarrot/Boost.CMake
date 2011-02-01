################################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>              #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

find_program(FOP_EXECUTABLE fop)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FOP DEFAULT_MSG FOP_EXECUTABLE)
