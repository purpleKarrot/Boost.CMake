##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

if(COMMAND boost_add_directory)
  return()
endif(COMMAND boost_add_directory)


function(boost_add_directory type name)
  string(TOUPPER "BOOST_ENABLE_${CMAKE_PROJECT_NAME}_${type}" option)
  option(${option} "Enable ${type} for ${CMAKE_PROJECT_NAME}" ON)
  if(${${option}})
    add_subdirectory(${name})
  endif(${${option}})
endfunction(boost_add_directory)
