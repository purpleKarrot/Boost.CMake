##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

# This file transforms comments from a CMake module to QuickBook.

file(WRITE ${OUTPUT_FILE} "")
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
        "[section ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}]\n"
        "${buffer}"
        "[endsect]\n\n"
        )
    endif()
    set(buffer)
  endif()
endforeach(line)
