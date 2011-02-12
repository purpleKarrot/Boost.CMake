##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostDocs)

set(reference)
foreach(module BoostDocs BoostProject BoostTesting)
  set(input "${CMAKE_CURRENT_SOURCE_DIR}/../modules/${module}.cmake")
  set(output "${module}.qbk")
  add_custom_command(OUTPUT ${output}
    COMMAND ${CMAKE_COMMAND}
            -DINPUT_FILE=${input}
            -DOUTPUT_FILE=${output}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/reference.cmake
    DEPENDS ${input} reference.cmake
    )

  list(APPEND reference ${output})
endforeach(module)

#
boost_documentation(cmake.qbk ${reference})