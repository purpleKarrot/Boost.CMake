##########################################################################
# Copyright (C) 2007-2009 Douglas Gregor <doug.gregor@gmail.com>         #
# Copyright (C) 2007-2009 Troy Straszheim <troy@resophonic.com>          #
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

include(CMakeParseArguments)

# use this function as a replacement for 'project' in boost projects.
function(boost_project name)
  cmake_parse_arguments(PROJ "" "" "AUTHORS;DESCRIPTION;DEPENDS" ${ARGN})
  set(BOOST_PROJECT_NAME ${name} PARENT_SCOPE)
  project(${name})
endfunction(boost_project)


function(boost_link_libraries target boost_libs link_libs)
  foreach(lib ${boost_libs})
    list(APPEND link_libs "${lib}-shared") # TODO: proper variant
  endforeach(lib)
  target_link_libraries(${target} ${link_libs})
endfunction(boost_link_libraries)

# Creates a Boost library target that generates a compiled library
# (.a, .lib, .dll, .so, etc) from source files.
#
#   boost_add_library(name SHARED
#     SOURCES
#       source1
#       source2
#       ...
#     LINK_BOOST_LIBRARIES
#       system
#     LINK_LIBRARIES
#       ...
#     )
#
# where "name" is the name of library (e.g. "regex", not "boost_regex")
# and source1, source2, etc. are the source files used
# to build the library, e.g., cregex.cpp.
#
# This macro has a variety of options that affect its behavior. In
# several cases, we use the placeholder "feature" in the option name
# to indicate that there are actually several different kinds of
# options, each referring to a different build feature, e.g., shared
# libraries, multi-threaded, debug build, etc. For a complete listing
# of these features, please refer to the CMakeLists.txt file in the
# root of the Boost distribution, which defines the set of features
# that will be used to build Boost libraries by default.
#
# The options that affect this macro's behavior are:
#
#   COMPILE_FLAGS: Provides additional compilation flags that will be
#   used when building all variants of the library. For example, one
#   might want to add "-DBOOST_SIGNALS_NO_LIB=1" through this option
#   (which turns off auto-linking for the Signals library while
#   building it).
#
#   feature_COMPILE_FLAGS: Provides additional compilation flags that
#   will be used only when building variants of the library that
#   include the given feature. For example,
#   MULTI_THREADED_COMPILE_FLAGS are additional flags that will be
#   used when building a multi-threaded variant, while
#   SHARED_COMPILE_FLAGS will be used when building a shared library
#   (as opposed to a static library).
#
#   LINK_FLAGS: Provides additional flags that will be passed to the
#   linker when linking each variant of the library. This option
#   should not be used to link in additional libraries; see LINK_LIBS
#   and DEPENDS.
#
#   feature_LINK_FLAGS: Provides additional flags that will be passed
#   to the linker when building variants of the library that contain a
#   specific feature, e.g., MULTI_THREADED_LINK_FLAGS. This option
#   should not be used to link in additional libraries; see
#   feature_LINK_LIBS.
#
#   LINK_LIBS: Provides additional libraries against which each of the
#   library variants will be linked. For example, one might provide
#   "expat" as options to LINK_LIBS, to state that each of the library
#   variants will link against the expat library binary. Use LINK_LIBS
#   for libraries external to Boost; for Boost libraries, use DEPENDS.
#
#   feature_LINK_LIBS: Provides additional libraries for specific
#   variants of the library to link against. For example,
#   MULTI_THREADED_LINK_LIBS provides extra libraries to link into
#   multi-threaded variants of the library.
#
#   DEPENDS: States that this Boost library depends on and links
#   against another Boost library. The arguments to DEPENDS should be
#   the unversioned name of the Boost library, such as
#   "boost_filesystem". Like LINK_LIBS, this option states that all
#   variants of the library being built will link against the stated
#   libraries. Unlike LINK_LIBS, however, DEPENDS takes particular
#   library variants into account, always linking the variant of one
#   Boost library against the same variant of the other Boost
#   library. For example, if the boost_mpi_python library DEPENDS on
#   boost_python, multi-threaded variants of boost_mpi_python will
#   link against multi-threaded variants of boost_python.
#
#   MODULE: This option states that, when building a shared library,
#   the shared library should be built as a module rather than a
#   normal shared library. Modules have special meaning and behavior
#   on some platforms, such as Mac OS X.
#
#   NO_feature: States that library variants containing a particular
#   feature should not be built. For example, passing
#   NO_SINGLE_THREADED suppresses generation of single-threaded
#   variants of this library.
#
#   EXTRA_VARIANTS: Specifies that extra variants of this library
#   should be built, based on the features listed. Each "variant" is a 
#   colon-separated list of features. For example, passing
#     EXTRA_VARIANTS "PYTHON_NODEBUG:PYTHON_DEBUG"
#   will result in the creation of an extra set of library variants,
#   some with the PYTHON_NODEBUG feature and some with the
#   PYTHON_DEBUG feature. 
#
#   FORCE_VARIANTS: This will force the build system to ALWAYS build this 
#   variant of the library not matter what variants are set.
#
# Example:
#   boost_add_library(boost_thread
#     SOURCES
#       barrier.cpp condition.cpp exceptions.cpp mutex.cpp once.cpp 
#       recursive_mutex.cpp thread.cpp tss_hooks.cpp tss_dll.cpp tss_pe.cpp 
#       tss.cpp xtime.cpp
#     SHARED_COMPILE_FLAGS "-DBOOST_THREAD_BUILD_DLL=1"
#     STATIC_COMPILE_FLAGS "-DBOOST_THREAD_BUILD_LIB=1"
#     NO_SINGLE_THREADED
#     )
function(boost_add_library name)
  cmake_parse_arguments(LIB
    "SHARED;STATIC" #;SINGLE_THREAD;MULTI_THREAD"
    "PCH"
    "SOURCES;LINK_BOOST_LIBRARIES;LINK_LIBRARIES"
    ${ARGN}
    )

  if(NOT LIB_SOURCES)
    set(LIB_SOURCES ${LIB_UNPARSED_ARGUMENTS})
  endif(NOT LIB_SOURCES)

  if(NOT LIB_SHARED AND NOT LIB_STATIC)
    set(LIB_SHARED ON)
    set(LIB_STATIC ON)
  endif(NOT LIB_SHARED AND NOT LIB_STATIC)

