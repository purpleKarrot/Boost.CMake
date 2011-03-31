##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(BoostDoxygen)
include(BoostXsltproc)
include(CMakeParseArguments)

# Use Doxygen to parse header files and produce BoostBook output.
#
#   boost_add_reference(name header1 header2 ...
#     [DOXYFILE doxyfile ]
#     [TAGFILES tagfile1 tagfile2 ... ]
#     [DOXYGEN_PARAMETERS param1=value1 param2=value2 ... ]
#     [XSLTPROC_PARAMETERS param1=value1 param2=value2 ... ]
#     [DEPENDS dep dep2 ... ]
#     )
#
# This function sets up rules to transform a set of C/C++ header files
# into BoostBook reference documentation. The resulting BoostBook XML
# file will be named by the "output" parameter, and the set of headers
# is provided following the output file. The actual parsing of header
# files is provided by Doxygen, and is transformed into XML through
# various XSLT transformations.
#
# Doxygen has a variety of configuration parameters. One can supply
# extra Doxygen configuration parameters by providing NAME=VALUE pairs
# following the DOXYGEN_PARAMETERS argument. These parameters will be added to
# the Doxygen configuration file.
#
function(boost_add_reference name)
  set(mv_keys TAGFILES DOXYGEN_PARAMETERS XSLTPROC_PARAMETERS DEPENDS)
  cmake_parse_arguments(REF "" "DOXYFILE" "${mv_keys}" ${ARGN})

  # generate Doxygen XML from input source files
  boost_doxygen(${name} XML
    INPUT      ${REF_UNPARSED_ARGUMENTS}
    DOXYFILE   "${REF_DOXYFILE}"
    TAGFILES   "${REF_TAGFILES}"
    PARAMETERS "${REF_DOXYGEN_PARAMETERS}"
    )

  # Transform single Doxygen XML file into BoostBook XML
  boost_xsltproc(
    "${CMAKE_CURRENT_BINARY_DIR}/${name}.xml"
    "${BOOSTBOOK_XSL_DIR}/doxygen/doxygen2boostbook.xsl"
    "${${name}_xml}"
    PARAMETERS "${REF_XSLTPROC_PARAMETERS}"
    )
endfunction(boost_add_reference)
