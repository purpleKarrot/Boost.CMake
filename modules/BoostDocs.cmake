##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


# Transforms the source XML file by applying the given XSL stylesheet.
#
#   xsl_transform(<output> <stylesheet> <input>
#     [CATALOG <catalog>]
#     [PARAMETERS param1=value1 param2=value2 ...]
#     [DEPENDS <dependancies>]
#     )
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
endfunction(boost_xsltproc)


#
#   boost_doxygen(<name> [XML] [TAG]
#     [DOXYFILE <doxyfile>]
#     [INPUT <input files>]
#     [TAGFILES <tagfiles>]
#     [PARAMETERS" <parameters>]
#     )
#
function(boost_doxygen name)
  set(${name}_tag "${name}_tag-NOTFOUND" PARENT_SCOPE)
  set(${name}_xml "${name}_xml-NOTFOUND" PARENT_SCOPE)
endfunction(boost_doxygen)


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
endfunction(boost_add_reference)


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
endfunction(boost_documentation)

##########################################################################

if(NOT DEFINED BOOST_BUILD_DOCUMENTATION)
  set(BOOST_BUILD_DOCUMENTATION ON)
endif(NOT DEFINED BOOST_BUILD_DOCUMENTATION)

if(NOT BOOST_BUILD_DOCUMENTATION)
  return()
endif(NOT BOOST_BUILD_DOCUMENTATION)

set(DOXYGEN_SKIP_DOT ON)
find_package(Doxygen)
if(NOT DOXYGEN_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT DOXYGEN_FOUND)

find_package(XSLTPROC)
if(NOT XSLTPROC_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT XSLTPROC_FOUND)

find_package(DBLATEX)
find_package(FOP)
if(NOT DBLATEX_FOUND AND NOT FOP_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT DBLATEX_FOUND AND NOT FOP_FOUND)

find_package(BoostBook)
if(NOT BOOSTBOOK_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT BOOSTBOOK_FOUND)

find_package(QuickBook)
if(NOT QUICKBOOK_FOUND)
  set(BOOST_BUILD_DOCUMENTATION OFF)
endif(NOT QUICKBOOK_FOUND)

find_package(HTMLHelp)

set(BOOST_BUILD_DOCUMENTATION ${BOOST_BUILD_DOCUMENTATION}
  CACHE BOOL "Whether documentation should be built")

if(NOT BOOST_BUILD_DOCUMENTATION)
  message(STATUS "Documentation will not be built!")
  return()
endif(NOT BOOST_BUILD_DOCUMENTATION)

include(CMakeParseArguments)

##########################################################################

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

function(boost_doxygen name)
  cmake_parse_arguments(DOXY
    "XML;TAG" "DOXYFILE" "INPUT;TAGFILES;PARAMETERS" ${ARGN})

  set(doxyfile ${CMAKE_CURRENT_BINARY_DIR}/${name}.doxyfile)

  if(DOXY_DOXYFILE)
    configure_file(${DOXY_DOXYFILE} ${doxyfile} COPYONLY)
  else()
    file(REMOVE ${doxyfile})
  endif()

  set(default_parameters
    "QUIET = YES"
    "WARN_IF_UNDOCUMENTED = NO"
    "GENERATE_LATEX = NO"
    "GENERATE_HTML = NO"
    "GENERATE_XML = NO"
    )

  foreach(param ${default_parameters} ${DOXY_PARAMETERS})
    file(APPEND ${doxyfile} "${param}\n")
  endforeach(param)

  set(output)
  if(DOXY_XML)
    set(xml_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}-xml)
    list(APPEND output ${xml_dir}/index.xml ${xml_dir}/combine.xslt)
    file(APPEND ${doxyfile}
      "GENERATE_XML = YES\n"
      "XML_OUTPUT = ${xml_dir}\n"
      )
  endif(DOXY_XML)

  if(DOXY_TAG)
    set(tagfile ${CMAKE_CURRENT_BINARY_DIR}/${name}.tag)
    list(APPEND output ${tagfile})
    file(APPEND ${doxyfile} "GENERATE_TAGFILE = ${tagfile}\n")
    set(${name}_tag ${tagfile} PARENT_SCOPE)
  endif(DOXY_TAG)

  set(tagfiles)
  foreach(file ${DOXY_TAGFILES})
    get_filename_component(file ${file} ABSOLUTE)
    set(tagfiles "${tagfiles} \\\n \"${file}\"")
  endforeach(file)
  file(APPEND ${doxyfile} "TAGFILES = ${tagfiles}\n")

  set(input)
  foreach(file ${DOXY_INPUT})
    get_filename_component(file ${file} ABSOLUTE)
    set(input "${input} \\\n \"${file}\"")
  endforeach(file)
  file(APPEND ${doxyfile} "INPUT = ${input}\n")

  add_custom_command(OUTPUT ${output}
    COMMAND ${DOXYGEN_EXECUTABLE} ${doxyfile}
    DEPENDS ${DOXY_INPUT} ${DOXY_TAGFILES}
    )

  if(DOXY_XML)
    # Collect Doxygen XML into a single XML file
    boost_xsltproc(
      ${xml_dir}/all.xml
      ${xml_dir}/combine.xslt
      ${xml_dir}/index.xml
      )
    set(${name}_xml ${xml_dir}/all.xml PARENT_SCOPE)
  endif(DOXY_XML)
