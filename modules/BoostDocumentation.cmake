##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

option(BOOST_BUILD_DOCUMENTATION "Should documentation be built?" ON)

# Adds documentation for the current library or tool project
#
#   boost_documentation(source1 source2 source3 ... )
#
# This macro describes the documentation for a library or tool, which
# will be built and installed as part of the normal build
# process. Documentation can be in a variety of formats, and the input
# format will determine how that documentation is transformed. The
# documentation's format is determined by its extension, and the
# following input formats are supported:
# 
# QuickBook
# BoostBook (.XML extension):
function(boost_documentation input)
  if(NOT BOOST_BUILD_DOCUMENTATION)
    return()
  endif(NOT BOOST_BUILD_DOCUMENTATION)

  get_filename_component(input ${input} ABSOLUTE)
  get_filename_component(input_ext ${input} EXT)
  get_filename_component(input_name ${input} NAME)
  set(input_file ${CMAKE_CURRENT_BINARY_DIR}/${input_name})
  
  # copy to destination directory because quickbook screws up xinclude paths 
  # when the output is not in the source directory
  add_custom_command(OUTPUT ${input_file}
    COMMAND ${CMAKE_COMMAND} -E copy ${input} ${input_file}
    DEPENDS ${input}
    )

  # copy all dependencies that are not built
  set(depends)
  foreach(file ${ARGN})
    set(srcfile ${CMAKE_CURRENT_SOURCE_DIR}/${file})
    set(binfile ${CMAKE_CURRENT_BINARY_DIR}/${file})
    if(EXISTS ${srcfile})
      add_custom_command(OUTPUT ${binfile}
        COMMAND ${CMAKE_COMMAND} -E copy ${srcfile} ${binfile}
        DEPENDS ${srcfile}
        )
    endif(EXISTS ${srcfile})
    list(APPEND depends ${binfile})
  endforeach(file)

  if(input_ext STREQUAL ".qbk")
    boost_qbk_doc(${input_file} ${depends})
  elseif(input_ext STREQUAL ".xml")
    boost_xml_doc(${input_file} ${depends})
  elseif(input_ext STREQUAL ".html")
    boost_html_doc(${input_file} ${depends})
  else()
    message(STATUS "${BOOST_CURRENT_PROJECT} has unknown doc format: ${input_ext}")
  endif()
endfunction(boost_documentation)
