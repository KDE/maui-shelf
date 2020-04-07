#include <QQmlApplicationEngine>

#include <QQmlApplicationEngine>
#include <QQmlContext>
// #include <QQuickStyle>
#include <QIcon>
#include <QCommandLineParser>
#include <QFileInfo>
#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "./mauikit/src/mauikit.h"
#include <QStyleHints>
#endif

#include "pdfdocument.h"
#include "epubreader.h"

#include "lib.h"
#include "library.h"
#include "./src/models/library/librarymodel.h"
//#include "./src/models/cloud/cloud.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QGuiApplication::styleHints()->setMousePressAndHoldInterval(2000); // in [ms]
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName(LIB::AppName);
    app.setApplicationVersion(LIB::AppVersion);
    app.setApplicationDisplayName(LIB::AppName);
    app.setWindowIcon(QIcon(":/assets/library.svg"));

    //    Library library;

    QQmlApplicationEngine engine;

    auto context = engine.rootContext();
    //    context->setContextProperty("library", &library);


    qmlRegisterType<PdfDocument>("PDF", 1, 0, "Document");
    qmlRegisterType<EpubReader>("EPUB", 1, 0, "Document");
    qmlRegisterType<LibraryModel>("LibraryList", 1, 0, "LibraryList");
//    qmlRegisterType<Cloud>("CloudList", 1, 0, "CloudList");


#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
