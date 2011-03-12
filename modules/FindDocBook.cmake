##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

# Find the DocBook DTD (version 4.2)
find_path(DOCBOOK_DTD_DIR docbookx.dtd
  PATHS
    "/usr/share/xml/docbook/schema/dtd/4.2"
    "/opt/local/share/xml/docbook/4.2"
    "$ENV{SystemDrive}/docbook/xml"
  DOC
    "Path to the DocBook DTD"
  )

# Find the DocBook XSL stylesheets
find_path(DOCBOOK_XSL_DIR html/html.xsl
  PATHS
    "/usr/share/xml/docbook/stylesheet/nwalsh"
    "/opt/local/share/xsl/docbook-xsl"
    "$ENV{SystemDrive}/docbook/xsl"
  DOC
    "Path to the DocBook XSL stylesheets"
  )

set(DOCBOOK_CATALOG ${CMAKE_BINARY_DIR}/docbook_catalog.xml
  CACHE INTERNAL "" FORCE
  )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DocBook DEFAULT_MSG
  DOCBOOK_CATALOG
  DOCBOOK_DTD_DIR
  DOCBOOK_XSL_DIR
  )

if(NOT DOCBOOK_FOUND)
  set(DOCBOOK_CATALOG DOCBOOK_CATALOG-NOTFOUND CACHE INTERNAL "" FORCE)
  return()
endif(NOT DOCBOOK_CATALOG)

file(WRITE ${DOCBOOK_CATALOG}
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
  "</catalog>\n"
  )
