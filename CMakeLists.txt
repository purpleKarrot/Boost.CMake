##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)

find_package(Boost 1.45 REQUIRED COMPONENTS boostbook quickbook NO_MODULE)
include("${Boost_DEV_FILE}")

boost_project(CMake TOOL
  AUTHORS
    "Daniel Pfeifer <daniel -at- pfeifer-mail.de>"
  DESCRIPTION
    "A collection of CMake modules to simplify the use and development of Boost libraries."
  DEPENDS
    boostbook
    quickbook
  DEB_DEPENDS
    doxygen
    xsltproc
  )

add_subdirectory(doc)

file(WRITE ${BOOST_EXPORT_FILE}
  "include(\${CMAKE_CURRENT_LIST_DIR}/boostbook.cmake)\n"
  "include(\${CMAKE_CURRENT_LIST_DIR}/quickbook.cmake)\n"
  )

if(WIN32)
  set(boost_data_dir  ".")
  set(BOOST_INCLUDE   "\${CMAKE_CURRENT_LIST_DIR}/include")
  set(BOOST_LIBRARIES "\${CMAKE_CURRENT_LIST_DIR}/lib")
else(WIN32)
  set(boost_data_dir  "share/boost")
  set(BOOST_INCLUDE   "\${CMAKE_CURRENT_LIST_DIR}/../../include")
  set(BOOST_LIBRARIES "\${CMAKE_CURRENT_LIST_DIR}/../../lib")
endif(WIN32)

set(config_file "${CMAKE_CURRENT_BINARY_DIR}/boost-config.cmake")
set(version_file "${CMAKE_CURRENT_BINARY_DIR}/boost-config-version.cmake")

configure_file(boost-config.cmake.in "${config_file}" @ONLY)
configure_file(boost-config-version.cmake.in "${version_file}" @ONLY)

install(FILES "${config_file}" "${version_file}"
  DESTINATION "${boost_data_dir}"
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  )

install(DIRECTORY modules resources
  DESTINATION "${boost_data_dir}"
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  )

if(NOT WIN32)
  return()
endif(NOT WIN32)

include(BoostExtract)

function(download name url md5)
  set(archive "${CMAKE_CURRENT_BINARY_DIR}/${name}.tgz")
  if(EXISTS "${archive}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E md5sum "${archive}"
      OUTPUT_VARIABLE output
      )
    if("${output}" MATCHES "^${md5} ")
      return()
    endif("${output}" MATCHES "^${md5} ")
  endif(EXISTS "${archive}")
  message(STATUS "Downloading '${url}'")
  file(DOWNLOAD "${url}" "${archive}" SHOW_PROGRESS EXPECTED_MD5 "${md5}")
endfunction(download)

function(extract_download name url md5)
  download(${name} ${url} ${md5})
  boost_extract(
    "${CMAKE_CURRENT_BINARY_DIR}/${name}.tgz"
    "${CMAKE_CURRENT_BINARY_DIR}/${name}"
    )
endfunction(extract_download)

extract_download(doxygen
  ftp://ftp.stack.nl/pub/users/dimitri/doxygen-1.7.3.windows.bin.zip
  cafd01d3460066c40a377fd00dd98f8a
  )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/doxygen/doxygen.exe
  DESTINATION bin
  COMPONENT "${BOOST_RUNTIME_COMPONENT}"
  CONFIGURATIONS Release
  )

file(APPEND ${BOOST_EXPORT_FILE}
  "add_executable(\${BOOST_NAMESPACE}doxygen IMPORTED)\n"
  "set_target_properties(\${BOOST_NAMESPACE}doxygen PROPERTIES\n"
  " IMPORTED_LOCATION \"\${CMAKE_CURRENT_LIST_DIR}/../bin/doxygen.exe\"\n"
  " )\n"
  )

add_subdirectory(xsltproc)
