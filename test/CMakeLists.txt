##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


boost_add_test(fail_compile FAIL COMPILE )
boost_add_test(fail_link    FAIL LINK    )
boost_add_test(fail_run     FAIL RUN     )

boost_add_test(succeed_compile COMPILE succeed.cpp )
boost_add_test(succeed_link    LINK    succeed.cpp )
boost_add_test(succeed_run     RUN     succeed.cpp )

return()

# positive compile
add_library(succeed_compile STATIC succeed.cpp)
add_custom_command(TARGET succeed_compile PRE_LINK
  COMMAND ${CMAKE_COMMAND} -E echo "true" >"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/succeed_compile.dir/link.txt"
  )
add_custom_command(TARGET succeed_compile POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:succeed_compile>"
  )

# negative compile
add_library(fail_compile STATIC fail_compile.cpp)
add_custom_command(TARGET fail_compile PRE_LINK
  COMMAND ${CMAKE_COMMAND} -E echo "true" >"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/fail_compile.dir/link.txt"
  )
#add_custom_command(TARGET succeed_compile POST_BUILD
#  COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:fail_compile>"
#  )
add_dependencies(fail_compile revert)
set_target_properties(fail_compile PROPERTIES
  RULE_LAUNCH_COMPILE "${revert_location}"
  )
set_source_files_properties(fail_compile.cpp PROPERTIES
  KEEP_EXTENSION ON
  )
add_custom_command(TARGET fail_compile POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/fail_compile.dir/fail_compile.cpp"
  COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:fail_compile>"
  )


# positive link
add_executable(succeed_link succeed.cpp)

# negative link
add_executable(fail_link fail_link.cpp)
add_dependencies(fail_link revert)
set_target_properties(fail_link PROPERTIES
  RULE_LAUNCH_LINK "${revert_location}"
  )
add_custom_command(TARGET fail_link POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E touch "$<TARGET_FILE:fail_link>"
  )


# positive run
add_executable(succeed_run succeed.cpp)
add_custom_command(TARGET succeed_run POST_BUILD
  COMMAND ${CMAKE_COMMAND} -DEXECUTABLE="$<TARGET_FILE:succeed_run>" -P ${CMAKE_CURRENT_SOURCE_DIR}/test_launch.cmake
  )

# negative run
add_executable(fail_run fail_run.cpp)
add_custom_command(TARGET fail_run POST_BUILD
  COMMAND ${CMAKE_COMMAND} -DFAIL=ON -DEXECUTABLE="$<TARGET_FILE:fail_run>" -P ${CMAKE_CURRENT_SOURCE_DIR}/test_launch.cmake
  )

