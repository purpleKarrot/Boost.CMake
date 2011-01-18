##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)
include(FindPackageHandleStandardArgs)

set(DOXYGEN_SKIP_DOT ON)
find_package(Doxygen)

##########################################################################
# Documentation tools configuration                                      #
##########################################################################

# Find xsltproc to transform XML documents via XSLT
find_program(XSLTPROC_EXECUTABLE xsltproc
  DOC "xsltproc transforms XML via XSLT"
  )
find_package_handle_standard_args(XSLTPROC DEFAULT_MSG XSLTPROC_EXECUTABLE)

# Apache FO Processor
find_program(FOP_EXECUTABLE fop
   )
find_package_handle_standard_args(FOP DEFAULT_MSG FOP_EXECUTABLE)

# DocBook to LaTeX Publishing
find_program(DBLATEX_EXECUTABLE dblatex
  )
find_package_handle_standard_args(DBLATEX DEFAULT_MSG DBLATEX_EXECUTABLE)
# /usr/share/xml/docbook/stylesheet/dblatex/xsl/docbook.xsl

# Find the DocBook DTD (version 4.2)
find_path(DOCBOOK_DTD_DIR docbookx.dtd
  PATHS
    "/usr/share/xml/docbook/schema/dtd/4.2"
    "${CMAKE_BINARY_DIR}/stable-source/src/docbook_xml/4.2"
  DOC
    "Path to the DocBook DTD"
  )

# Find the DocBook XSL stylesheets
find_path(DOCBOOK_XSL_DIR html/html.xsl
  PATHS
    "/usr/share/xml/docbook/stylesheet/nwalsh"
    "${CMAKE_BINARY_DIR}/stable-source/src/docbook_xsl"
  DOC
    "Path to the DocBook XSL stylesheets"
  )

# Find the BoostBook DTD (it should be in the distribution!)
find_path(BOOSTBOOK_DTD_DIR boostbook.dtd
  PATHS
    "${CMAKE_BINARY_DIR}/stable-source/src/boostbook/dtd"
  DOC
    "Path to the BoostBook DTD"
  )

# Find the BoostBook XSL stylesheets (they should be in the distribution!)
find_path(BOOSTBOOK_XSL_DIR docbook.xsl
  PATHS
    "${CMAKE_BINARY_DIR}/stable-source/src/boostbook/xsl"
  DOC
    "Path to the BoostBook XSL stylesheets"
  )

find_package_handle_standard_args(DOCBOOK_DTD DEFAULT_MSG DOCBOOK_DTD_DIR)
find_package_handle_standard_args(DOCBOOK_XSL DEFAULT_MSG DOCBOOK_XSL_DIR)
find_package_handle_standard_args(BOOSTBOOK_DTD DEFAULT_MSG BOOSTBOOK_DTD_DIR)
find_package_handle_standard_args(BOOSTBOOK_XSL DEFAULT_MSG BOOSTBOOK_XSL_DIR)

set(BOOSTBOOK_CATALOG ${CMAKE_BINARY_DIR}/boostbook_catalog.xml)
file(WRITE ${BOOSTBOOK_CATALOG}
  "<?xml version=\"1.0\"?>\n"
  "<!DOCTYPE catalog\n"
  "  PUBLIC \"-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN\"\n"
  "  \"http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd\">\n"
  "<catalog xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">\n"
  "  <rewriteURI"
    " uriStartString=\"http://www.oasis-open.org/docbook/xml/\""
    " rewritePrefix=\"file://${DOCBOOK_DTD_DIR}/\""
    "/>\n"
  "  <rewriteURI"
    " uriStartString=\"http://docbook.sourceforge.net/release/xsl/current/\""
    " rewritePrefix=\"file://${DOCBOOK_XSL_DIR}/\""
    "/>\n"
  "  <rewriteURI"
    " uriStartString=\"http://www.boost.org/tools/boostbook/dtd/\""
    " rewritePrefix=\"file://${BOOSTBOOK_DTD_DIR}/\""
    "/>\n"
  "  <rewriteURI"
    " uriStartString=\"http://www.boost.org/tools/boostbook/xsl/\""
    " rewritePrefix=\"file://${BOOSTBOOK_XSL_DIR}/\""
    "/>\n"
  "</catalog>\n"
  )
mark_as_advanced(BOOSTBOOK_DTD_DIR BOOSTBOOK_XSL_DIR BOOSTBOOK_CATALOG)


set(QUICKBOOK_EXECUTABLE quickbook)


##########################################################################

