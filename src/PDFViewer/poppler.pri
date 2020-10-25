#ANDROID_EXTRA_LIBS += $$PWD/poppler/libfreetype.so
ANDROID_EXTRA_LIBS += $$PWD/poppler/libfreetype_armeabi-v7a.so
ANDROID_EXTRA_LIBS += $$PWD/poppler/libpoppler_armeabi-v7a.so
ANDROID_EXTRA_LIBS += $$PWD/poppler/libpoppler-qt5_armeabi-v7a.so

INCLUDEPATH  += $$PWD/poppler/qt5/ \

LIBS += -L$$PWD/poppler/ -lfreetype_armeabi-v7a
LIBS += -L$$PWD/poppler/ -lpoppler-qt5_armeabi-v7a
LIBS += -L$$PWD/poppler/ -lpoppler_armeabi-v7a

