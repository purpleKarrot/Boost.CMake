################################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>                   #
#                                                                              #
# Distributed under the Boost Software License, Version 1.0.                   #
# See accompanying file LICENSE_1_0.txt or copy at                             #
#   http://www.boost.org/LICENSE_1_0.txt                                       #
################################################################################

string(TOLOWER ${CPACK_PACKAGE_NAME} package_name)
set(specfile "${BOOST_MONOLITHIC_DIR}/${package_name}.spec")

file(WRITE ${specfile}
  "# -*- rpm-spec -*-\n"
  "Name:      ${package_name}\n"
  "Summary:   The free peer-reviewed portable C++ source libraries\n"
  "Version:   ${Boost_VERSION}\n"
  "Release:   1\n"
  "License:   Boost Software License, Version 1.0\n"
  "URL:       http://www.boost.org\n"
  "Group:     System Environment/Libraries\n"
  "Source:    ${CPACK_SOURCE_PACKAGE_FILE_NAME}.tar.gz\n"
  "BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root\n"
  )

################################################################################
# build requires

foreach(depend ${CPACK_RPM_BUILD_DEPENDS})
  file(APPEND ${specfile} "BuildRequires: ${depend}\n")
endforeach(depend)

file(APPEND ${specfile} "\n")

################################################################################
# long description

file(READ "${CPACK_PACKAGE_DESCRIPTION_FILE}" description)
file(APPEND ${specfile} "%description\n${description}\n\n")

################################################################################
# package descriptions

foreach(component ${CPACK_COMPONENTS_ALL})
  string(TOUPPER "${component}" COMPONENT)
  file(APPEND ${specfile}
    "%package ${component}\n"
    "Summary: ${CPACK_COMPONENT_${COMPONENT}_DISPLAY_NAME}\n"
    "Group: System Environment/Libraries\n"
#   "Requires: boost-mpich2 = %{version}-%{release}\n"
    "\n"
    "%description ${component}\n"
    "${CPACK_COMPONENT_${COMPONENT}_DESCRIPTION}\n"
    "\n"
    )
endforeach(component)

################################################################################
# prep

file(APPEND ${specfile}
  "%prep\n"
  "%setup -q -n ${CPACK_SOURCE_PACKAGE_FILE_NAME}\n"
  "\n"
  )

################################################################################
# build

file(APPEND ${specfile}
  "%build\n"
  "cmake .\n"
  "make -j8 preinstall\n"
  "\n"
  )

################################################################################
# check

# file(APPEND ${specfile}
#   "%check\n"
#   "make test\n"
#   "\n"
#   )

################################################################################
# install

file(APPEND ${specfile} "%install\n")

foreach(component ${CPACK_COMPONENTS_ALL})
  file(APPEND ${specfile}
    "cmake -DCOMPONENT=${component} -DCMAKE_INSTALL_PREFIX=$RPM_BUILD_ROOT/usr -P cmake_install.cmake\n"
    "sed s!$RPM_BUILD_ROOT!!g install_manifest_${component}.txt > files.${component}.txt\n"
    )
endforeach(component)

file(APPEND ${specfile} "\n")

################################################################################
# clean

file(APPEND ${specfile}
  "%clean\n"
  "cmake -E remove_directory ${CPACK_SOURCE_PACKAGE_FILE_NAME}\n"
  "\n"
  )

################################################################################
# files

foreach(component ${CPACK_COMPONENTS_ALL})
  file(APPEND ${specfile}
    "%files ${component} -f files.${component}.txt\n"
    "%defattr(-, root, root, -)\n"
    "%doc LICENSE_1_0.txt\n"
    "\n"
    )
endforeach(component)

################################################################################
# changelog

execute_process(COMMAND date +"%a %b %d %Y"
  OUTPUT_VARIABLE date OUTPUT_STRIP_TRAILING_WHITESPACE
  )

string(REPLACE "\"" "" date ${date})

file(APPEND ${specfile}
  "%changelog\n"
  "* ${date} ${CPACK_PACKAGE_CONTACT}\n"
  "  Package built with CMake\n"
  )

################################################################################
# deploy

find_program(RPMBUILD_COMMAND rpmbuild)
set(RPM_ROOTDIR ${CMAKE_BINARY_DIR}/RPM)

file(MAKE_DIRECTORY ${RPM_ROOTDIR})
file(MAKE_DIRECTORY ${RPM_ROOTDIR}/tmp)
file(MAKE_DIRECTORY ${RPM_ROOTDIR}/BUILD)
file(MAKE_DIRECTORY ${RPM_ROOTDIR}/RPMS)
file(MAKE_DIRECTORY ${RPM_ROOTDIR}/SOURCES)
file(MAKE_DIRECTORY ${RPM_ROOTDIR}/SPECS)
file(MAKE_DIRECTORY ${RPM_ROOTDIR}/SRPMS)

add_custom_target(rpm_source
  COMMAND cpack -G TGZ --config CPackSourceConfig.cmake
  COMMAND ${CMAKE_COMMAND} -E copy ${CPACK_SOURCE_PACKAGE_FILE_NAME}.tar.gz ${RPM_ROOTDIR}/SOURCES
  COMMAND ${RPMBUILD_COMMAND} -bs --define=\"_topdir ${RPM_ROOTDIR}\" --buildroot=${RPM_ROOTDIR}/tmp ${specfile}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )

add_custom_target(rpm
  COMMAND cpack -G TGZ --config CPackSourceConfig.cmake
  COMMAND ${CMAKE_COMMAND} -E copy ${CPACK_SOURCE_PACKAGE_FILE_NAME}.tar.gz ${RPM_ROOTDIR}/SOURCES
  COMMAND ${RPMBUILD_COMMAND} -bb --define=\"_topdir ${RPM_ROOTDIR}\" --buildroot=${RPM_ROOTDIR}/tmp ${specfile}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )  
