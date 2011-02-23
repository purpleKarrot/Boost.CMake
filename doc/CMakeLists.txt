##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostDocs)

set(reference)
file(GLOB boost_modules "${Boost_MODULE_PATH}/Boost*.cmake")
foreach(module ${boost_modules})
  get_filename_component(name ${module} NAME_WE)
  set(output "${name}.qbk")
  add_custom_command(OUTPUT ${output}
    COMMAND ${CMAKE_COMMAND}
            -DINPUT_FILE=${module}
            -DOUTPUT_FILE=${output}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/reference.cmake
    DEPENDS ${module} reference.cmake
    )

  list(APPEND reference ${output})
endforeach(module)

#
boost_documentation(cmake.qbk ${reference})
