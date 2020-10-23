# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


cmake_minimum_required(VERSION 3.0)

set(SHELF_VERSION 1.0.0)
set(CMAKE_CXX_STANDARD 17)

project(shelf VERSION ${SHELF_VERSION})

set(REQUIRED_QT_VERSION 5.10.0)
set(REQUIRED_KF5_VERSION 5.60)

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Core Qml Quick Sql Svg QuickControls2)
find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n Notifications KIO Attica)
find_package ( Poppler REQUIRED COMPONENTS Qt5 )

if(ANDROID)
    find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS AndroidExtras)
endif()

find_package(MauiKit REQUIRED)

include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMAddAppIcon)
include(FeatureSummary)

ecm_setup_version(${SHELF_VERSION}
    VARIABLE_PREFIX SHELF
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/shelf_version.h"
    )

add_subdirectory(src)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
