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
//#include "epubreader.h"

#include "library.h"
#include "models/library/librarymodel.h"
//#include "./src/models/cloud/cloud.h"

#include <KLocalizedContext>
#include <KLocalizedString>

#define SHELF_URI "org.maui.shelf"

int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
	QGuiApplication app(argc, argv);
	QGuiApplication::styleHints()->setMousePressAndHoldInterval(2000); // in [ms]
#else
	QApplication app(argc, argv);
#endif

	app.setOrganizationName("Maui");
	app.setWindowIcon(QIcon(":/assets/library.svg"));

	MauiApp::instance ()->setIconName ("qrc:/assets/library.svg");
	MauiApp::instance ()->setHandleAccounts (false);

	KLocalizedString::setApplicationDomain("shelf");
	KAboutData about(QStringLiteral("shelf"), i18n("Shelf"), "1.0.0", i18n("Shelf is a documents viewer and collection manager.\nLibrary allows you to browse your local and cloud collection, and also allows you to download new content from the integrated store."),
					 KAboutLicense::LGPL_V3, i18n("© 2019-2020 Nitrux Development Team"));
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
