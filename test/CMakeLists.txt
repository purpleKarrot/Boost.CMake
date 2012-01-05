##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

project(BoostCMake CXX)

find_package(Boost COMPONENTS cmake NO_MODULE)
include(${Boost_USE_FILE})

include(BoostAddTestSuite)

boost_add_test_suite(
  COMPILE
    compile.cpp
  COMPILE_FAIL
    compile_fail.cpp
  LINK
    link.cpp
  LINK_FAIL
    link_fail.cpp
  RUN
    run.cpp
  RUN_FAIL
    run_fail.cpp
  )
