##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


# Use Doxygen to parse header files and produce BoostBook output.
#
#   doxygen_to_boostbook(output header1 header2 ...
#     [PARAMETERS param1=value1 param2=value2 ... ]
#     )
#
# This macro sets up rules to transform a set of C/C++ header files
# into BoostBook reference documentation. The resulting BoostBook XML
# file will be named by the "output" parameter, and the set of headers
# is provided following the output file. The actual parsing of header
# files is provided by Doxygen, and is transformed into XML through
# various XSLT transformations.
#
# Doxygen has a variety of configuration parameters. One can supply
# extra Doxygen configuration parameters by providing NAME=VALUE pairs
# following the PARAMETERS argument. These parameters will be added to
# the Doxygen configuration file.
#
function(boost_add_reference name)
endfunction(boost_add_reference)


if(NOT BOOST_BUILD_DOCUMENTATION)
  return()
endif(NOT BOOST_BUILD_DOCUMENTATION)


function(boost_add_reference name)
  cmake_parse_arguments(REF ""
    "ID;TITLE;DOXYFILE" "DOXYGEN_PARAMETERS;TAGFILES;DEPENDS" ${ARGN})

  boost_doxygen(${name} XML
    INPUT      ${REF_UNPARSED_ARGUMENTS}
    DOXYFILE   "${REF_DOXYFILE}"
    TAGFILES   "${REF_TAGFILES}"
    PARAMETERS "${REF_DOXYGEN_PARAMETERS}"
    )

  set(parameters)
  if(REF_ID)
    list(APPEND parameters "boost.doxygen.refid=${REF_ID}")
  endif(REF_ID)

  if(REF_TITLE)
    list(APPEND parameters "boost.doxygen.reftitle=${REF_TITLE}")
  endif(REF_TITLE)

  # Transform single Doxygen XML file into BoostBook XML
  boost_xsltproc(
    ${CMAKE_CURRENT_BINARY_DIR}/${name}.xml
    ${BOOSTBOOK_XSL_DIR}/doxygen/doxygen2boostbook.xsl
    ${${name}_xml}
    PARAMETERS ${parameters}
    )
endfunction(boost_add_reference)