function(boost_doxygen name)
  cmake_parse_arguments(DOXY "" "FILE" "INPUT;OUTPUT;PARAMETERS" ${ARGN})
  set(doxyfile ${CMAKE_CURRENT_BINARY_DIR}/${name}.doxyfile)

  if(DOXY_FILE)
    configure_file(${DOXY_FILE} ${doxyfile} COPYONLY)
  else()
    file(REMOVE ${doxyfile})
  endif()

  foreach(param ${DOXY_PARAMETERS})
    file(APPEND ${doxyfile} "${param}\n")
  endforeach(param)

  set(input)
  foreach(file ${DOXY_INPUT})
    get_filename_component(file ${file} ABSOLUTE)
    set(input "${input} \\\n \"${file}\"")
  endforeach(file)
  file(APPEND ${doxyfile} "INPUT = ${input}\n")

  add_custom_command(OUTPUT ${DOXY_OUTPUT}
    COMMAND ${DOXYGEN_EXECUTABLE} ${doxyfile}
    DEPENDS ${DOXY_INPUT}
    )
endfunction(boost_doxygen)

##########################################################################

# Transforms the source XML file by applying the given XSL stylesheet.
#
#   xsl_transform(output input [input2 input3 ...]
#                 STYLESHEET stylesheet
#                 [CATALOG catalog]
#                 [DIRECTORY mainfile]
#                 [PARAMETERS param1=value1 param2=value2 ...]
#                 [[MAKE_ALL_TARGET | MAKE_TARGET] target]
#                 [COMMENT comment])
#
# This macro builds a custom command that transforms an XML file
# (input) via the given XSL stylesheet. The output will either be a
# single file (the default) or a directory (if the DIRECTION argument
# is specified). The STYLESBEET stylesheet must be a valid XSL
# stylesheet. Any extra input files will be used as additional
# dependencies for the target. For example, these extra input files
# might refer to other XML files that are included by the input file
# through XInclude.
#
# When the XSL transform output is going to a directory, the mainfile
# argument provides the name of a file that will be generated within
# the output directory. This file will be used for dependency tracking.
# 
# XML catalogs can be used to remap parts of URIs within the
# stylesheet to other (typically local) entities. To provide an XML
# catalog file, specify the name of the XML catalog file via the
# CATALOG argument. It will be provided to the XSL transform.
# 
# The PARAMETERS argument is followed by param=value pairs that set
# additional parameters to the XSL stylesheet. The parameter names
# that can be used correspond to the <xsl:param> elements within the
# stylesheet.
# 
# To associate a target name with the result of the XSL
# transformation, use the MAKE_TARGET or MAKE_ALL_TARGET option and
# provide the name of the target. The MAKE_ALL_TARGET option only
# differs from MAKE_TARGET in that MAKE_ALL_TARGET will make the
# resulting target a part of the default build.
#
# If a COMMENT argument is provided, it will be used as the comment
# CMake provides when running this XSL transformation. Otherwise, the
# comment will be "Generating "output" via XSL transformation...".
function(boost_xsltproc output stylesheet input)
  cmake_parse_arguments(THIS_XSL "" "CATALOG" "PARAMETERS;DEPENDS" ${ARGN})

  set(catalog)
  if(THIS_XSL_CATALOG)
    set(catalog "XML_CATALOG_FILES=${THIS_XSL_CATALOG}")
    if(CMAKE_HOST_WIN32)
      set(catalog set "${catalog}" &)
    endif(CMAKE_HOST_WIN32)
  endif(THIS_XSL_CATALOG)

  # Translate XSL parameters into a form that xsltproc can use.
  set(stringparams)
  foreach(param ${THIS_XSL_PARAMETERS})
    string(REGEX REPLACE "([^=]*)=([^;]*)" "\\1;\\2" name_value ${param})
    list(GET name_value 0 name)
    list(GET name_value 1 value)
    list(APPEND stringparams --stringparam ${name} ${value})
  endforeach(param)

  # Run the XSLT processor to do the XML transformation.
  add_custom_command(OUTPUT ${output}
    COMMAND ${catalog} ${XSLTPROC_EXECUTABLE} --xinclude --nonet
            ${stringparams} -o ${output} ${stylesheet} ${input}
    DEPENDS ${input} ${THIS_XSL_DEPENDS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endfunction(boost_xsltproc)

##########################################################################

# Use Doxygen to parse header files and produce BoostBook output.
#
#   doxygen_to_boostbook(output header1 header2 ...
#     [PARAMETERS param1=value1 param2=value2 ... ])
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
  cmake_parse_arguments(REF "" "ID;TITLE;DOXYFILE" "DOXYGEN_PARAMETERS;DEPENDS" ${ARGN})
  set(reference_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}-xml)

  boost_doxygen(${name}
    INPUT
      ${REF_UNPARSED_ARGUMENTS}
    OUTPUT
      ${reference_dir}/index.xml
      ${reference_dir}/combine.xslt
    FILE "${REF_DOXYFILE}"
    PARAMETERS
      "GENERATE_LATEX = NO"
      "GENERATE_HTML = NO"
      "GENERATE_XML = YES"
      "XML_OUTPUT = ${reference_dir}"
      "${REF_DOXYGEN_PARAMETERS}"
    DEPENDS ${REF_DEPENDS}
    )

  # Collect Doxygen XML into a single XML file
  boost_xsltproc(
    ${reference_dir}/all.xml
    ${reference_dir}/combine.xslt
    ${reference_dir}/index.xml
    DEPENDS ${REF_DEPENDS}
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
    ${reference_dir}/all.xml
    PARAMETERS ${parameters}
    )
endfunction(boost_add_reference)

##########################################################################

function(boost_docbook input)
  set(output_html ${CMAKE_CURRENT_BINARY_DIR}/html/HTML.manifest)
  set(output_man  ${CMAKE_CURRENT_BINARY_DIR}/man/man.manifest)
# set(fop_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PROJECT_NAME}.fo)
  set(pdf_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PROJECT_NAME}.pdf)

  boost_xsltproc(${output_html} ${BOOSTBOOK_XSL_DIR}/html.xsl ${input}
    CATALOG ${BOOSTBOOK_CATALOG}
    )
  boost_xsltproc(${output_man} ${BOOSTBOOK_XSL_DIR}/manpages.xsl ${input}
    CATALOG ${BOOSTBOOK_CATALOG}
    )
