################################################################################
# Copyright (C) 2012 Daniel Pfeifer <daniel@pfeifer-mail.de>                   #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################


if(NOT TARGET boost_cmake_fail)
  add_executable(boost_cmake_fail EXCLUDE_FROM_ALL
    "${CMAKE_CURRENT_LIST_DIR}/fail.cpp"
    )
  set_target_properties(boost_cmake_fail PROPERTIES
    OUTPUT_NAME fail
    )
endif(NOT TARGET boost_cmake_fail)


set(__boost_test_python "${CMAKE_CURRENT_LIST_DIR}/test_python.cmake")


macro(__boost_add_test_compile fail)
  get_filename_component(name ${FILE} NAME_WE)

  get_filename_component(SOURCE ${FILE} ABSOLUTE)
  set(OBJECT ${name}.o)

  string(REGEX REPLACE "<([A-Z_]+)>" "@\\1@" compile
    "${CMAKE_CXX_COMPILE_OBJECT}"
    )
  string(CONFIGURE "${compile}" compile @ONLY)
  separate_arguments(compile)

  add_custom_command(OUTPUT ${OBJECT}
    COMMAND ${CMAKE_COMMAND} -E remove ${OBJECT}
  # COMMAND ${CMAKE_COMMAND} -E echo ${compile}
    COMMAND ${EXIT_${fail}_RULE} ${compile}
    COMMAND ${CMAKE_COMMAND} -E touch ${OBJECT}
    DEPENDS ${FILE}
    COMMENT "compile test: ${name}"
    )
  list(APPEND TEST_OUTPUT ${OBJECT})
endmacro(__boost_add_test_compile)


macro(__boost_add_test_link link_rule fail)
  get_filename_component(name ${FILE} NAME_WE)

  get_filename_component(SOURCE ${FILE} ABSOLUTE)
  set(TARGET ${name}_ok)
  set(OBJECT ${name}.o)
  set(OBJECTS ${OBJECT})

  string(REGEX REPLACE "<([A-Z_]+)>" "@\\1@" compile
    "${CMAKE_CXX_COMPILE_OBJECT}"
    )
  string(REGEX REPLACE "<([A-Z_]+)>" "@\\1@" link
    "${link_rule}"
    )
  string(CONFIGURE "${compile}" compile @ONLY)
  string(CONFIGURE "${link}" link @ONLY)
  separate_arguments(compile)
  separate_arguments(link)

  add_custom_command(OUTPUT ${TARGET}
    COMMAND ${CMAKE_COMMAND} -E remove ${TARGET}
    COMMAND ${CMAKE_COMMAND} -E echo ${compile}
    COMMAND ${CMAKE_COMMAND} -E echo ${link}
    COMMAND ${compile}
    COMMAND ${EXIT_${fail}_RULE} ${link}
    COMMAND ${CMAKE_COMMAND} -E touch ${TARGET}
    DEPENDS ${FILE}
    COMMENT "link test: ${name}"
    )
  list(APPEND TEST_OUTPUT ${TARGET})
endmacro(__boost_add_test_link)


macro(__boost_add_test_run driver fail)
  get_filename_component(name ${FILE} NAME_WE)
  add_custom_command(OUTPUT ${name}_ok
    COMMAND ${CMAKE_COMMAND} -E remove ${name}_ok
    COMMAND ${EXIT_${fail}_RULE} $<TARGET_FILE:${driver}> ${name}
    COMMAND ${CMAKE_COMMAND} -E touch ${name}_ok
    DEPENDS ${FILE}
    COMMENT "Running test: ${name}"
    )
  list(APPEND TEST_OUTPUT ${name}_ok)
endmacro(__boost_add_test_run)


macro(__boost_add_test_python fail)
  get_filename_component(name ${FILE} NAME_WE)

  set(module "${PROJECT_NAME}-test-${name}-ext")
  add_library(${module} MODULE EXCLUDE_FROM_ALL ${FILE})
  target_link_libraries(${module} ${TEST_LINK_LIBRARIES})
  set_target_properties(${module} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    OUTPUT_NAME "${name}_ext"
    PREFIX ""
    )

  add_custom_command(OUTPUT ${name}_ok
    COMMAND ${CMAKE_COMMAND} -E remove ${name}_ok
    COMMAND ${CMAKE_COMMAND}
      -D "PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR}"
      -D "PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}"
      -D "PYTHON_FILE=${CMAKE_CURRENT_SOURCE_DIR}/${name}.py"
      -D "FAIL=${fail}"
      -P "${__boost_test_python}"
    COMMAND ${CMAKE_COMMAND} -E touch ${name}_ok
    DEPENDS ${FILE} ${module}
    COMMENT "Running test: ${name}"
    )
  list(APPEND TEST_OUTPUT ${name}_ok)
endmacro(__boost_add_test_python)
