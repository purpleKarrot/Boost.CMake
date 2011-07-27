##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
# http://www.boost.org/LICENSE_1_0.txt                                   #
##########################################################################

if(DEFINED CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
  return()
endif()

include(BoostExtract)

set(libxml2_mirror
  "ftp://gd.tuwien.ac.at/pub/libxml"
  #"ftp://xmlsoft.org/libxml2"
  )

##########################################################################

boost_extract(libxml2 DOWNLOAD
  "${libxml2_mirror}/libxml2-2.7.8.tar.gz"
  8127a65e8c3b08856093099b52599c86
  )

boost_extract(libxslt DOWNLOAD
  "${libxml2_mirror}/libxslt-1.1.26.tar.gz"
  e61d0364a30146aaa3001296f853b2b9
  )

set(libxml2_dir "${CMAKE_CURRENT_BINARY_DIR}/libxml2")
set(libxslt_dir "${CMAKE_CURRENT_BINARY_DIR}/libxslt")

set(include_dir ${CMAKE_CURRENT_BINARY_DIR}/include)
file(MAKE_DIRECTORY ${include_dir})
include_directories(
  ${include_dir}
  ${libxml2_dir}/include
  ${libxslt_dir}
  )

add_definitions(
  -D_CRT_SECURE_NO_WARNINGS
  -D_CRT_NONSTDC_NO_WARNINGS
  -DNOLIBTOOL
  -DLIBXML_STATIC
  -DLIBXSLT_STATIC
  -DLIBEXSLT_STATIC
  -DWIN32_LEAN_AND_MEAN
  )

##########################################################################

set(VERSION "2.7.8")
set(LIBXML_VERSION_NUMBER "20708")
set(LIBXML_VERSION_EXTRA "-boost")
set(WITH_TRIO 0)
set(WITH_THREADS 0)
set(WITH_TREE 1)
set(WITH_OUTPUT 1)
set(WITH_PUSH 1)
set(WITH_READER 1)
set(WITH_PATTERN 1)
set(WITH_WRITER 1)
set(WITH_SAX1 1)
set(WITH_FTP 0)
set(WITH_HTTP 0)
set(WITH_VALID 1)
set(WITH_HTML 1)
set(WITH_LEGACY 0)
set(WITH_C14N 1)
set(WITH_CATALOG 1)
set(WITH_DOCB 0)
set(WITH_XPATH 1)
set(WITH_XPTR 1)
set(WITH_XINCLUDE 1)
set(WITH_ICONV 0)
set(WITH_ICU 0)
set(WITH_ISO8859X 1)
set(WITH_DEBUG 0)
set(WITH_MEM_DEBUG 0)
set(WITH_RUN_DEBUG 0)
set(WITH_REGEXPS 1)
set(WITH_SCHEMAS 1)
set(WITH_SCHEMATRON 1)
set(WITH_MODULES 0)
set(WITH_ZLIB 0)
configure_file(${libxml2_dir}/include/libxml/xmlversion.h.in
  ${include_dir}/libxml/xmlversion.h @ONLY)

file(WRITE ${include_dir}/config.h.in "#include <win32config.h>\n")
configure_file(${include_dir}/config.h.in ${include_dir}/config.h COPYONLY)

##########################################################################

set(VERSION "1.1.26")
set(LIBXSLT_VERSION_NUMBER "10126")
set(LIBXSLT_VERSION_EXTRA "-boost")
set(WITH_XSLT_DEBUG 0)
set(WITH_MEM_DEBUG 0)
set(WITH_TRIO 0)
set(WITH_DEBUGGER 0)
set(WITH_MODULES 0)
set(XSLT_LOCALE_XLOCALE 0)
set(XSLT_LOCALE_WINAPI 1)
configure_file(${libxslt_dir}/libxslt/xsltconfig.h.in
  ${include_dir}/libxslt/xsltconfig.h @ONLY)

##########################################################################

set(VERSION "1.1.26")
set(LIBEXSLT_VERSION_NUMBER "10126")
set(LIBEXSLT_VERSION_EXTRA "-boost")
set(WITH_CRYPTO 1)
configure_file(${libxslt_dir}/libexslt/exsltconfig.h.in
  ${include_dir}/libexslt/exsltconfig.h @ONLY)

file(WRITE ${include_dir}/exsltconfig.h.in "#include <libexslt/exsltconfig.h>\n")
configure_file(${include_dir}/exsltconfig.h.in ${include_dir}/exsltconfig.h COPYONLY)

##########################################################################

add_executable(xsltproc
  ${libxml2_dir}/SAX.c
  ${libxml2_dir}/entities.c
  ${libxml2_dir}/encoding.c
  ${libxml2_dir}/error.c
  ${libxml2_dir}/parserInternals.c
  ${libxml2_dir}/parser.c
  ${libxml2_dir}/tree.c
  ${libxml2_dir}/hash.c
  ${libxml2_dir}/list.c
  ${libxml2_dir}/xmlIO.c
  ${libxml2_dir}/xmlmemory.c
  ${libxml2_dir}/uri.c
  ${libxml2_dir}/valid.c
  ${libxml2_dir}/xlink.c
  ${libxml2_dir}/HTMLparser.c
  ${libxml2_dir}/HTMLtree.c
  ${libxml2_dir}/debugXML.c
  ${libxml2_dir}/xpath.c
  ${libxml2_dir}/xpointer.c
  ${libxml2_dir}/xinclude.c
  ${libxml2_dir}/nanohttp.c
  ${libxml2_dir}/nanoftp.c
  ${libxml2_dir}/DOCBparser.c
  ${libxml2_dir}/catalog.c
  ${libxml2_dir}/globals.c
  ${libxml2_dir}/threads.c
  ${libxml2_dir}/c14n.c
  ${libxml2_dir}/xmlstring.c
  ${libxml2_dir}/xmlregexp.c
  ${libxml2_dir}/xmlschemas.c
  ${libxml2_dir}/xmlschemastypes.c
  ${libxml2_dir}/xmlunicode.c
  ${libxml2_dir}/xmlreader.c
  ${libxml2_dir}/relaxng.c
  ${libxml2_dir}/dict.c
  ${libxml2_dir}/SAX2.c
  ${libxml2_dir}/xmlwriter.c
  ${libxml2_dir}/legacy.c
  ${libxml2_dir}/chvalid.c
  ${libxml2_dir}/pattern.c
  ${libxml2_dir}/xmlsave.c
  ${libxml2_dir}/xmlmodule.c
  ${libxml2_dir}/schematron.c

  ${libxslt_dir}/libxslt/attrvt.c
  ${libxslt_dir}/libxslt/xslt.c
  ${libxslt_dir}/libxslt/xsltlocale.c
  ${libxslt_dir}/libxslt/xsltutils.c
  ${libxslt_dir}/libxslt/pattern.c
  ${libxslt_dir}/libxslt/templates.c
  ${libxslt_dir}/libxslt/variables.c
  ${libxslt_dir}/libxslt/keys.c
  ${libxslt_dir}/libxslt/numbers.c
  ${libxslt_dir}/libxslt/extensions.c
  ${libxslt_dir}/libxslt/extra.c
  ${libxslt_dir}/libxslt/functions.c
  ${libxslt_dir}/libxslt/namespaces.c
  ${libxslt_dir}/libxslt/imports.c
  ${libxslt_dir}/libxslt/attributes.c
  ${libxslt_dir}/libxslt/documents.c
  ${libxslt_dir}/libxslt/preproc.c
  ${libxslt_dir}/libxslt/transform.c
  ${libxslt_dir}/libxslt/security.c

  ${libxslt_dir}/libexslt/exslt.c
  ${libxslt_dir}/libexslt/common.c
  ${libxslt_dir}/libexslt/crypto.c
  ${libxslt_dir}/libexslt/math.c
  ${libxslt_dir}/libexslt/sets.c
  ${libxslt_dir}/libexslt/functions.c
  ${libxslt_dir}/libexslt/strings.c
  ${libxslt_dir}/libexslt/date.c
  ${libxslt_dir}/libexslt/saxon.c
  ${libxslt_dir}/libexslt/dynamic.c
  ${libxslt_dir}/xsltproc/xsltproc.c
  )

set_target_properties(xsltproc PROPERTIES
  FOLDER "${BOOST_CURRENT_NAME}"
  PROJECT_LABEL "xsltproc (executable)"
  )

install(TARGETS xsltproc
  DESTINATION bin
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  CONFIGURATIONS Release
  )

file(APPEND "${BOOST_EXPORTS_FILE}"
  "add_executable(\${BOOST_NAMESPACE}xsltproc IMPORTED)\n"
  "set_target_properties(\${BOOST_NAMESPACE}xsltproc PROPERTIES\n"
  " IMPORTED_LOCATION \"\${CMAKE_CURRENT_LIST_DIR}/../bin/xsltproc.exe\"\n"
  " )\n"
  )
