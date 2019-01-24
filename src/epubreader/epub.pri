include($$PWD/quazip/quazip.pri)

INCLUDEPATH += $$[QT_INSTALL_HEADERS]/QtZlib
INCLUDEPATH += $$PWD
DEPENDPATH += $$PWD

SOURCES += $$PWD/epubreader.cpp \
#    $$PWD/cbzreader.cpp \

HEADERS += $$PWD/epubreader.h \
#    $$PWD/cbzreader.h \
