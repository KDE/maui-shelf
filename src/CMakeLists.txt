# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

set(shelf_SRCS
    main.cpp
    library.cpp
    models/placesmodel.cpp
    models/library/librarymodel.cpp)

set(shelf_ASSETS
    lib_assets.qrc)

if(ANDROID)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${shelf_SRCS}
        ${shelf_ASSETS})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)

else()
    qt_add_executable(${PROJECT_NAME}
        ${shelf_SRCS}
        ${shelf_ASSETS})
endif()

qt_add_qml_module(${PROJECT_NAME} URI app.maui.shelf
    NO_PLUGIN
    QML_FILES
    main.qml
    views/library/LibraryView.qml
    views/library/LibraryMenu.qml
    views/Viewer/Viewer.qml
    views/cloud/CloudView.qml
    views/Viewer/Viewer_TXT.qml
    views/Viewer/Viewer_EPUB.qml
    views/SettingsDialog.qml
    views/Viewer/Viewer_CB.qml
    views/library/Sidebar.qml)

if (ANDROID)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::Documents
    Qt6::Quick
    Qt6::Qml
    Qt6::Sql
    Qt6::Multimedia
    KF6::CoreAddons
    KF6::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/shelf.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

qt_finalize_target(${PROJECT_NAME})
