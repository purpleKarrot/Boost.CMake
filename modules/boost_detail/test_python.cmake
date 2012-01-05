##########################################################################
# Copyright (C) 2012 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

set(ENV{PYTHONPATH} ${PYTHONPATH})

execute_process(COMMAND ${PYTHON_EXECUTABLE} ${PYTHON_FILE}
  RESULT_VARIABLE result
  )

if((FAIL AND result EQUAL 0) OR (NOT FAIL AND NOT result EQUAL 0))
  message(FATAL_ERROR "")
endif()
