// SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QDir>
#include <QQmlExtensionPlugin>

class ShelfPopplerPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override;
private:
    QString resolveFilePath(const QString &path) const
    {
#if defined(Q_OS_ANDROID)
        return QStringLiteral(":/android_rcc_bundle/qml/org/shelf/poppler/") + path;
#else
        return baseUrl().toLocalFile() + QLatin1Char('/') + path;
#endif
    }
    QString resolveFileUrl(const QString &filePath) const
    {
#if defined(Q_OS_ANDROID)
        return QStringLiteral("qrc:/android_rcc_bundle/qml/org/shelf/poppler/") + filePath;
#else
        return baseUrl().toString() + QLatin1Char('/') + filePath;
#endif
    }
};
