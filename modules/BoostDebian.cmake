##########################################################################
# Copyright (C) 2010-2011 Daniel Pfeifer <daniel@pfeifer-mail.de>        #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

find_program(DPKG_BUILDPACKAGE dpkg-buildpackage)
find_program(DPUT dput)

if(NOT DPKG_BUILDPACKAGE OR NOT DPUT)
  return()
endif()

# debian policy enforce lower case for package name
# Package: (mandatory)
IF(NOT CPACK_DEBIAN_PACKAGE_NAME)
  STRING(TOLOWER
    "${CPACK_PACKAGE_NAME}${CPACK_PACKAGE_VERSION}"
    CPACK_DEBIAN_PACKAGE_NAME
    )
ENDIF(NOT CPACK_DEBIAN_PACKAGE_NAME)

# Section: (recommended)
IF(NOT CPACK_DEBIAN_PACKAGE_SECTION)
  SET(CPACK_DEBIAN_PACKAGE_SECTION "devel")
ENDIF(NOT CPACK_DEBIAN_PACKAGE_SECTION)

# Priority: (recommended)
IF(NOT CPACK_DEBIAN_PACKAGE_PRIORITY)
  SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
ENDIF(NOT CPACK_DEBIAN_PACKAGE_PRIORITY)

file(STRINGS "${CPACK_PACKAGE_DESCRIPTION_FILE}" DESC_LINES)
foreach(LINE ${DESC_LINES})
  set(DEB_LONG_DESCRIPTION "${DEB_LONG_DESCRIPTION} ${LINE}\n")
endforeach(LINE)

set(debian_dir "${CMAKE_BINARY_DIR}/_Debian/${CPACK_DEBIAN_PACKAGE_NAME}/debian")

##########################################################################
# debian/control                                                         #
##########################################################################

set(debian_control ${debian_dir}/control)
list(APPEND CPACK_DEBIAN_BUILD_DEPENDS cmake)
list(REMOVE_DUPLICATES CPACK_DEBIAN_BUILD_DEPENDS)
list(SORT CPACK_DEBIAN_BUILD_DEPENDS)
string(REPLACE ";" ", " build_depends "${CPACK_DEBIAN_BUILD_DEPENDS}")
file(WRITE ${debian_control}
  "Source: ${CPACK_DEBIAN_PACKAGE_NAME}\n"
  "Section: ${CPACK_DEBIAN_PACKAGE_SECTION}\n"
  "Priority: ${CPACK_DEBIAN_PACKAGE_PRIORITY}\n"
  "Maintainer: ${CPACK_PACKAGE_CONTACT}\n"
  "Build-Depends: ${build_depends}\n"
  "Standards-Version: 3.9.1\n"
  "Homepage: ${CPACK_PACKAGE_VENDOR}\n"
  )

foreach(component ${CPACK_COMPONENTS_ALL})
  string(TOUPPER "${component}" COMPONENT)
  set(display_name "${CPACK_COMPONENT_${COMPONENT}_DISPLAY_NAME}")
  set(description "${CPACK_COMPONENT_${COMPONENT}_DESCRIPTION}")

  set(deb_depends ${CPACK_COMPONENT_${COMPONENT}_DEBIAN_DEPENDS})
  foreach(dep ${CPACK_COMPONENT_${COMPONENT}_DEPENDS})
    string(TOUPPER "${dep}" DEP)
    list(APPEND deb_depends ${CPACK_COMPONENT_${DEP}_DEB_PACKAGE})
  endforeach(dep)
  string(REPLACE ";" ", " deb_depends "${deb_depends}")

  if(CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)
    set(architecture all)
  else(CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)
    set(architecture any)
  endif(CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)

  file(APPEND ${debian_control}
    "\n"
    "Package: ${CPACK_COMPONENT_${COMPONENT}_DEB_PACKAGE}\n"
    "Architecture: ${architecture}\n"
    "Depends: ${deb_depends}\n"
    "Description: Boost.${display_name}\n"
    "${DEB_LONG_DESCRIPTION}"
    " .\n"
    " ${description}\n"
    )