endfunction(boost_doxygen)

##########################################################################

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

##########################################################################

function(boost_docbook input)
  set(doc_targets)

  if(OFF) # generate HTML
    set(output_html ${CMAKE_CURRENT_BINARY_DIR}/html/HTML.manifest)
    boost_xsltproc(${output_html} ${BOOSTBOOK_XSL_DIR}/html.xsl ${input}
      CATALOG ${BOOSTBOOK_CATALOG}
      )
  endif()

  if(OFF) # generate manpages
    set(output_man  ${CMAKE_CURRENT_BINARY_DIR}/man/man.manifest)
    boost_xsltproc(${output_man} ${BOOSTBOOK_XSL_DIR}/manpages.xsl ${input}
      CATALOG ${BOOSTBOOK_CATALOG}
      )
  endif()

  if(FOP_FOUND)
    set(fop_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.fo)
    set(pdf_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.pdf)
    boost_xsltproc(${fop_file} ${BOOSTBOOK_XSL_DIR}/fo.xsl ${input}
      CATALOG ${BOOSTBOOK_CATALOG}
      PARAMETERS img.src.path=${CMAKE_CURRENT_BINARY_DIR}/images/
      )
    add_custom_command(OUTPUT ${pdf_file}
      COMMAND ${FOP_EXECUTABLE} ${fop_file} ${pdf_file} #2>/dev/null
      DEPENDS ${fop_file}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      )
    list(APPEND doc_targets ${pdf_file})
  elseif(DBLATEX_FOUND)
    set(pdf_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.pdf)
    add_custom_command(OUTPUT ${pdf_file}
      COMMAND ${DBLATEX_EXECUTABLE} -o ${pdf_file} ${input} #2>/dev/null
      DEPENDS ${input}
      )
    list(APPEND doc_targets ${pdf_file})
  endif()

  if(HTML_HELP_COMPILER)
    set(hhp_output ${CMAKE_CURRENT_BINARY_DIR}/htmlhelp/htmlhelp.hhp)
    set(chm_output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.chm)
    boost_xsltproc(${hhp_output} ${BOOSTBOOK_XSL_DIR}/html-help.xsl ${input}
      CATALOG ${BOOSTBOOK_CATALOG}
      PARAMETERS
        "img.src.path=${CMAKE_CURRENT_BINARY_DIR}/images/"
        "htmlhelp.chm=../${BOOST_CURRENT_PROJECT}.chm"
      )
    set(hhc_cmake ${CMAKE_CURRENT_BINARY_DIR}/hhc.cmake)
    file(WRITE ${hhc_cmake}
      "execute_process(COMMAND \"${HTML_HELP_COMPILER}\" htmlhelp.hhp"
      " WORKING_DIRECTORY \"${CMAKE_CURRENT_BINARY_DIR}/htmlhelp\""
      " OUTPUT_QUIET)"
      )
    add_custom_command(OUTPUT ${chm_output}
      COMMAND "${CMAKE_COMMAND}" -P "${hhc_cmake}"
      DEPENDS ${hhp_output}
      )
    list(APPEND doc_targets ${chm_output})
  endif(HTML_HELP_COMPILER)

  set(target "${BOOST_CURRENT_PROJECT}-doc")
  add_custom_target(${target} DEPENDS ${doc_targets})
  set_target_properties(${target} PROPERTIES
    FOLDER "${BOOST_CURRENT_FOLDER}"
    PROJECT_LABEL "${BOOST_CURRENT_PROJECT} (documentation)"
    )
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

