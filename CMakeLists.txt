##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

cmake_minimum_required(VERSION 2.8.5 FATAL_ERROR)
project(BoostCMake NONE)

set(CMAKE_MODULE_PATH "${BoostCMake_SOURCE_DIR}/modules")
include(BoostExport)

if(WIN32)
  set(boost_data_dir  ".")
else(WIN32)
  set(boost_data_dir  "share/boost")
endif(WIN32)

install(
  FILES
    ${Boost_SOURCE_DIR}/BoostComponents.cmake
    ${Boost_SOURCE_DIR}/BoostConfig.cmake
    ${Boost_SOURCE_DIR}/BoostConfigVersion.cmake
    ${Boost_SOURCE_DIR}/UseBoost.cmake
  DESTINATION "${boost_data_dir}"
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  )

# make the binary directory usable...
file(COPY modules resources DESTINATION .)

install(DIRECTORY modules resources
  DESTINATION "${boost_data_dir}"
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  )

if(WIN32)
  add_subdirectory(xsltproc)
endif(WIN32)

boost_export(CODE
  "set(Boost_MODULE_PATH \"\${CMAKE_CURRENT_LIST_DIR}/../cmake/modules\")\n"
  "set(Boost_RESOURCE_PATH \"\${CMAKE_CURRENT_LIST_DIR}/../cmake/resources\")\n"
  )

add_subdirectory(doc)
add_subdirectory(test)