endforeach(component)

##########################################################################
# debian/copyright                                                       #
##########################################################################

set(debian_copyright ${debian_dir}/copyright)
configure_file(${CPACK_RESOURCE_FILE_LICENSE} ${debian_copyright} COPYONLY)

##########################################################################
# debian/rules                                                           #
##########################################################################

set(debian_rules ${debian_dir}/rules)
file(WRITE ${debian_rules}
  "#!/usr/bin/make -f\n"
  "\n"
  "DEBUG = debug_build\n"
  "RELEASE = release_build\n"
  "CFLAGS =\n"
  "CPPFLAGS =\n"
  "CXXFLAGS =\n"
  "FFLAGS =\n"
  "LDFLAGS =\n"
  "\n"
  "configure-debug:\n"
  "	cmake -E make_directory $(DEBUG)\n"
  "	cd $(DEBUG); cmake -DCMAKE_BUILD_TYPE=Debug -DBOOST_DEBIAN_PACKAGES=TRUE ..\n"
  "	touch configure-debug\n"
  "\n"
  "configure-release:\n"
  "	cmake -E make_directory $(RELEASE)\n"
  "	cd $(RELEASE); cmake -DCMAKE_BUILD_TYPE=Release -DBOOST_DEBIAN_PACKAGES=TRUE ..\n"
  "	touch configure-release\n"
  "\n"
  "build: build-arch\n" # build-indep
  "\n"
  "build-arch: configure-debug configure-release\n"
  "	$(MAKE) --no-print-directory -C $(DEBUG) preinstall\n"
  "	$(MAKE) --no-print-directory -C $(RELEASE) preinstall\n"
  "	touch build-arch\n"
  "\n"
  "build-indep: configure-release\n"
  "	$(MAKE) --no-print-directory -C $(RELEASE) documentation\n"
  "	touch build-indep\n"
  "\n"
  "binary: binary-arch binary-indep\n"
  "\n"
  "binary-arch: build-arch\n"
  )

foreach(component ${CPACK_COMPONENTS_ALL})
  string(TOUPPER "${component}" COMPONENT)
  if(NOT CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)
    set(path debian/${component})
    file(APPEND ${debian_rules}
      "	cd $(DEBUG); cmake -DCOMPONENT=${component} -DCMAKE_INSTALL_PREFIX=../${path}/usr -P cmake_install.cmake\n"
      "	cd $(RELEASE); cmake -DCOMPONENT=${component} -DCMAKE_INSTALL_PREFIX=../${path}/usr -P cmake_install.cmake\n"
      "	cmake -E make_directory ${path}/DEBIAN\n"
      "	dpkg-gencontrol -p${CPACK_COMPONENT_${COMPONENT}_DEB_PACKAGE} -P${path}\n"
      "	dpkg --build ${path} ..\n"
      )
  endif(NOT CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)
endforeach(component)

file(APPEND ${debian_rules}
  "\n"
  "binary-indep: build-indep\n"
  )

foreach(component ${CPACK_COMPONENTS_ALL})
  string(TOUPPER "${component}" COMPONENT)
  if(CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)
    set(path debian/${component})
    file(APPEND ${debian_rules}
      "	cd $(DEBUG); cmake -DCOMPONENT=${component} -DCMAKE_INSTALL_PREFIX=../${path}/usr -P cmake_install.cmake\n"
      "	cd $(RELEASE); cmake -DCOMPONENT=${component} -DCMAKE_INSTALL_PREFIX=../${path}/usr -P cmake_install.cmake\n"
      "	cmake -E make_directory ${path}/DEBIAN\n"
      "	dpkg-gencontrol -p${CPACK_COMPONENT_${COMPONENT}_DEB_PACKAGE} -P${path}\n"
      "	dpkg --build ${path} ..\n"
      )
  endif(CPACK_COMPONENT_${COMPONENT}_BINARY_INDEP)
endforeach(component)