## TODO: this function can be used for more than html...
function(boost_html_doc input)
# set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.docbook)
# add_custom_command(OUTPUT ${output}
#   COMMAND ${PANDOC_EXECUTABLE} -S -w docbook ${input} -o ${output}
#   DEPENDS ${input}
#   )
# boost_docbook(${output})

  if(HTML_HELP_COMPILER)
    set(hhp_file ${CMAKE_CURRENT_BINARY_DIR}/htmlhelp.hhp)
    file(WRITE ${hhp_file}
      "[OPTIONS]\n"
      "Binary TOC=Yes\n"
      "Auto TOC=9\n"
      "Compatibility=1.1 or later\n"
      "Compiled file=${BOOST_CURRENT_PROJECT}.chm\n"
      "Contents file=toc.hhc\n"
      "Default Window=Main\n"
      "Default topic=index.html\n"
      "Display compile progress=No\n"
      "Full-text search=Yes\n"
      "Language=0x0409 English (UNITED STATES)\n"
      "Title=Boost.${BOOST_CURRENT_PROJECT}\n"
      "Enhanced decompilation=No\n"
      "[WINDOWS]\n"
      "Main=\"Boost.${BOOST_CURRENT_PROJECT}\",\"toc.hhc\",,\"index.html\",\"index.html\",,,,,0x2520,,0x603006,,,,,,,,0\n"
      "[FILES]\n"
      )
    foreach(file ${input} ${ARGN})
      file(RELATIVE_PATH file "${CMAKE_CURRENT_BINARY_DIR}" "${file}")
      file(APPEND ${hhp_file} "${file}\n")
    endforeach(file)
    set(hhc_cmake ${CMAKE_CURRENT_BINARY_DIR}/hhc.cmake)
    file(WRITE ${hhc_cmake}
      "execute_process(COMMAND \"${HTML_HELP_COMPILER}\" htmlhelp.hhp"
      " WORKING_DIRECTORY \"${CMAKE_CURRENT_BINARY_DIR}\""
      " OUTPUT_QUIET)"
      )
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.chm
      COMMAND "${CMAKE_COMMAND}" -P "${hhc_cmake}"
      DEPENDS ${input} ${ARGN}
      )
    set(target "${BOOST_CURRENT_PROJECT}-doc")
    add_custom_target(${target} DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.chm)
    set_target_properties(${target} PROPERTIES
      FOLDER "${BOOST_CURRENT_FOLDER}"
      PROJECT_LABEL "${BOOST_CURRENT_PROJECT} (documentation)"
      )
  endif(HTML_HELP_COMPILER)
endfunction(boost_html_doc)

##########################################################################

function(boost_xml_doc input)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.docbook)
  boost_xsltproc(${output} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${input}
    CATALOG ${BOOSTBOOK_CATALOG}
    DEPENDS ${input} ${ARGN}
    )

# add_custom_target(db-${BOOST_CURRENT_PROJECT} DEPENDS ${output})
# set(doc ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}-complete.xml)
# boost_xsltproc(${doc} ${CMAKE_SOURCE_DIR}/doc/copy.xslt ${input})
# add_custom_target(doc-${BOOST_CURRENT_PROJECT} DEPENDS ${doc})

  boost_docbook(${output})
endfunction(boost_xml_doc)

##########################################################################

function(boost_qbk_doc input)
  get_filename_component(input_path ${input} PATH)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.xml)
  add_custom_command(OUTPUT ${output}
    COMMAND ${QUICKBOOK_EXECUTABLE}
            --input-file ${input}
            --include-path ${input_path}
            --include-path ${CMAKE_CURRENT_SOURCE_DIR}
            --output-file ${output}
    DEPENDS ${input} ${ARGN}
    )
  boost_xml_doc(${output} ${ARGN})
endfunction(boost_qbk_doc)

##########################################################################

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
