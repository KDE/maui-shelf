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

add_executable(shelf
    ${popplerqmlplugin_SRCS}
    ${shelf_SRCS}
)

if (ANDROID)
    target_link_libraries(shelf Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(shelf shelf.cpp)
endif()

target_link_libraries(shelf MauiKit Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg Poppler::Qt5 )

install(TARGETS shelf ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.maui.shelf.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/shelf.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
# install(FILES org.kde.index.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

