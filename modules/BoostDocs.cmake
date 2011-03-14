##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

if(CMAKE_HOST_WIN32)
  set(dev_null NUL)
else()
  set(dev_null /dev/null)
endif()

if(NOT TARGET documentation)
  add_custom_target(documentation)
endif(NOT TARGET documentation)  

##########################################################################

include(BoostDocTools)
include(BoostAddReference)
include(BoostDocumentation)
include(BoostDoxygen)
include(BoostXsltproc)

if(NOT BOOST_BUILD_DOCUMENTATION)
  return()
endif(NOT BOOST_BUILD_DOCUMENTATION)

include(CMakeParseArguments)

##########################################################################

function(boost_docbook input)
  set(doc_targets)
  set(html_dir "${CMAKE_CURRENT_BINARY_DIR}/html/${BOOST_CURRENT_PROJECT}")

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
    boost_xsltproc("${hhp_output}" "${stylesheet}" "${input}"
      CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
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
      COMPONENT "${BOOST_DOC_COMPONENT}"
      )
  else() # generate HTML and manpages
    set(output_html "${html_dir}/index.html")
    set(stylesheet "${Boost_RESOURCE_PATH}/docbook-xsl/xhtml.xsl")
    boost_xsltproc("${output_html}" "${stylesheet}" "${input}"
      CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
      )
    list(APPEND doc_targets ${output_html})
#   set(output_man  ${CMAKE_CURRENT_BINARY_DIR}/man/man.manifest)
#   boost_xsltproc(${output_man} ${BOOSTBOOK_XSL_DIR}/manpages.xsl ${input}
#     CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
#     )
#   list(APPEND doc_targets ${output_man})
    install(DIRECTORY "${html_dir}"
      DESTINATION "share/doc/boost/"
      COMPONENT "${BOOST_DOC_COMPONENT}"
      )
  endif()

  if(DBLATEX_FOUND OR FOP_FOUND)
    set(pdf_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.pdf)
  
    if(FOP_FOUND)
      set(fop_file ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_CURRENT_PROJECT}.fo)
      boost_xsltproc(${fop_file} ${BOOSTBOOK_XSL_DIR}/fo.xsl ${input}
        CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
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

    list(APPEND doc_targets ${pdf_file})
    install(FILES ${pdf_file}
      DESTINATION share/doc/Boost
      COMPONENT "${BOOST_DOC_COMPONENT}"
      )
  endif()

  set(target "${BOOST_CURRENT_PROJECT}-doc")
  add_custom_target(${target} DEPENDS ${doc_targets})
  set_target_properties(${target} PROPERTIES
    FOLDER "${BOOST_CURRENT_FOLDER}"
    PROJECT_LABEL "${BOOST_CURRENT_PROJECT} (documentation)"
    )

  # TODO: actually I want to add this to 'preinstall'
  add_dependencies(documentation ${target})
  set_boost_project("${BOOST_HAS_DOC_VAR}" ON)
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
    CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
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
    COMMAND $<TARGET_FILE:${BOOST_NAMESPACE}quickbook>
            --input-file ${input}
            --include-path ${input_path}
            --include-path ${CMAKE_CURRENT_SOURCE_DIR}
            --output-file ${output}
    DEPENDS ${input} ${ARGN}
    )
  boost_xml_doc(${output} ${ARGN})
endfunction(boost_qbk_doc)
