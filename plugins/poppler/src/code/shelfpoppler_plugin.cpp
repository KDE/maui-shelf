// SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <QQmlEngine>
#include <QResource>

#include "shelfpoppler_plugin.h"
#include "pdfdocument.h"

void ShelfPopplerPlugin::registerTypes(const char *uri)
{
#if defined(Q_OS_ANDROID)
    QResource::registerResource(QStringLiteral("assets:/android_rcc_bundle.rcc"));
    #endif

    qmlRegisterType<PdfDocument>(uri, 1, 0, "Document");

    qmlRegisterType(resolveFileUrl(QStringLiteral("PDFViewer.qml")), uri, 1, 0, "PDFViewer");

}
