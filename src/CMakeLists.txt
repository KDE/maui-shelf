# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/PDFViewer/poppler-qml-plugin
    ${CMAKE_CURRENT_BINARY_DIR}/PDFViewer/poppler-qml-plugin
    )

set(popplerqmlplugin_SRCS
#    PDFViewer/poppler-qml-plugin/plugin.cpp
    PDFViewer/poppler-qml-plugin/pdfdocument.cpp
    PDFViewer/poppler-qml-plugin/pdfimageprovider.cpp
    PDFViewer/poppler-qml-plugin/pdfitem.cpp
#    PDFViewer/poppler-qml-plugin/verticalview.cpp
    PDFViewer/poppler-qml-plugin/pdftocmodel.cpp
)

set(shelf_SRCS
    main.cpp
    models/library/librarymodel.cpp
    library.cpp
    qml.qrc
    lib_assets.qrc
)

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${popplerqmlplugin_SRCS}
        ${shelf_SRCS} )
else()
    add_executable(${PROJECT_NAME}
        ${popplerqmlplugin_SRCS}
        ${shelf_SRCS} )
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)
endif()

target_link_libraries(${PROJECT_NAME} MauiKit Qt5::Sql Qt5::Quick Qt5::Core Qt5::Qml Qt5::Svg PkgConfig::PopplerQt5 Qt5::Concurrent KF5::SyntaxHighlighting KF5::CoreAddons KF5::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
install(TARGETS shelf ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.maui.shelf.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/shelf.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
# install(FILES org.kde.index.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
endif()
