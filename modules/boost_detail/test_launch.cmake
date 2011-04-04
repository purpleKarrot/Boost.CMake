##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

execute_process(COMMAND "${EXECUTABLE}" RESULT_VARIABLE result)

message(STATUS "${EXECUTABLE} returned ${result}")

if((FAIL AND result EQUAL 0) OR (NOT FAIL AND NOT result EQUAL 0))
  file(REMOVE "${EXECUTABLE}")
  message(FATAL_ERROR "result unexpected!")
endif()
