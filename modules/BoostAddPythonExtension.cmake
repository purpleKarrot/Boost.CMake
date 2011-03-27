##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


#
function(boost_add_python_extension)
  boost_parse_target_arguments(${ARGN})

  set(target ${TARGET_NAME}_py)
  add_library(${target} SHARED ${TARGET_SOURCES})
  boost_link_libraries(${target} python ${TARGET_LINK_BOOST_LIBRARIES} SHARED)
  target_link_libraries(${target} ${TARGET_LINK_LIBRARIES})

  set_property(TARGET ${target} APPEND PROPERTY
    COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1;BOOST_ALL_NO_LIB=1")

  set_target_properties(${target} PROPERTIES
    DEFINE_SYMBOL "${TARGET_DEFINE_SYMBOL}"
    OUTPUT_NAME "${TARGET_NAME}"
    PREFIX ""
    FOLDER "${BOOST_CURRENT_FOLDER}"
    PROJECT_LABEL "${TARGET_NAME} (python extension)"
#   VERSION "${Boost_VERSION}"
    )

  if(WIN32)
    set_target_properties(${target} PROPERTIES
      SUFFIX .pyd
      IMPORT_SUFFIX .pyd
      )
  endif()

  boost_install_libraries(${target})
endfunction(boost_add_python_extension)
