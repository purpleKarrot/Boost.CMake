################################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>               #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>                #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>              #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

include(CMakeParseArguments)

# This function creates a Boost regression test. If the test can be built,
# executed, and exits with a return code of zero, it will be considered to have
# passed.
#
#   boost_add_test(name [COMPILE|LINK|RUN] [FAIL]
#                  [source1 source2 ...]
#                  [LINK_BOOST_LIBRARIES boostlib1 boostlib2 ...]
#                  [LINK_LIBRARIES linklibs ...]
#                  [ARGS arg1 arg2... ]
#                 )
#
# 'name' is the name of the test. source1, source2, etc. are the
# source files that will be built and linked into the test
# executable. If no source files are provided, the file "name.cpp"
# will be used instead.
#
# There are several optional arguments to control how the regression
# test is built and executed:
#
#   LINK_BOOST_LIBRARIES: States that this test executable depends on and links
#   against another Boost library.
#
#   LINK_LIBRARIES: Provides additional libraries against which the test
#   executable will be linked. For example, one might provide "expat"
#   as options to LINK_LIBRARIES, to state that this executable should be
#   linked against the external "expat" library. Use LINK_LIBRARIES for
#   libraries external to Boost; for Boost libraries, use LINK_BOOST_LIBRARIES.
#
#   ARGS: Provides additional arguments that will be passed to the
#   test executable when it is run.
#
function(boost_add_test name)
  cmake_parse_arguments(TEST "COMPILE;RUN;LINK;FAIL" ""
    "ARGS;LINK_BOOST_LIBRARIES;LINK_LIBRARIES" ${ARGN})

  # If no sources are specified, use the name of the test.cpp
  if(NOT TEST_UNPARSED_ARGUMENTS)
    set(TEST_UNPARSED_ARGUMENTS ${name})
  endif(NOT TEST_UNPARSED_ARGUMENTS)

  set(test_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}) 
  set(listfile ${test_dir}/CMakeLists.txt)

  file(WRITE ${listfile}
    "cmake_minimum_required(VERSION 2.8)\n"
    "project(Test)\n\n"
    "set_directory_properties(PROPERTIES\n"
    )

  foreach(property COMPILE_DEFINITIONS INCLUDE_DIRECTORIES)
    get_directory_property(value ${property})
    file(APPEND ${listfile} "  ${property} \"${value}\"\n")
  endforeach(property)

  file(APPEND ${listfile}
    "  )\n\n"
    "link_directories(\"${CMAKE_BINARY_DIR}/lib\")\n\n"
    "set(sources\n"
    )

  foreach(source ${TEST_UNPARSED_ARGUMENTS})
    get_filename_component(absolute "${source}" ABSOLUTE)
    file(RELATIVE_PATH relative "${test_dir}" "${absolute}")
    file(APPEND ${listfile} "  ${relative}\n")
  endforeach(source)

  file(APPEND ${listfile}
    "  )\n\n"
    "add_library(compile STATIC \${sources})\n\n"
    "add_executable(link \${sources})\n"
    )

  if(TEST_LINK_LIBRARIES OR TEST_LINK_BOOST_LIBRARIES)
    file(APPEND ${listfile} "target_link_libraries(link\n")
    foreach(lib ${TEST_LINK_LIBRARIES})
      file(APPEND ${listfile} "  ${lib}\n")
    endforeach(lib)
    foreach(lib ${TEST_LINK_BOOST_LIBRARIES})
      file(APPEND ${listfile} "  boost_${lib}.a\n")
      # set(target "lib_${boost_lib}_static")
      # get_target_property(DEPEND_TYPE ${target} TYPE)
      # get_target_property(DEPEND_LOCATION ${target} LOCATION)
    endforeach(lib)
    file(APPEND ${listfile} "  )\n")
  endif(TEST_LINK_LIBRARIES OR TEST_LINK_BOOST_LIBRARIES)

  file(APPEND ${listfile} "\n"
    "add_custom_target(run COMMAND link \"${TEST_ARGS}\"\n"
    "  # WORKING_DIRECTORY \${WORKING_DIRECTORY}\n"
    "  )\n"
    )

  if(TEST_COMPILE)
    set(target compile)
  elseif(TEST_LINK)
    set(target link)
  else()
    set(target run)
  endif()

  set(testname "${BOOST_CURRENT_PROJECT}-${name}")

  add_test(${testname} 
    ${CMAKE_CTEST_COMMAND}
    --build-and-test ${name} ${name}
    --build-generator ${CMAKE_GENERATOR}
    --build-makeprogram ${CMAKE_MAKE_PROGRAM}
    --build-target "${target}"
    --build-noclean
    --build-options
    "-DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_CXX_COMPILER_WORKS:INTERNAL=${CMAKE_CXX_COMPILER_WORKS}"
    "-DCMAKE_DETERMINE_CXX_ABI_COMPILED:INTERNAL=${CMAKE_DETERMINE_CXX_ABI_COMPILED}"
    "-DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}"
    "-DCMAKE_C_COMPILER_WORKS:INTERNAL=${CMAKE_C_COMPILER_WORKS}"
    "-DCMAKE_DETERMINE_C_ABI_COMPILED:INTERNAL=${CMAKE_DETERMINE_C_ABI_COMPILED}"
    "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
    )

  # TODO: RUN FAIL testcases should be tested to COMPILE and LINK too!

  if(TEST_FAIL)
    set(will_fail ON)
    set(fail_label known-failure)
  else(TEST_FAIL)
    set(will_fail OFF)
    set(fail_label)
  endif(TEST_FAIL)

  set_tests_properties(${testname} PROPERTIES
    LABELS "${BOOST_CURRENT_PROJECT};${fail_label}"
    WILL_FAIL "${will_fail}"
    )
endfunction(boost_add_test)

################################################################################

#
# boost_test_suite(
#   RUN
#     ...
#   COMPILE_FAIL
#     ...
#   LINK_BOOST_LIBRARIES
#     unit_test_framework
#     ...
#   )
#
function(boost_test_suite)
  set(args COMPILE COMPILE_FAIL LINK LINK_FAIL RUN RUN_FAIL
    LINK_BOOST_LIBRARIES LINK_LIBRARIES)
  cmake_parse_arguments(TEST "" "" "${args}" ${ARGN})

  foreach(test ${TEST_COMPILE})
    boost_add_test(${test} COMPILE)
  endforeach(test)

  foreach(test ${TEST_COMPILE_FAIL})
    boost_add_test(${test} COMPILE FAIL)
  endforeach(test)

  foreach(test ${TEST_LINK})
    boost_add_test(${test} LINK
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)

  foreach(test ${TEST_LINK_FAIL})
    boost_add_test(${test} LINK FAIL
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)

  foreach(test ${TEST_RUN})
    boost_add_test(${test} RUN
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)

  foreach(test ${TEST_RUN_FAIL})
    boost_add_test(${test} RUN FAIL
      LINK_BOOST_LIBRARIES ${TEST_LINK_BOOST_LIBRARIES}
      LINK_LIBRARIES ${TEST_LINK_LIBRARIES}
      )
  endforeach(test)
endfunction(boost_test_suite)
