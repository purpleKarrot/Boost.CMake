##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include("${Boost_USE_FILE}")
include(BoostConfiguration)

include(BoostProject)
include(BoostForwardFile)
include(BoostAddHeaders)
include(BoostParseTargetArguments)
include(BoostPrecompileHeader)
include(BoostAddLibrary)
include(BoostAddExecutable)
include(BoostAddPythonExtension)

#
if(APPLE)
  set(CPACK_PACKAGE_ICON "${Boost_RESOURCE_PATH}/boost.icns")
else(APPLE)
  set(CPACK_PACKAGE_ICON "${Boost_RESOURCE_PATH}\\\\boost.bmp")
endif(APPLE)

set(CPACK_NSIS_MUI_ICON    "${Boost_RESOURCE_PATH}/boost.ico")
set(CPACK_NSIS_MUI_UNIICON "${Boost_RESOURCE_PATH}/boost.ico")
