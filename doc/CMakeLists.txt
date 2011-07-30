##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

set(boost_modules
  BoostProject
  BoostAddLibrary
  BoostAddExecutable
  BoostAddPythonExtension
  BoostAddReference
  BoostDocumentation
  BoostExtract
  BoostTesting
  )

set(reference)
foreach(module ${boost_modules})
  set(input "${CMAKE_CURRENT_SOURCE_DIR}/../modules/${module}.cmake")
  set(output "${module}.txt")
  add_custom_command(OUTPUT ${output}
    COMMAND ${CMAKE_COMMAND}
            -DINPUT_FILE=${input}
            -DOUTPUT_FILE=${output}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/reference.cmake
    DEPENDS ${input} reference.cmake
    )

  list(APPEND reference ${output})
endforeach(module)

boost_documentation(boost_cmake.txt
    build.txt
    guide_user.txt
    guide_devel.txt
    reference.txt
    ${reference}
  IMAGES
    images/cmake_configure.png
    images/cmake_install.png
    images/install_darwin.png
    images/install_windows.png
  )
