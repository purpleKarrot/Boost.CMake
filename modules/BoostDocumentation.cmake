##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
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
# QuickBook
# BoostBook (.XML extension):
function(boost_documentation input)
  if(NOT Boost_BUILD_DOCS)
    return()
  endif()

  cmake_parse_arguments(DOC "" "" "IMAGES" ${ARGN})

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
  foreach(file ${DOC_UNPARSED_ARGUMENTS})
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

  # copy images
  foreach(image ${DOC_IMAGES})
    set(src ${CMAKE_CURRENT_SOURCE_DIR}/${image})
    set(dst ${CMAKE_CURRENT_BINARY_DIR}/html/${image})
    add_custom_command(OUTPUT ${dst}
      COMMAND ${CMAKE_COMMAND} -E copy ${src} ${dst}
      DEPENDS ${src}
      )
    list(APPEND depends ${dst})
  endforeach(image)

  if(input_ext STREQUAL ".txt")
    boost_doc_asciidoc(${input_file} ${depends})
  elseif(input_ext STREQUAL ".qbk")
    boost_doc_quickbook(${input_file} ${depends})
  elseif(input_ext STREQUAL ".xml")
    boost_doc_boostbook(${input_file} ${depends})
  elseif(input_ext STREQUAL ".html")
    boost_html_doc(${input_file} ${depends})
  else()
    message(STATUS "${BOOST_CURRENT_PROJECT} has unknown doc format: ${input_ext}")
  endif()
endfunction(boost_documentation)

##########################################################################

if(NOT TARGET documentation)
  add_custom_target(documentation)
endif(NOT TARGET documentation)  

if(CMAKE_HOST_WIN32)
  set(dev_null NUL)
else()
  set(dev_null /dev/null)
endif()

include(BoostDoxygen)

if(CMAKE_HOST_WIN32)
  set(XSLTPROC_EXECUTABLE "$<TARGET_FILE:${BOOST_NAMESPACE}xsltproc>")
endif(CMAKE_HOST_WIN32)
find_package(Xsltproc REQUIRED)
include("${XSLTPROC_USE_FILE}")

include(CMakeParseArguments)
find_package(HTMLHelp QUIET)
find_package(DBLATEX QUIET)
find_package(FOProcessor QUIET)

##########################################################################

function(boost_docbook input)
  find_package(Boost COMPONENTS boostbook NO_MODULE)
  set(doc_targets)
  set(html_dir "${CMAKE_CURRENT_BINARY_DIR}/html")

  file(COPY
      "${Boost_RESOURCE_PATH}/images"
      "${Boost_RESOURCE_PATH}/boost.css"
    DESTINATION
      "${html_dir}"
    )

  if(HTML_HELP_COMPILER)
    set(hhp_output "${html_dir}/htmlhelp.hhp")
    set(chm_output "${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.chm")
    set(stylesheet "${Boost_RESOURCE_PATH}/docbook-xsl/htmlhelp.xsl")
    xsltproc("${hhp_output}" "${stylesheet}" "${input}"
      PARAMETERS "htmlhelp.chm=../${BOOST_CURRENT_PROJECT}.chm"
      )
    set(hhc_cmake ${CMAKE_CURRENT_BINARY_DIR}/hhc.cmake)
    file(WRITE ${hhc_cmake}
      "execute_process(COMMAND \"${HTML_HELP_COMPILER}\" htmlhelp.hhp"
      " WORKING_DIRECTORY \"${html_dir}\" OUTPUT_QUIET)"
      )
    add_custom_command(OUTPUT ${chm_output}
      COMMAND "${CMAKE_COMMAND}" -P "${hhc_cmake}"
      DEPENDS ${hhp_output}
      )
    list(APPEND doc_targets ${chm_output})
    install(FILES "${chm_output}"
      DESTINATION "doc"
      COMPONENT "${BOOST_MANUAL_COMPONENT}"
      CONFIGURATIONS "Release"
      )
  else() # generate HTML and manpages
    set(output_html "${html_dir}/index.html")
    set(stylesheet "${Boost_RESOURCE_PATH}/docbook-xsl/xhtml.xsl")
    xsltproc("${output_html}" "${stylesheet}" "${input}"
      CATALOG "${BOOSTBOOK_CATALOG}"
      )
    list(APPEND doc_targets ${output_html})
