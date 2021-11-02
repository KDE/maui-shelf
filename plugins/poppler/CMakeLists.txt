# SPDX-FileCopyrightText: 2021 Camilo Higuita <milo.h@aol.com>
#
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.16)

set(KF5_VERSION "5.70.0")
set(REQUIRED_QT_VERSION 5.15.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(UNIX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror")
endif()

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE) #for windows copying libs

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(AUTOMOC_MOC_OPTIONS -Muri=org.shelf.poppler)

project(ShelfPoppler LANGUAGES CXX VERSION 1.0.0)

find_package(ECM ${KF5_VERSION} NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

option(QUICK_COMPILER "Use QtQuick compiler to improve performance" TRUE)

include(GenerateExportHeader)
include(GNUInstallDirs)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(FeatureSummary)
include(ECMPoQmTools)
include(ECMSetupVersion)
include(ECMGenerateQmlTypes)
include(CMakePackageConfigHelpers)
#include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)
include(KDEPackageAppTemplates)

set(CMAKECONFIG_INSTALL_DIR "${KDE_INSTALL_CMAKEPACKAGEDIR}/ShelfPoppler")

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/ShelfPopplerConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/ShelfPopplerConfig.cmake"
    INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR}
    PATH_VARS KF5_INCLUDE_INSTALL_DIR CMAKE_INSTALL_PREFIX
    )

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/ShelfPopplerConfigVersion.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/ShelfPopplerConfig.cmake"
    DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
    COMPONENT Devel
    )

#install(EXPORT ShelfPopplerTargets
#    DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
#    FILE ShelfPopplerTargets.cmake
#    NAMESPACE Shelf::)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX ShelfPoppler
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/shelfpoppler_version.h"
    PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/ShelfPopplerConfigVersion.cmake"
    SOVERSION 1
    )

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/shelfpoppler_version.h"
    DESTINATION ${KDE_INSTALL_INCLUDEDIR}/Shelf/Poppler
    COMPONENT Devel)

find_package(Qt5 ${REQUIRED_QT_VERSION} COMPONENTS Core Quick Concurrent REQUIRED)

if(QUICK_COMPILER)
    find_package(Qt5QuickCompiler)
    set_package_properties(Qt5QuickCompiler PROPERTIES
        DESCRIPTION "Compile QML at build time"
        TYPE OPTIONAL
        )
endif()

add_subdirectory(src)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
