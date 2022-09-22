#include <QCommandLineParser>
#include <QDate>
#include <QIcon>
#include <QPair>

#include <QQmlApplicationEngine>
#include <QQmlContext>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include <MauiKit/Core/mauiapp.h>

//#include "epubreader.h"

#include "library.h"
#include "models/library/librarymodel.h"
//#include "./src/models/cloud/cloud.h"

#include <KI18n/KLocalizedString>

#include "../shelf_version.h"

#define SHELF_URI "org.maui.shelf"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName("Maui");
    app.setWindowIcon(QIcon(":/assets/shelf.svg"));

    MauiApp::instance ()->setIconName ("qrc:/assets/shelf.svg");

    KLocalizedString::setApplicationDomain("shelf");
    KAboutData about(QStringLiteral("shelf"), i18n("Shelf"), SHELF_VERSION_STRING, i18n("Browse and view your documents."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Maui Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/shelf");
    about.setBugAddress("https://invent.kde.org/maui/shelf/-/issues");
    about.setOrganizationDomain(SHELF_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    QPair<QString, QList<QUrl>> arguments;
    arguments.first = "collection";

    if (!args.isEmpty())
    {
        arguments.first = "viewer";
    }

    QQmlApplicationEngine engine;
    QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, args](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        if (!args.isEmpty())
            Library::instance()->openFiles(args);
    },
    Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("globalQmlEngine", &engine);

    engine.rootContext()->setContextProperty("initModule", arguments.first);
    engine.rootContext()->setContextProperty("initData", QUrl::toStringList(arguments.second));

    //	qmlRegisterType<EpubReader>("EPUB", 1, 0, "Document");
    qmlRegisterType<LibraryModel>(SHELF_URI, 1, 0, "LibraryList");
    qmlRegisterSingletonInstance<Library>(SHELF_URI, 1, 0, "Library", Library::instance());

    engine.load(url);

    return app.exec();
}
