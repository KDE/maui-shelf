
ecm_create_qm_loader(shelfpoppler_QM_LOADER shelfpopplerplugin_qt)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    )

#add the sources to compile
set(
    sources
    code/shelfpoppler_plugin.cpp
    code/pdfdocument.cpp
    code/pdfimageprovider.cpp
    code/thumbnailer.cpp
    code/pdfitem.cpp
#    code/verticalview.cpp
    code/pdftocmodel.cpp
    resources.qrc
     ${shelfpoppler_QM_LOADER}
    )

set(
    pluginData
    controls/qmldir
    )

#ecm_generate_qmltypes(org.shelf.poppler ${PROJECT_VERSION}
#    DESTINATION ${KDE_INSTALL_QMLDIR}/org/shelf/poppler )


#ecm_generate_qmltypes(org.shelf.poppler ${PROJECT_VERSION}
#    DESTINATION ${CMAKE_BINARY_DIR}/bin/org/shelf/poppler)

add_library(
    ShelfPoppler
    SHARED
    ${sources} ${pluginData}
    )

#generate_export_header(ShelfPoppler BASE_NAME ShelfPoppler)
#set_target_properties(ShelfPoppler PROPERTIES
#    VERSION ${ShelfPoppler_VERSION_STRING}
#    SOVERSION ${ShelfPoppler_SOVERSION}
#    EXPORT_NAME ShelfPopplerPlugin
#    )

target_include_directories(ShelfPoppler
    INTERFACE "$<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR}/Shelf/Poppler>")

target_include_directories(ShelfPoppler PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR};${CMAKE_CURRENT_BINARY_DIR};>")

if (ANDROID)
    add_library(poppler SHARED IMPORTED GLOBAL)
    set_target_properties( poppler PROPERTIES IMPORTED_LOCATION "/home/camilo/Qt5152/5.15.2/android/lib/libpoppler_armeabi-v7a.so" )

    add_library(poppler-qt5 SHARED IMPORTED GLOBAL)
    set_target_properties( poppler-qt5 PROPERTIES IMPORTED_LOCATION "/home/camilo/Qt5152/5.15.2/android/lib/libpoppler-qt5_armeabi-v7a.so" )

    target_include_directories(ShelfPoppler PUBLIC "/home/camilo/Qt5152/5.15.2/android/include/")

    target_link_libraries(ShelfPoppler PRIVATE poppler-qt5)
elseif(UNIX)
    target_link_libraries(ShelfPoppler PRIVATE Poppler::Qt5)
endif()

target_link_libraries(
    ShelfPoppler
    PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::Qml
    Qt5::Concurrent
    )

#install(TARGETS ShelfPoppler EXPORT ShelfPopplerTargets ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

#install(FILES
#    ${CMAKE_CURRENT_BINARY_DIR}/shelfpoppler_export.h
#    DESTINATION ${KDE_INSTALL_INCLUDEDIR}/Shelf/Poppler
#    COMPONENT Devel)

if (BUILD_SHARED_LIBS)
    add_custom_target(copy_to_bin ALL
        COMMAND ${CMAKE_COMMAND} -E
        make_directory ${CMAKE_BINARY_DIR}/bin/org/shelf/poppler/
        COMMAND ${CMAKE_COMMAND} -E
        copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/controls ${CMAKE_BINARY_DIR}/bin/org/shelf/poppler/
        COMMAND ${CMAKE_COMMAND} -E
        copy $<TARGET_FILE:ShelfPoppler> ${CMAKE_BINARY_DIR}/bin/org/shelf/poppler/
        )

    install(DIRECTORY controls/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/shelf/poppler)
endif()

install(TARGETS ShelfPoppler DESTINATION ${KDE_INSTALL_QMLDIR}/org/shelf/poppler)