# boost_xsltproc(${fop_file} ${BOOSTBOOK_XSL_DIR}/fo.xsl ${input}
#   CATALOG ${BOOSTBOOK_CATALOG}
#   PARAMETERS img.src.path=${CMAKE_CURRENT_BINARY_DIR}/images/
#   )
# add_custom_command(OUTPUT ${pdf_file}
#   COMMAND ${FOP_EXECUTABLE} ${fop_file} ${pdf_file} 2>/dev/null
#   DEPENDS ${fop_file}
#   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#   )
  add_custom_command(OUTPUT ${pdf_file}
    COMMAND ${DBLATEX_EXECUTABLE} -o ${pdf_file} ${input} 2>/dev/null
    DEPENDS ${input}
    )
  add_custom_target(pdf-${BOOST_PROJECT_NAME} DEPENDS ${pdf_file})
  add_custom_target(html-${BOOST_PROJECT_NAME} DEPENDS ${output_html})
endfunction(boost_docbook)

##########################################################################

#   <library name="Iterator Adaptors" dirname="utility" html-only="1"
#            url="../../libs/utility/iterator_adaptors.htm">
#     <libraryinfo>
#       <author>
#         <firstname>Dave</firstname>
#         <surname>Abrahams</surname>
#       </author>
#       <author>
#         <firstname>Jeremy</firstname>
#         <surname>Siek</surname>
#       </author>
#       <author>
#         <firstname>John</firstname>
#         <surname>Potter</surname>
#       </author>
#       <librarypurpose>Adapt a base type into a standard conforming iterator</librarypurpose>
#       <librarycategory name="category:iterators"/>
#     </libraryinfo>
#   </library>

# TODO: this function can be used for more than html...
function(boost_html_doc input)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PROJECT_NAME}.docbook)
  add_custom_command(OUTPUT ${output}
    COMMAND ${PANDOC_EXECUTABLE} -S -w docbook ${input} -o ${output}
    DEPENDS ${input}
    )
  boost_docbook(${output})
endfunction(boost_html_doc)

##########################################################################

function(boost_xml_doc input)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PROJECT_NAME}.docbook)
  boost_xsltproc(${output} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${input}
    CATALOG ${BOOSTBOOK_CATALOG}
    DEPENDS ${input} ${ARGN}
    )

  add_custom_target(db-${BOOST_PROJECT_NAME} DEPENDS ${output})

  set(doc ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PROJECT_NAME}-complete.xml)
  boost_xsltproc(${doc} ${CMAKE_SOURCE_DIR}/doc/copy.xslt ${input})
  add_custom_target(doc-${BOOST_PROJECT_NAME} DEPENDS ${doc})

  boost_docbook(${output})
endfunction(boost_xml_doc)

##########################################################################

function(boost_qbk_doc input)
  get_filename_component(input_path ${input} PATH)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PROJECT_NAME}.xml)
  add_custom_command(OUTPUT ${output}
    COMMAND ${QUICKBOOK_EXECUTABLE}
            --input-file ${input}
            --include-path ${input_path}
            --output-file ${output}
    DEPENDS ${input} ${ARGN}
    )
  boost_xml_doc(${output} ${ARGN})
endfunction(boost_qbk_doc)

##########################################################################

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
#   QuickBook
#   BoostBook (.XML extension):
function(boost_documentation input)
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

  if(input_ext STREQUAL ".qbk")
    boost_qbk_doc(${input_file} ${ARGN})
  elseif(input_ext STREQUAL ".xml")
    boost_xml_doc(${input_file} ${ARGN})
  elseif(input_ext STREQUAL ".html")
    boost_html_doc(${input_file} ${ARGN})
  else()
    message(STATUS "${BOOST_PROJECT_NAME} has unknown doc format: ${input_ext}")
  endif()
endfunction(boost_documentation)
