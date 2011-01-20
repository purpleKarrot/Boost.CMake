##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

set(BOOSTBOOK_CATALOG ${CMAKE_BINARY_DIR}/boostbook_catalog.xml)

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

# Find the DocBook DTD (version 4.2)
find_path(DOCBOOK_DTD_DIR docbookx.dtd
  PATHS
    "/usr/share/xml/docbook/schema/dtd/4.2"
  DOC
    "Path to the DocBook DTD"
  )

# Find the DocBook XSL stylesheets
find_path(DOCBOOK_XSL_DIR html/html.xsl
  PATHS
    "/usr/share/xml/docbook/stylesheet/nwalsh"
  DOC
    "Path to the DocBook XSL stylesheets"
  )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BOOSTBOOK DEFAULT_MSG
  BOOSTBOOK_CATALOG
  BOOSTBOOK_DTD_DIR
  BOOSTBOOK_XSL_DIR
  DOCBOOK_DTD_DIR
  DOCBOOK_XSL_DIR
  )

mark_as_advanced(BOOSTBOOK_DTD_DIR BOOSTBOOK_XSL_DIR BOOSTBOOK_CATALOG)

if(NOT BOOSTBOOK_FOUND)
  set(BOOSTBOOK_CATALOG BOOSTBOOK_CATALOG-NOTFOUND)
  return()
endif(NOT BOOSTBOOK_FOUND)

file(WRITE ${BOOSTBOOK_CATALOG}
  "<?xml version=\"1.0\"?>\n"
  "<!DOCTYPE catalog\n"
  " PUBLIC \"-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN\"\n"
  " \"http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd\">\n"
  "<catalog xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">\n"
  " <rewriteURI"
    " uriStartString=\"http://www.oasis-open.org/docbook/xml/4.2/\""
    " rewritePrefix=\"${DOCBOOK_DTD_DIR}/\""
    "/>\n"
  " <rewriteURI"
    " uriStartString=\"http://docbook.sourceforge.net/release/xsl/current/\""
    " rewritePrefix=\"${DOCBOOK_XSL_DIR}/\""
    "/>\n"
  " <rewriteURI"
    " uriStartString=\"http://www.boost.org/tools/boostbook/dtd/\""
    " rewritePrefix=\"${BOOSTBOOK_DTD_DIR}/\""
    "/>\n"
  " <rewriteURI"
    " uriStartString=\"http://www.boost.org/tools/boostbook/xsl/\""
    " rewritePrefix=\"${BOOSTBOOK_XSL_DIR}/\""
    "/>\n"
  "</catalog>\n"
  )
