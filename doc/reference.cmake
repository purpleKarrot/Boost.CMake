##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

# This file transforms comments from a CMake module to QuickBook.

get_filename_component(name ${INPUT_FILE} NAME_WE)

file(WRITE ${OUTPUT_FILE} "=== ${name}\n")

file(STRINGS ${INPUT_FILE} lines)

set(buffer)
foreach(line ${lines})
  if(line MATCHES "^##")
    set(buffer)
  elseif(line MATCHES "^# ?(.*)")
    set(buffer "${buffer}${CMAKE_MATCH_1}\n")
  else()
    if(buffer AND line MATCHES "^([^ (]+)\\(([^ )]+)")
      file(APPEND ${OUTPUT_FILE}
        "==== ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}\n"
        "${buffer}\n\n"
        )
    endif()
    set(buffer)
  endif()
endforeach(line)
