


#ANDROID_EXTRA_LIBS += $$PWD/poppler/libfreetype.so
ANDROID_EXTRA_LIBS += $$PWD/poppler/libfreetype.so
#ANDROID_EXTRA_LIBS += $$PWD/poppler/libpoppler.so
#ANDROID_EXTRA_LIBS += $$PWD/poppler/libpoppler-qt5.so

INCLUDEPATH  += $$PWD/poppler/qt5/ \

LIBS += -L$$PWD/poppler/ -lfreetype
LIBS += -L$$PWD/poppler/ -lpoppler-qt5
LIBS += -L$$PWD/poppler/ -lpoppler

#unix:!macx: LIBS += -lfreetype

#unix:!macx|win32: LIBS += -lfreetype