# if(NOT LIB_SINGLE_THREAD AND NOT LIB_MULTI_THREAD)
#   set(LIB_SINGLE_THREAD ON)
#   set(LIB_MULTI_THREAD  ON)
# endif(NOT LIB_SINGLE_THREAD AND NOT LIB_MULTI_THREAD)

  if(LIB_PCH)
    # TODO: support precompiled headers
  endif(LIB_PCH)

  set(targets)
  
  if(LIB_SHARED)
    add_library(${name}-shared SHARED ${LIB_SOURCES})
    boost_link_libraries(${name}-shared
      "${LIB_LINK_BOOST_LIBRARIES}" "${LIB_LINK_LIBRARIES}")
	set_property(TARGET ${name}-shared
	  APPEND PROPERTY COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK=1")
    list(APPEND targets ${name}-shared)
  endif(LIB_SHARED)

  if(LIB_STATIC)
    add_library(${name}-static STATIC ${LIB_SOURCES})
    # TODO: boost_link_libraries
    list(APPEND targets ${name}-static)
  endif(LIB_STATIC)

# set_target_properties(${name} PROPERTIES
#   #DEFINE_SYMBOL "${name}_EXPORT"
#   PREFIX libboost_ # or boost_ for dlls  # TODO: can we set this globally?
#   )

  set_property(TARGET ${targets} PROPERTY FOLDER "${BOOST_PROJECT_NAME}")

  install(TARGETS ${targets}
    ARCHIVE DESTINATION lib COMPONENT ${CMAKE_PROJECT_NAME}-dev
    LIBRARY DESTINATION lib COMPONENT ${CMAKE_PROJECT_NAME}-dev
    RUNTIME DESTINATION bin COMPONENT ${CMAKE_PROJECT_NAME}-lib
    )
endfunction(boost_add_library)


# Creates a new executable from source files.
#
#   boost_add_executable(exename
#                        source1 source2 ...
#                        [COMPILE_FLAGS compileflags]
#                        [feature_COMPILE_FLAGS compileflags]
#                        [LINK_FLAGS linkflags]
#                        [feature_LINK_FLAGS linkflags]
#                        [LINK_LIBS linklibs]
#                        [feature_LINK_LIBS linklibs]
#                        [DEPENDS libdepend1 libdepend2 ...]
#                        [feature]
#                        [NO_INSTALL])
#
# where exename is the name of the executable (e.g., "wave").  source1,
# source2, etc. are the source files used to build the executable, e.g.,
# cpp.cpp. If no source files are provided, "exename.cpp" will be
# used.
#
# This macro has a variety of options that affect its behavior. In
# several cases, we use the placeholder "feature" in the option name
# to indicate that there are actually several different kinds of
# options, each referring to a different build feature, e.g., shared
# libraries, multi-threaded, debug build, etc. For a complete listing
# of these features, please refer to the CMakeLists.txt file in the
# root of the Boost distribution, which defines the set of features
# that will be used to build Boost libraries by default.
#
# The options that affect this macro's behavior are:
#
#   COMPILE_FLAGS: Provides additional compilation flags that will be
#   used when building the executable.
#
#   feature_COMPILE_FLAGS: Provides additional compilation flags that
#   will be used only when building the executable with the given
#   feature (e.g., SHARED_COMPILE_FLAGS when we're linking against
#   shared libraries). Note that the set of features used to build the
#   executable depends both on the arguments given to
#   boost_add_executable (see the "feature" argument description,
#   below) and on the user's choice of variants to build.
#
#   LINK_FLAGS: Provides additional flags that will be passed to the
#   linker when linking the executable. This option should not be used
#   to link in additional libraries; see LINK_LIBS and DEPENDS.
#
#   feature_LINK_FLAGS: Provides additional flags that will be passed
#   to the linker when linking the executable with the given feature
#   (e.g., MULTI_THREADED_LINK_FLAGS when we're linking a
#   multi-threaded executable).
#
#   LINK_LIBS: Provides additional libraries against which the
#   executable will be linked. For example, one might provide "expat"
#   as options to LINK_LIBS, to state that the executable will link
#   against the expat library binary. Use LINK_LIBS for libraries
#   external to Boost; for Boost libraries, use DEPENDS.
#
#   feature_LINK_LIBS: Provides additional libraries to link against
#   when linking an executable built with the given feature. 
#
#   DEPENDS: States that this executable depends on and links against
#   a Boostlibrary. The arguments to DEPENDS should be the unversioned
#   name of the Boost library, such as "boost_filesystem". Like
#   LINK_LIBS, this option states that the executable will link
#   against the stated libraries. Unlike LINK_LIBS, however, DEPENDS
#   takes particular library variants into account, always linking to
#   the appropriate variant of a Boost library. For example, if the
#   MULTI_THREADED feature was requested in the call to
#   boost_add_executable, DEPENDS will ensure that we only link
#   against multi-threaded libraries.
#
#   feature: States that the executable should always be built using a
#   given feature, e.g., SHARED linking (against its libraries) or
#   MULTI_THREADED (for multi-threaded builds). If that feature has
#   been turned off by the user, the executable will not build.
#
#   NO_INSTALL: Don't install this executable with the rest of Boost.
#
#   OUTPUT_NAME: If you want the executable to be generated somewhere
#   other than the binary directory, pass the path (including
#   directory and file name) via the OUTPUT_NAME parameter.
#
# Example:
#   boost_add_executable(wave cpp.cpp 
#     DEPENDS boost_wave boost_program_options boost_filesystem 
#             boost_serialization
#     )
macro(boost_add_executable2 EXENAME)
  # Note: ARGS is here to support the use of boost_add_executable in
  # the testing code.
  parse_arguments(THIS_EXE
    "DEPENDS;COMPILE_FLAGS;LINK_FLAGS;LINK_LIBS;OUTPUT_NAME;ARGS;TARGET_PREFIX;${BOOST_ADD_ARG_NAMES}"
    "NO_INSTALL;${BOOST_ADDEXE_OPTION_NAMES}"
    ${ARGN}
    )

  # Determine the list of sources
  if(THIS_EXE_DEFAULT_ARGS)
    set(THIS_EXE_SOURCES ${THIS_EXE_DEFAULT_ARGS})
  else()
    set(THIS_EXE_SOURCES ${EXENAME}.cpp)
  endif()

  # Whether we can build both debug and release versions of this
  # executable within an IDE (based on the selected configuration
  # type).
  set(THIS_EXE_DEBUG_AND_RELEASE FALSE)
  
  # Compute the variant that will be used to build this executable,
  # taking into account both the requested features passed to
  # boost_add_executable and what options the user has set.
  boost_select_variant(${EXENAME} THIS_EXE)

  # message("THIS_EXE_VARIANT=${THIS_EXE_VARIANT}")
  # Possibly hyphenate exe's name
  if (THIS_PROJECT_IS_TOOL)
    set(THIS_EXE_NAME ${THIS_EXE_TARGET_PREFIX}${EXENAME})
  else()
    set(THIS_EXE_NAME ${BOOST_PROJECT_NAME}-${THIS_EXE_TARGET_PREFIX}${EXENAME})
  endif()

  # Compute the name of the variant targets that we'll be linking
  # against. We'll use this to link against the appropriate
  # dependencies. For IDE targets where we can build both debug and
  # release configurations, create DEBUG_ and RELEASE_ versions of
  # the macros.
  if (THIS_EXE_DEBUG_AND_RELEASE)
    boost_library_variant_target_name(RELEASE ${THIS_EXE_VARIANT})
    set(RELEASE_VARIANT_TARGET_NAME "${VARIANT_TARGET_NAME}")
    boost_library_variant_target_name(DEBUG ${THIS_EXE_VARIANT})
    set(DEBUG_VARIANT_TARGET_NAME "${VARIANT_TARGET_NAME}")
  else (THIS_EXE_DEBUG_AND_RELEASE)
    boost_library_variant_target_name(${THIS_EXE_VARIANT})
  endif (THIS_EXE_DEBUG_AND_RELEASE)

  # Compute the actual set of library dependencies, based on the
  # variant name we computed above. The RELEASE and DEBUG versions
  # only apply when THIS_EXE_DEBUG_AND_RELEASE.
  set(THIS_EXE_ACTUAL_DEPENDS)
  set(THIS_EXE_RELEASE_ACTUAL_DEPENDS)
  set(THIS_EXE_DEBUG_ACTUAL_DEPENDS)
  set(DEPENDENCY_FAILURES "")
  foreach(LIB ${THIS_EXE_DEPENDS})
    if (LIB MATCHES ".*-.*")
      # The user tried to state exactly which variant to use. Just
      # propagate the dependency and hope that s/he was
      # right. Eventually, this should at least warn, because it is
      # not the "proper" way to do things
      list(APPEND THIS_EXE_ACTUAL_DEPENDS ${LIB})
      list(APPEND THIS_EXE_RELEASE_ACTUAL_DEPENDS ${LIB})
      list(APPEND THIS_EXE_DEBUG_ACTUAL_DEPENDS ${LIB})
      dependency_check(${LIB})
    else ()
      # The user has given the name of just the library target,
      # e.g., "boost_filesystem". We add on the appropriate variant
      # name(s).
      list(APPEND THIS_EXE_ACTUAL_DEPENDS "${LIB}${VARIANT_TARGET_NAME}")
      list(APPEND THIS_EXE_RELEASE_ACTUAL_DEPENDS "${LIB}${RELEASE_VARIANT_TARGET_NAME}")
      list(APPEND THIS_EXE_DEBUG_ACTUAL_DEPENDS "${LIB}${DEBUG_VARIANT_TARGET_NAME}")
      if(THIS_EXE_RELEASE_AND_DEBUG)
    dependency_check("${LIB}${RELEASE_VARIANT_TARGET_NAME}")
    dependency_check("${LIB}${DEBUG_VARIANT_TARGET_NAME}")
      else()
    dependency_check("${LIB}${VARIANT_TARGET_NAME}")
      endif()
    endif ()
  endforeach()

  set(THIS_EXE_OKAY TRUE)

  if(DEPENDENCY_FAILURES)
    set(THIS_EXE_OKAY FALSE)
    # separate_arguments(DEPENDENCY_FAILURES)
    colormsg(HIRED "    ${THIS_EXE_NAME}" RED "(executable) disabled due to dependency failures:")
    colormsg("      ${DEPENDENCY_FAILURES}")
  endif()

  trace(THIS_EXE_VARIANT)
  trace(THIS_EXE_OUTPUT_NAME)
  if (THIS_EXE_VARIANT AND (NOT DEPENDENCY_FAILURES))
    # It's okay to build this executable

    add_executable(${THIS_EXE_NAME} ${THIS_EXE_SOURCES})
    
    # Set the various compilation and linking flags
    set_target_properties(${THIS_EXE_NAME} PROPERTIES
      COMPILE_FLAGS "${THIS_EXE_COMPILE_FLAGS}"
      LINK_FLAGS "${THIS_EXE_LINK_FLAGS}"
      LABELS "${BOOST_PROJECT_NAME}"
      )

    # For IDE generators where we can build both debug and release
    # configurations, pass the configurations along separately.
    if (THIS_EXE_DEBUG_AND_RELEASE)
      set_target_properties(${THIS_EXE_NAME} PROPERTIES
        COMPILE_FLAGS_DEBUG "${DEBUG_COMPILE_FLAGS} ${THIS_EXE_COMPILE_FLAGS}"
        COMPILE_FLAGS_RELEASE "${RELEASE_COMPILE_FLAGS} ${THIS_EXE_COMPILE_FLAGS}"
        LINK_FLAGS_DEBUG "${DEBUG_LINK_FLAGS} ${DEBUG_EXE_LINK_FLAGS} ${THIS_EXE_LINK_FLAGS}"
        LINK_FLAGS_RELEASE "${RELEASE_LINK_FLAGS} ${RELEASE_EXE_LINK_FLAGS} ${THIS_EXE_LINK_FLAGS}"
        )
    endif (THIS_EXE_DEBUG_AND_RELEASE)

    # If the user gave an output name, use it.
    if(THIS_EXE_OUTPUT_NAME)
      set_target_properties(${THIS_EXE_NAME} PROPERTIES
        OUTPUT_NAME ${THIS_EXE_OUTPUT_NAME}
        )
    endif()

    # Link against the various libraries 
    if (THIS_EXE_DEBUG_AND_RELEASE)
      # Configuration-agnostic libraries
      target_link_libraries(${THIS_EXE_NAME} ${THIS_EXE_LINK_LIBS})
      
      foreach(LIB ${THIS_EXE_RELEASE_ACTUAL_DEPENDS} ${THIS_EXE_RELEASE_LINK_LIBS})     
        target_link_libraries(${THIS_EXE_NAME} optimized ${LIB})
      endforeach(LIB ${THIS_EXE_RELEASE_ACTUAL_DEPENDS} ${THIS_EXE_RELEASE_LINK_LIBS})     
      
      foreach(LIB ${THIS_EXE_DEBUG_ACTUAL_DEPENDS} ${THIS_EXE_DEBUG_LINK_LIBS})     
        target_link_libraries(${THIS_EXE_NAME} debug ${LIB})
      endforeach(LIB ${THIS_EXE_DEBUG_ACTUAL_DEPENDS} ${THIS_EXE_DEBUG_LINK_LIBS})     

    else (THIS_EXE_DEBUG_AND_RELEASE)
      target_link_libraries(${THIS_EXE_NAME} 
        ${THIS_EXE_ACTUAL_DEPENDS} 
        ${THIS_EXE_LINK_LIBS})
    endif (THIS_EXE_DEBUG_AND_RELEASE)

  endif ()
endmacro(boost_add_executable2)

function(boost_add_executable name)
  cmake_parse_arguments(EXE "" ""
    "SOURCES;LINK_BOOST_LIBRARIES;LINK_LIBRARIES" ${ARGN})

  add_executable(${name} ${EXE_SOURCES})
  boost_link_libraries(${name} "${EXE_LINK_BOOST_LIBRARIES}" "${EXE_LINK_LIBRARIES}")
  set_property(TARGET ${name} PROPERTY FOLDER "${BOOST_PROJECT_NAME}")
endfunction(boost_add_executable)


#
#  Macro for building boost.python extensions
#
macro(boost_python_extension MODULE_NAME)
  parse_arguments(BPL_EXT  "" "" ${ARGN})

  if (WIN32)
    set(extlibtype SHARED)
  else()
    set(extlibtype MODULE)
  endif()

  boost_add_single_library(${MODULE_NAME}
    ${BPL_EXT_DEFAULT_ARGS}
    ${extlibtype}
    LINK_LIBS ${PYTHON_LIBRARIES}
    DEPENDS boost_python
    SHARED
    MULTI_THREADED
    )

  if(WIN32)
    set_target_properties(${VARIANT_LIBNAME} PROPERTIES
      OUTPUT_NAME "${MODULE_NAME}"
      PREFIX ""
      SUFFIX .pyd
      IMPORT_SUFFIX .pyd
      )
  else()
    set_target_properties(${VARIANT_LIBNAME} PROPERTIES
      OUTPUT_NAME "${MODULE_NAME}"
      PREFIX ""
      )
  endif()
endmacro(boost_python_extension)

function(boost_add_python_extension)
endfunction(boost_add_python_extension)