file(APPEND ${debian_rules}
  "\n"
  "clean:\n"
  "	cmake -E remove_directory $(DEBUG)\n"
  "	cmake -E remove_directory $(RELEASE)\n"
  "	cmake -E remove configure-debug configure-release build-arch build-indep\n"
  "\n"
  ".PHONY: binary binary-arch binary-indep clean\n"
  )

execute_process(COMMAND chmod +x ${debian_rules})

##########################################################################
# debian/compat                                                          #
##########################################################################

file(WRITE ${debian_dir}/compat "7")

##########################################################################
# debian/source/format                                                   #
##########################################################################

file(WRITE ${debian_dir}/source/format "3.0 (quilt)")

##########################################################################
# debian/changelog                                                       #
##########################################################################

set(debian_changelog ${debian_dir}/changelog)
execute_process(COMMAND date -R OUTPUT_VARIABLE DATE_TIME)
#execute_process(COMMAND date +"%a, %d %b %Y %H:%M:%S %z" OUTPUT_VARIABLE DATE_TIME)
file(WRITE ${debian_changelog}
  "${CPACK_DEBIAN_PACKAGE_NAME} (${CPACK_PACKAGE_VERSION}) unstable; urgency=low\n\n"
  "  * Package built with CMake\n\n"
  " -- ${CPACK_PACKAGE_CONTACT}  ${DATE_TIME}"
  )

##########################################################################
# .orig.tar.gz                                                           #
##########################################################################

execute_process(COMMAND date +%y%m%d
  OUTPUT_VARIABLE day_suffix
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

set(package_file_name "${CPACK_DEBIAN_PACKAGE_NAME}_${day_suffix}")

file(WRITE "${CMAKE_BINARY_DIR}/_Debian/cpack.cmake"
  "set(CPACK_GENERATOR TGZ)\n"
  "set(CPACK_PACKAGE_NAME \"${CPACK_DEBIAN_PACKAGE_NAME}\")\n"
  "set(CPACK_PACKAGE_VERSION \"${CPACK_PACKAGE_VERSION}\")\n"
  "set(CPACK_PACKAGE_FILE_NAME \"${package_file_name}.orig\")\n"
  "set(CPACK_PACKAGE_DESCRIPTION \"${CPACK_PACKAGE_NAME} Source\")\n"
  "set(CPACK_IGNORE_FILES \"${CPACK_SOURCE_IGNORE_FILES}\")\n"
  "set(CPACK_INSTALLED_DIRECTORIES \"${CPACK_SOURCE_INSTALLED_DIRECTORIES}\")\n"
  )

set(orig_file "${CMAKE_BINARY_DIR}/_Debian/${package_file_name}.orig.tar.gz")
add_custom_command(OUTPUT "${orig_file}"
  COMMAND cpack --config ./cpack.cmake
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/_Debian"
  )

##########################################################################
# upload packages to PPA                                                 #
##########################################################################

set(changes_file_list)
set(changes_file_deps)

foreach(dist maverick natty oneiric)
  set(dist_dir "${CMAKE_BINARY_DIR}/_Debian/${dist}")
  file(COPY "${debian_dir}" DESTINATION "${dist_dir}")

  file(WRITE "${dist_dir}/debian/changelog"
    "${CPACK_DEBIAN_PACKAGE_NAME} (${day_suffix}-${dist}) ${dist}; urgency=low\n\n"
    "  * Package built with CMake\n\n"
    " -- ${CPACK_PACKAGE_CONTACT}  ${DATE_TIME}"
    )

  set(changes_file "${package_file_name}-${dist}_source.changes")

  add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/_Debian/${changes_file}
    COMMAND ${DPKG_BUILDPACKAGE} -S
    DEPENDS "${orig_file}"
    WORKING_DIRECTORY "${dist_dir}"
    )

  list(APPEND changes_file_list ${changes_file})
  list(APPEND changes_file_deps ${CMAKE_BINARY_DIR}/_Debian/${changes_file})
endforeach(dist)

add_custom_target(deploy
  ${DPUT} "ppa:purplekarrot/ppa" ${changes_file_list}
  DEPENDS ${changes_file_deps}
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/_Debian"
  )

