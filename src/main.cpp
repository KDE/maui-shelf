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
#include "mauiapp.h"
#else
#include <MauiKit/mauiapp.h>
#endif

#include "pdfdocument.h"
#include "epubreader.h"

#include "lib.h"
#include "library.h"
#include "./src/models/library/librarymodel.h"
//#include "./src/models/cloud/cloud.h"

#define LIBRARY_URI "org.maui.library"

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
	app.setOrganizationName(LIB::orgName);
    app.setOrganizationDomain(LIBRARY_URI);
	app.setWindowIcon(QIcon(":/assets/library.svg"));
	MauiApp::instance()->setHandleAccounts(false); //for now index can not handle cloud accounts
	MauiApp::instance()->setCredits ({QVariantMap({{"name", "Camilo Higuita"}, {"email", "milo.h@aol.com"}, {"year", "2019-2020"}})});
	MauiApp::instance()->setDescription ("Library is a documents viewer and collection manager.\nLibrary allows you to browse your local and cloud collection, and also allows you to download new content from the integrated store.");

    //    Library library;
    QQmlApplicationEngine engine;
	qmlRegisterType<PdfDocument>("PDF", 1, 0, "Document");
	qmlRegisterType<EpubReader>("EPUB", 1, 0, "Document");
    qmlRegisterType<LibraryModel>(LIBRARY_URI, 1, 0, "LibraryList");
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
