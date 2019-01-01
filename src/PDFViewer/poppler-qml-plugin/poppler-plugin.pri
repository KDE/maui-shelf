QT += concurrent xml quick qml gui core

INCLUDEPATH  += $$PWD/ \
#INCLUDEPATH  += "/usr/include/qt/QtQml/5.12.0/QtQml/"
#INCLUDEPATH  += "/usr/include/qt/QtQml/5.12.0/QtQml/private"
#INCLUDEPATH  += "/usr/include/qt/QtQml/5.12.0/"
#INCLUDEPATH  += "/usr/include/qt/QtQml/"

#INCLUDEPATH  += "/usr/include/qt/QtQuick/5.12.0/QtQuick/"
#INCLUDEPATH  += "/usr/include/qt/QtQuick/5.12.0/QtQuick/private/"
#INCLUDEPATH  += "/usr/include/qt/QtQuick/"
#INCLUDEPATH  += "/usr/include/qt/QtQuick/5.12.0/"

#INCLUDEPATH  += "/usr/include/qt/QtCore/5.12.0/QtCore/private/"
#INCLUDEPATH  += "/usr/include/qt/QtCore/5.12.0/QtCore/"
#INCLUDEPATH  += "/usr/include/qt/QtCore/5.12.0/"

#INCLUDEPATH  += "/usr/include/qt/QtGui/5.12.0/QtGui"
#INCLUDEPATH  += "/usr/include/qt/QtGui/5.12.0/"
#INCLUDEPATH  += "/usr/include/qt/QtGui/5.12.0/QtGui/private"

SOURCES += \
    $$PWD/pdfdocument.cpp \
    $$PWD/pdfimageprovider.cpp \
    $$PWD/pdfitem.cpp \
    $$PWD/pdftocmodel.cpp \
#    $$PWD/verticalview.cpp

HEADERS += \
    $$PWD/pdfdocument.h \
    $$PWD/pdfimageprovider.h \
    $$PWD/pdfitem.h \
    $$PWD/pdftocmodel.h \
#    $$PWD/verticalview.h
