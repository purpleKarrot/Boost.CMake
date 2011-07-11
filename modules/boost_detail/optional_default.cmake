################################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>                   #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

#set default values for BOOST_ENABLED_DOCS, ~_TESTS, ~_EXAMPLES
macro(boost_optional_default option default)
  if(NOT DEFINED BOOST_ENABLED_${option})
    set(Boost_BUILD_${option} ${default} PARENT_SCOPE)
  elseif(BOOST_ENABLED_${option} STREQUAL "NONE")
    set(Boost_BUILD_${option} OFF PARENT_SCOPE)
  elseif(BOOST_ENABLED_${option} STREQUAL "ALL")
    set(Boost_BUILD_${option} ON PARENT_SCOPE)
  else()
    list(FIND BOOST_ENABLED_${option} ${project} enabled)
    if(enabled GREATER "-1")
      set(Boost_BUILD_${option} ON PARENT_SCOPE)
    else()
      set(Boost_BUILD_${option} OFF PARENT_SCOPE)
    endif()
  endif()
endmacro(boost_optional_default)
