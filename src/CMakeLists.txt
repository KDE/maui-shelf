# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


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
        ${shelf_SRCS}
        ${shelf_ASSETS}
        )
else()
    add_executable(${PROJECT_NAME}
        ${shelf_SRCS}
        ${shelf_ASSETS}
        )
endif()

if (ANDROID)
     target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Quick Qt5::Qml KF5::CoreAddons KF5::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/shelf.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
