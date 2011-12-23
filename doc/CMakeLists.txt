##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

project(BoostCMake NONE)

find_package(Boost COMPONENTS cmake boostbook NO_MODULE)
include(${Boost_USE_FILE})
include(BoostDocumentation)

find_package(AsciiDoc REQUIRED)

set(depends)
set(dbk_file "${CMAKE_CURRENT_BINARY_DIR}/boost_cmake.dbk")

set(sources
  boost_cmake.txt
  build.txt
  guide_user.txt
  guide_devel.txt
  )

set(modules
  BoostAddDirectory
  BoostAddExecutable
  BoostAddLibrary
  BoostAddPythonExtension
  BoostAddReference
  BoostDocumentation
  BoostDoxygen
  BoostExport
  BoostExtract
  BoostTesting
  BoostVariables
  FindAsciiDoc
  FindDBLATEX
  FindFOProcessor
  FindIconv
  FindICU
  FindPandoc
  FindQuickbook
  FindXSLTPROC
  )

foreach(file ${sources})
  set(srcfile "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
  set(binfile "${CMAKE_CURRENT_BINARY_DIR}/${file}")
  add_custom_command(OUTPUT ${binfile}
    COMMAND ${CMAKE_COMMAND} -E copy ${srcfile} ${binfile}
    DEPENDS ${srcfile}
    )
  list(APPEND depends ${binfile})
endforeach(file)

set(reference_file "${CMAKE_CURRENT_BINARY_DIR}/reference.txt")
file(WRITE ${reference_file} "//\n\n== Module Reference\n\n")
list(APPEND depends ${reference_file})

foreach(module ${modules})
  set(srcfile "${CMAKE_CURRENT_SOURCE_DIR}/../modules/${module}.cmake")
  set(binfile "${CMAKE_CURRENT_BINARY_DIR}/${module}.txt")
  add_custom_command(OUTPUT ${binfile}
    COMMAND ${CMAKE_COMMAND}
            -DINPUT_FILE=${srcfile}
            -DOUTPUT_FILE=${binfile}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/reference.cmake
    DEPENDS ${srcfile} reference.cmake
    )
  file(APPEND ${reference_file} "include::${module}.txt[]\n")
  list(APPEND depends ${binfile})
endforeach(module)

add_custom_command(OUTPUT ${dbk_file}
  COMMAND ${ASCIIDOC_EXECUTABLE} -b docbook -o ${dbk_file} boost_cmake.txt
  DEPENDS ${depends}
  )

boost_documentation(${dbk_file}
  #images/cmake_configure.png
  #images/cmake_install.png
  #images/install_darwin.png
  #images/install_windows.png
  )