#   set(output_man  ${CMAKE_CURRENT_BINARY_DIR}/man/man.manifest)
#   xsltproc(${output_man} ${BOOSTBOOK_XSL_DIR}/manpages.xsl ${input})
#   list(APPEND doc_targets ${output_man})
    install(DIRECTORY "${html_dir}/"
      DESTINATION "share/doc/boost/${BOOST_CURRENT_PROJECT}"
      COMPONENT "${BOOST_MANUAL_COMPONENT}"
      CONFIGURATIONS "Release"
      )
  endif()

  set(target "${BOOST_CURRENT_PROJECT}-doc")
  add_custom_target(${target} DEPENDS ${doc_targets})
  set_target_properties(${target} PROPERTIES
    FOLDER "${BOOST_CURRENT_FOLDER}"
    PROJECT_LABEL "${BOOST_CURRENT_PROJECT} (documentation)"
    )
  add_dependencies(documentation ${target})

  # build documentation as pdf
  if(DBLATEX_FOUND OR FOPROCESSOR_FOUND)
    set(pdf_dir ${CMAKE_BINARY_DIR}/pdf)
    set(pdf_file ${pdf_dir}/${BOOST_CURRENT_PROJECT}.pdf)
    file(MAKE_DIRECTORY ${pdf_dir})

    if(FOPROCESSOR_FOUND)
      set(fop_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.fo)
      xsltproc(${fop_file} ${BOOSTBOOK_XSL_DIR}/fo.xsl ${input}
        PARAMETERS img.src.path=${CMAKE_CURRENT_BINARY_DIR}/images/
        )
      add_custom_command(OUTPUT ${pdf_file}
        COMMAND ${FO_PROCESSOR} ${fop_file} ${pdf_file} 2>${dev_null}
        DEPENDS ${fop_file}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        )
    elseif(DBLATEX_FOUND)
      add_custom_command(OUTPUT ${pdf_file}
        COMMAND ${DBLATEX_EXECUTABLE} -o ${pdf_file} ${input} 2>${dev_null}
        DEPENDS ${input}
        )
    endif()

    set(target "${BOOST_CURRENT_PROJECT}-pdf")
    add_custom_target(${target} DEPENDS ${pdf_file})
    set_target_properties(${target} PROPERTIES
      FOLDER "${BOOST_CURRENT_FOLDER}"
      PROJECT_LABEL "${BOOST_CURRENT_PROJECT} (pdf)"
      )
  endif(DBLATEX_FOUND OR FOPROCESSOR_FOUND)
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

################################################################################
# BoostBook                                                                    #
################################################################################

function(boost_doc_boostbook input)
  find_package(Boost COMPONENTS boostbook NO_MODULE)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.docbook)
  xsltproc(${output} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${input}
    DEPENDS ${input} ${ARGN}
    )
  boost_docbook(${output})
endfunction(boost_doc_boostbook)

################################################################################
# Quickbook                                                                    #
################################################################################

function(boost_doc_quickbook input)
  find_package(Boost COMPONENTS quickbook NO_MODULE)
  get_filename_component(input_path ${input} PATH)
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.xml)
  add_custom_command(OUTPUT ${output}
    COMMAND $<TARGET_FILE:${BOOST_NAMESPACE}quickbook>
            --input-file ${input}
            --include-path ${input_path}
            --include-path ${CMAKE_CURRENT_SOURCE_DIR}
            --output-file ${output}
    DEPENDS ${input} ${ARGN}
    )
  boost_doc_boostbook(${output} ${ARGN})
endfunction(boost_doc_quickbook)

################################################################################
# AsciiDoc                                                                     #
################################################################################

function(boost_doc_asciidoc input)
  find_package(AsciiDoc REQUIRED)
  set(output "${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.docbook")
  add_custom_command(OUTPUT "${output}"
    COMMAND ${ASCIIDOC_EXECUTABLE} -b docbook -o ${output} ${input}
    DEPENDS ${input} ${ARGN}
    )
  boost_docbook(${output})
endfunction(boost_doc_asciidoc)
