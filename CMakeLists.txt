cmake_minimum_required(VERSION 3.16)

set(SHELF_VERSION 4.0.2)
add_compile_definitions(APP_COPYRIGHT_NOTICE="© 2019-2025 Maui Development Team")

project(shelf LANGUAGES CXX VERSION ${SHELF_VERSION})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(QT_MAJOR_VERSION 6)

set(REQUIRED_QT_VERSION 6.5.2)
set(REQUIRED_KF_VERSION 5.240.0)

find_package(ECM ${REQUIRED_KF_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

if(ANDROID)
    set(ANDROID_ABIS "armeabi-v8a")

    find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS QuickControls2)
elseif(UNIX)
    find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Widgets)
endif()

find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Sql Multimedia Qml Quick)
find_package(KF6 ${REQUIRED_KF_VERSION} REQUIRED COMPONENTS I18n CoreAddons)

find_package(MauiKit4 REQUIRED COMPONENTS FileBrowsing Documents)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    include(KDEInstallDirs)
    include(KDECMakeSettings)
endif()

#include(KDECompilerSettings NO_POLICY_SCOPE) //this makes android app launch crash by not finding the main method
include(KDEClangFormat)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(FeatureSummary)

if(${ECM_SOURCE_UNDER_VERSION_CONTROL})
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # Get the latest abbreviated commit hash of the working branch
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
    add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

else()
    add_definitions(-DGIT_COMMIT_HASH="${SHELF_VERSION}")
    add_definitions(-DGIT_BRANCH="Stable")
endif()

ecm_setup_version(${SHELF_VERSION}
    VARIABLE_PREFIX SHELF
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/shelf_version.h")

qt_policy(SET QTP0001 OLD)
qt_policy(SET QTP0004 NEW)

add_subdirectory(src)
ki18n_install(po)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(FILES org.kde.shelf.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES org.kde.shelf.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
endif()

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

qt_finalize_project()
