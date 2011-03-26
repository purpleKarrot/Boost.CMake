##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)

# Transforms the input XML file by applying the given XSL stylesheet.
#
#   boost_xsltproc(<output> <stylesheet> <input>
#     [PARAMETERS param1=value1 param2=value2 ...]
#     [DEPENDS <dependancies>]
#     )
#
# This function builds a custom command that transforms an XML file
# (input) via the given XSL stylesheet. 
#
# The PARAMETERS argument is followed by param=value pairs that set
# additional parameters to the XSL stylesheet. The parameter names
# that can be used correspond to the <xsl:param> elements within the
# stylesheet.
#
# Additional dependancies may be passed via the DEPENDS argument.
# For example, dependancies might refer to other XML files that are
# included by the input file through XInclude.
function(boost_xsltproc output stylesheet input)
  cmake_parse_arguments(THIS_XSL "" "" "DEPENDS;PARAMETERS" ${ARGN})

  file(RELATIVE_PATH name "${CMAKE_CURRENT_BINARY_DIR}" "${output}")
  string(REGEX REPLACE "[./]" "_" name ${name})
  set(script "${CMAKE_CURRENT_BINARY_DIR}/${name}.cmake")

  file(WRITE ${script}
    "set(ENV{XML_CATALOG_FILES} \"${BOOSTBOOK_CATALOG}\")\n"
    "execute_process(COMMAND \${XSLTPROC_EXECUTABLE} --xinclude --nonet\n"
    )

  # Translate XSL parameters into a form that xsltproc can use.
  foreach(param ${THIS_XSL_PARAMETERS})
    string(REGEX REPLACE "([^=]*)=([^;]*)" "\\1;\\2" name_value ${param})
    list(GET name_value 0 name)
    list(GET name_value 1 value)
    file(APPEND ${script} "  --stringparam ${name} \"${value}\"\n")
  endforeach(param)

  file(APPEND ${script}
    "  -o ${output} ${stylesheet} ${input}\n"
    "  RESULT_VARIABLE result\n"
    "  )\n"
    "if(NOT result EQUAL 0)\n"
    "  message(FATAL_ERROR \"xsltproc returned \${result}\")\n"
    "endif()\n"
    )

  if(CMAKE_HOST_WIN32)
    set(XSLTPROC_EXECUTABLE "$<TARGET_FILE:${BOOST_NAMESPACE}xsltproc>")
    list(APPEND THIS_XSL_DEPENDS "${BOOST_NAMESPACE}xsltproc")
  else(CMAKE_HOST_WIN32)
    find_program(XSLTPROC_EXECUTABLE xsltproc)
    if(NOT XSLTPROC_EXECUTABLE)
      message(FATAL_ERROR "xsltproc notfound!")
    endif(NOT XSLTPROC_EXECUTABLE)
  endif(CMAKE_HOST_WIN32)

  # Run the XSLT processor to do the XML transformation.
  add_custom_command(OUTPUT ${output}
    COMMAND ${CMAKE_COMMAND} -DXSLTPROC_EXECUTABLE=${XSLTPROC_EXECUTABLE} -P ${script}
    DEPENDS ${input} ${THIS_XSL_DEPENDS}
    )
endfunction(boost_xsltproc)
