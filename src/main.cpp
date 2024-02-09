#include <QCommandLineParser>
#include <QIcon>
#include <QPair>

#include <QQmlApplicationEngine>
#include <QQmlContext>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit3/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include <MauiKit3/Core/mauiapp.h>
#include <MauiKit3/FileBrowsing/moduleinfo.h>
#include <MauiKit3/Documents/moduleinfo.h>

//#include "epubreader.h"

#include "library.h"
#include "models/library/librarymodel.h"
#include "models/placesmodel.h"
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

    KLocalizedString::setApplicationDomain("shelf");
    KAboutData about(QStringLiteral("shelf"),
                     QStringLiteral("Shelf"),
                     SHELF_VERSION_STRING,
                     i18n("Browse and view your documents."),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(QStringLiteral("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/shelf");
    about.setBugAddress("https://invent.kde.org/maui/shelf/-/issues");
    about.setOrganizationDomain(SHELF_URI);
    about.setProgramLogo(app.windowIcon());

    about.addCredit(i18n("Peruse Developers"));

    const auto FBData = MauiKitFileBrowsing::aboutData();
    about.addComponent(FBData.name(), MauiKitFileBrowsing::buildVersion(), FBData.version(), FBData.webAddress());

    const auto DData = MauiKitDocuments::aboutData();
    about.addComponent(DData.name(), MauiKitDocuments::buildVersion(), DData.version(), DData.webAddress());

    const auto PopplerData = MauiKitDocuments::aboutPoppler();
    about.addComponent(PopplerData.name(), "", PopplerData.version(), PopplerData.webAddress());

    KAboutData::setApplicationData(about);
    MauiApp::instance ()->setIconName ("qrc:/assets/shelf.svg");

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

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.rootContext()->setContextProperty("globalQmlEngine", &engine);

    engine.rootContext()->setContextProperty("initModule", arguments.first);
    engine.rootContext()->setContextProperty("initData", QUrl::toStringList(arguments.second));

    //	qmlRegisterType<EpubReader>("EPUB", 1, 0, "Document");
    qmlRegisterType<LibraryModel>(SHELF_URI, 1, 0, "LibraryList");
    qmlRegisterType<PlacesModel>(SHELF_URI, 1, 0, "PlacesList");
    qmlRegisterSingletonInstance<Library>(SHELF_URI, 1, 0, "Library", Library::instance());

    engine.load(url);

    return app.exec();
}
