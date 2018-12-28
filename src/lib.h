#ifndef LIB_H
#define LIB_H

#include <QString>

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/fmh.h>
#else
#include "fmh.h"
#endif

namespace LIB
{
const QString AppName = "Library";
const QString AppVersion = "1.0.0";
const QString AppComment = "Documents collection manager";
const QString DBName = "collection.db";
const QString CollectionDBPath = FMH::DataPath+"/Library/";

enum class TABLE : uint8_t
{
    SOURCES,
    DOCUMENTS,
    BOOKMARKS
};

static const QMap<TABLE,QString> TABLEMAP =
{
    {TABLE::SOURCES,"sources"},
    {TABLE::DOCUMENTS,"documents"},
    {TABLE::BOOKMARKS,"bookmarks"},
};

}

#endif // LIB_H
