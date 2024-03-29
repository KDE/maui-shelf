# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


set(shelf_SRCS
    main.cpp
    library.cpp
    models/placesmodel.cpp
    models/library/librarymodel.cpp)

set(shelf_ASSETS
    lib_assets.qrc)

if(QUICK_COMPILER)
    qtquick_compiler_add_resources(shelf_QML_QRC qml.qrc)
else()
    qt5_add_resources(shelf_QML_QRC qml.qrc)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME}
        SHARED
        ${shelf_SRCS}
        ${shelf_ASSETS}
        ${shelf_QML_QRC})
else()
    add_executable(${PROJECT_NAME}
        ${shelf_SRCS}
        ${shelf_ASSETS}
        ${shelf_QML_QRC})
endif()

if (ANDROID)
     target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    MauiKit3
    MauiKit3::FileBrowsing
    MauiKit3::Documents
    Qt5::Quick
    Qt5::Qml
    KF5::CoreAddons
    KF5::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/shelf.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
