##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

find_package(Quickbook QUIET NO_MODULE)

if(Quickbook_FOUND)
  set(Quickbook_EXECUTABLE $<TARGET_FILE:quickbook>)
else()
  find_program(Quickbook_EXECUTABLE
    NAMES
      quickbook
    DOC
      "the quickbook tool"
    )
  if(Quickbook_EXECUTABLE)
    execute_process(COMMAND ${Quickbook_EXECUTABLE} --version
      OUTPUT_VARIABLE Quickbook_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    string(REGEX REPLACE "^Quickbook Version ([.0-9]+).*" "\\1"
      Quickbook_VERSION "${Quickbook_VERSION}"
      )
  endif()
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Quickbook 
    REQUIRED_VARS Quickbook_EXECUTABLE
    VERSION_VAR Quickbook_VERSION
    )
  set(Quickbook_FOUND ${QUICKBOOK_FOUND})
endif()

if(NOT Quickbook_FOUND)
  return()
endif()

include(CMakeParseArguments)

function(quickbook input)
  get_filename_component(input_path ${input} PATH)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.xml)
  add_custom_command(OUTPUT ${output}
    COMMAND ${Quickbook_EXECUTABLE}
            --input-file ${input}
            --include-path ${input_path}
            --include-path ${CMAKE_CURRENT_SOURCE_DIR}
            --output-file ${output}
    DEPENDS ${input} ${ARGN}
    )
endfunction(quickbook)
