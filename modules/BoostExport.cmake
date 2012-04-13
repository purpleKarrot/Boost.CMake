##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(RypplExport)
include(CMakeParseArguments)
include("${Boost_DIR}/BoostCatalog.cmake")

# Export of Boost projects
function(boost_export)
  set(parameters
    BOOST_DEPENDS
    CODE
    DEFINITIONS
    DEPENDS
    INCLUDE_DIRECTORIES
    TARGETS
    )
  cmake_parse_arguments(EXPORT "" "VERSION" "${parameters}" ${ARGN})

  set(targets)
  foreach(target ${EXPORT_TARGETS})
    if(TARGET ${target})
      list(APPEND targets ${target})
    else()
      if(TARGET ${target}-shared)
        list(APPEND targets ${target}-shared)
      endif()
      if(TARGET ${target}-static)
        list(APPEND targets ${target}-static)
      endif()
    endif()
  endforeach(target)
  set(EXPORT_TARGETS ${targets})
  unset(targets)

  foreach(depends ${EXPORT_BOOST_DEPENDS})
    list(FIND Boost_CATALOG ${depends} index)
    if(index EQUAL "-1")
      message(WARNING "unknown Boost component: ${depends}")
    else()
      math(EXPR package_index "${index} + 1")
      math(EXPR version_index "${index} + 2")
      list(GET Boost_CATALOG ${package_index} package)
      list(GET Boost_CATALOG ${version_index} version)
      list(APPEND EXPORT_DEPENDS "${package} ${version}")
    endif()
  endforeach(depends)

  ryppl_export(
    CODE                ${EXPORT_CODE}
    DEFINITIONS         ${EXPORT_DEFINITIONS}
    DEPENDS             ${EXPORT_DEPENDS}
    INCLUDE_DIRECTORIES ${EXPORT_INCLUDE_DIRECTORIES}
    TARGETS             ${EXPORT_TARGETS}
    )
endfunction(boost_export)
