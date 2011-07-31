################################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>                   #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

include(CMakeParseArguments)

if(NOT TARGET boost_test_invert)
  set(boost_test_invert_source "${CMAKE_BINARY_DIR}/boost_test_invert.cpp")
  file(WRITE "${boost_test_invert_source}.in"
    "#include <cstdlib>\n"
    "#include <sstream>\n"
    "int main(int argc, char* argv[]) {\n"
    "  std::stringstream stream;\n"
    "  for (int i = 1; i < argc; ++i)\n"
    "    stream << '\"' << argv[i] << '\"' << ' ';\n"
    "  return !system(stream.str().c_str());\n"
    "}\n"
    )
  configure_file("${boost_test_invert_source}.in" "${boost_test_invert_source}" COPYONLY)
  add_executable(boost_test_invert EXCLUDE_FROM_ALL ${boost_test_invert_source})
endif(NOT TARGET boost_test_invert)

set(boost_test_run_script "${CMAKE_CURRENT_LIST_DIR}/test_launch.cmake")

function(boost_test_impl_cmake name)
  cmake_parse_arguments(TEST "COMPILE;LINK;MODULE;RUN;FAIL" ""
    "ARGS;LINK_BOOST_LIBRARIES;LINK_LIBRARIES" ${ARGN})

  set(target "${BOOST_CURRENT}-test-${name}")

  # If no sources are specified, use the name of the test.cpp
  if(TEST_UNPARSED_ARGUMENTS)
    set(sources ${TEST_UNPARSED_ARGUMENTS})
  else(TEST_UNPARSED_ARGUMENTS)
    set(sources ${name})
  endif(TEST_UNPARSED_ARGUMENTS)

  if(TEST_COMPILE)
    add_library(${target} STATIC EXCLUDE_FROM_ALL ${sources})
    set(object_dir "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${target}.dir")

    # make the link step always suceed
    add_custom_command(TARGET ${target} PRE_LINK
      COMMAND ${CMAKE_COMMAND} -E echo "true" >"${object_dir}/link.txt"
      )

    if(TEST_FAIL)
      add_dependencies(${target} boost_test_invert)
      get_target_property(invert boost_test_invert LOCATION)
      set_target_properties(${target} PROPERTIES
        RULE_LAUNCH_COMPILE "${invert}"
        )
      set_source_files_properties(${sources} PROPERTIES
        KEEP_EXTENSION ON
        )

      set(object_files)
      foreach(file ${sources})
        if(NOT file MATCHES "[.]cpp$")
          set(file "${file}.cpp")
        endif(NOT file MATCHES "[.]cpp$")
        list(APPEND object_files "${object_dir}/${file}")
      endforeach(file)

      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E touch ${object_files}
        COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:${target}>"
        )
    else(TEST_FAIL)
      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:${target}>"
        )
    endif(TEST_FAIL)
  endif(TEST_COMPILE)

  if(TEST_LINK OR TEST_RUN)
    add_executable(${target} EXCLUDE_FROM_ALL ${sources})
  elseif(TEST_MODULE)
    add_library(${target} MODULE EXCLUDE_FROM_ALL ${sources})
  endif()

  if(TEST_LINK OR TEST_MODULE OR TEST_RUN)
    boost_link_libraries(${target} STATIC
      ${TEST_LINK_BOOST_LIBRARIES}
      )
    target_link_libraries(${target}
      ${TEST_LINK_LIBRARIES}
      )
  endif(TEST_LINK OR TEST_MODULE OR TEST_RUN)

  if(TEST_FAIL AND (TEST_LINK OR TEST_MODULE))
    add_dependencies(${target} boost_test_invert)
    get_target_property(invert boost_test_invert LOCATION)

    set_target_properties(${target} PROPERTIES
      RULE_LAUNCH_LINK "${invert}"
      )
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:${target}>"
      )
  endif(TEST_FAIL AND (TEST_LINK OR TEST_MODULE))

  if(TEST_RUN)
    set(test_run_args
      "-DEXECUTABLE=$<TARGET_FILE:${target}>"
      "-DARGS=${TEST_ARGS}"
      )
    if(TEST_FAIL)
      list(APPEND test_run_args "-DFAIL=ON")
    endif(TEST_FAIL)

    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} ${test_run_args} -P "${boost_test_run_script}"
      )
  endif(TEST_RUN)

  set(project_test "${BOOST_CURRENT}-test")
  if(NOT TARGET ${project_test})
    add_custom_target(${project_test})
    if(TARGET test)
      add_dependencies(test ${project_test})
    endif(TARGET test)
  endif(NOT TARGET ${project_test})
  add_dependencies(${project_test} ${target})

endfunction(boost_test_impl_cmake)
