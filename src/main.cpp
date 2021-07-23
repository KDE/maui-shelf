#include <QCommandLineParser>
#include <QDate>
#include <QFileInfo>
#include <QIcon>

#include <QQmlApplicationEngine>
#include <QQmlContext>


#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include <MauiKit/Core/mauiapp.h>

#include "pdfdocument.h"
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
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

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
    KAboutData about(QStringLiteral("shelf"), i18n("Shelf"), SHELF_VERSION_STRING, i18n("Browse and view your documents."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/shelf");
    about.setBugAddress("https://invent.kde.org/maui/shelf/-/issues");
    about.setOrganizationDomain(SHELF_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    //    Library library;
    QQmlApplicationEngine engine;
    qmlRegisterType<PdfDocument>("PDF", 1, 0, "Document");
//	qmlRegisterType<EpubReader>("EPUB", 1, 0, "Document");
    qmlRegisterType<LibraryModel>(SHELF_URI, 1, 0, "LibraryList");
//    qmlRegisterType<Cloud>("CloudList", 1, 0, "CloudList");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
