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
#endif

#include "pdfdocument.h"
//#include "verticalview.h"

#include "lib.h"
#include "library.h"
#include "./src/models/basemodel.h"
#include "./src/models/library/librarymodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
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


    //@uri DocumentViewer.PDF
    qmlRegisterType<PdfDocument>("PDF", 1, 0, "Document");
    //        qmlRegisterType<VerticalView>("PDF", 1, 0, "VerticalView");

    qmlRegisterUncreatableType<BaseList>("BaseList", 1, 0, "BaseList", QStringLiteral("BaseList should not be created in QML"));

    qmlRegisterType<BaseModel>("LibraryModel", 1, 0, "LibraryModel");
    qmlRegisterType<LibraryModel>("LibraryList", 1, 0, "LibraryList");

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
