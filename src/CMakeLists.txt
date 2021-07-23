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
    library.cpp
    models/library/librarymodel.cpp
)

set(shelf_ASSETS
    qml.qrc
    lib_assets.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${popplerqmlplugin_SRCS}
        ${shelf_SRCS}
        ${shelf_ASSETS}
        )
else()
    add_executable(${PROJECT_NAME}
        ${popplerqmlplugin_SRCS}
        ${shelf_SRCS}
        ${shelf_ASSETS}
        )
endif()

if (ANDROID)
    add_library( poppler SHARED IMPORTED GLOBAL)
    set_target_properties( poppler PROPERTIES IMPORTED_LOCATION "/home/camilo/Qt5152/5.15.2/android/lib/libpoppler_armeabi-v7a.so" )

    add_library( poppler-qt5 SHARED IMPORTED GLOBAL)
    set_target_properties( poppler-qt5 PROPERTIES IMPORTED_LOCATION "/home/camilo/Qt5152/5.15.2/android/lib/libpoppler-qt5_armeabi-v7a.so" )

    target_include_directories(${PROJECT_NAME} PUBLIC "/home/camilo/Qt5152/5.15.2/android/include/")

    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2 poppler-qt5)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets Poppler::Qt5)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Quick Qt5::Xml Qt5::Qml KF5::CoreAddons KF5::I18n )

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/shelf.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
