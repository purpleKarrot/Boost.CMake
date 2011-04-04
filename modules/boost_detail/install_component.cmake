##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

if(WIN32)
  set(components_dir "components")
else(WIN32)
  set(components_dir "share/boost/components")
endif(WIN32)

set(component_file "${BOOST_BINARY_DIR}/${BOOST_PROJECT}.cmake")
set(include_guard "_boost_${BOOST_PROJECT}_component_included")

file(WRITE ${component_file}
  "#\n\n"
  "if(${include_guard})\n"
  "  return()\n"
  "endif(${include_guard})\n"
  "set(${include_guard} TRUE)\n\n"
  )

if(NOT BOOST_IS_TOOL)
  foreach(depend ${BOOST_DEPENDS})
    file(APPEND ${component_file}
      "include(\${CMAKE_CURRENT_LIST_DIR}/${depend}.cmake)\n"
      )
  endforeach(depend)
endif(NOT BOOST_IS_TOOL)

file(READ ${BOOST_EXPORTS} exports)
file(APPEND ${component_file} "${exports}")

if(EXISTS "${BOOST_TARGETS}")
  file(APPEND ${component_file} "\n"
    "file(GLOB config_files \"\${CMAKE_CURRENT_LIST_DIR}/${BOOST_PROJECT}-*.cmake\")\n"
    "foreach(file \${config_files})\n"
    "  include(\"\${file}\")\n"
    "endforeach(file)\n"
    )
endif(EXISTS "${BOOST_TARGETS}")

file(INSTALL
  DESTINATION "${CMAKE_INSTALL_PREFIX}/${components_dir}"
  TYPE FILE
  FILES "${component_file}"
  )

file(REMOVE "${component_file}")
