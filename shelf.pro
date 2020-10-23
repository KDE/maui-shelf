QT += qml
QT += quick
QT += quickcontrols2
QT += sql

TARGET = shelf
TEMPLATE = app

CONFIG += ordered
CONFIG += c++17

linux:unix:!android {

    message(Building for Linux KDE)
    QT += KService KNotifications KNotifications KI18n
    QT += KIOCore KIOFileWidgets KIOWidgets KNTLM
    LIBS += -lMauiKit
    LIBS += -lpoppler-qt5

    INCLUDEPATH  += /usr/include/poppler/qt5
} else:android {

    message(Building helpers for Android)
    include($$PWD/src/PDFViewer/poppler.pri)
    include($$PWD/mauikit/mauikit.pri)
    include($$PWD/3rdparty/kirigami/kirigami.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

include($$PWD/src/PDFViewer/poppler-qml-plugin/poppler-plugin.pri)
include($$PWD/src/epubreader/epub.pri)


# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

INCLUDEPATH  += $$PWD/src/PDFViewer/


SOURCES += \
    $$PWD/src/main.cpp \
    $$PWD/src/models/library/librarymodel.cpp \
#    $$PWD/src/models/cloud/cloud.cpp \
    $$PWD/src/library.cpp


HEADERS += \
    $$PWD/src/models/library/librarymodel.h \
#    $$PWD/src/models/cloud/cloud.h \
    $$PWD/src/library.h

RESOURCES += $$PWD/src/qml.qrc \
    $$PWD/src/lib_assets.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
