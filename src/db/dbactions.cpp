/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

#include "dbactions.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

DBActions::DBActions(QObject *parent) : DB(parent) {}

DBActions::~DBActions() {}

void DBActions::init()
{
    qDebug() << "Getting collectionDB info from: " << LIB::CollectionDBPath;

    qDebug()<< "Starting DBActions";

    this->tag = Tagging::getInstance();
}

DBActions *DBActions::instance = nullptr;

DBActions *DBActions::getInstance()
{
    if(!instance)
    {
        instance = new DBActions();
        qDebug() << "getInstance(): First DBActions instance\n";
        instance->init();
        return instance;
    } else
    {
        qDebug()<< "getInstance(): previous DBActions instance\n";
        return instance;
    }
}

bool DBActions::execQuery(const QString &queryTxt)
{
    auto query = this->getQuery(queryTxt);
    return query.exec();
}

bool DBActions::insertDoc(const FMH::MODEL &doc)
{
    auto url = doc[FMH::MODEL_KEY::URL];
    auto title = doc[FMH::MODEL_KEY::TITLE];
    auto rate = doc[FMH::MODEL_KEY::RATE];
    auto fav = doc[FMH::MODEL_KEY::FAV];
    auto modified = doc[FMH::MODEL_KEY::MODIFIED];
    auto sourceUrl = doc[FMH::MODEL_KEY::SOURCE];
    auto date = doc[FMH::MODEL_KEY::DATE];
    auto format = doc[FMH::MODEL_KEY::FORMAT];

    qDebug()<< "writting to db: "<<title<<url<<format <<fav;
    /* first needs to insert album and artist*/
    QVariantMap sourceMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], sourceUrl}};
    this->insert(LIB::TABLEMAP[LIB::TABLE::SOURCES], sourceMap);


    QVariantMap docMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], sourceUrl},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::RATE], rate},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FAV], fav},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::DATE], date},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FORMAT], format},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::MODIFIED], modified}};

    return this->insert(LIB::TABLEMAP[LIB::TABLE::DOCUMENTS], docMap);
}

bool DBActions::addDoc(const QString &url)
{
    if(!this->checkExistance(LIB::TABLEMAP[LIB::TABLE::DOCUMENTS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
    {

        qDebug()<< "ADDING DOC" << url;
        QFileInfo info(url);
        auto title = info.baseName();
        auto format = info.suffix();
        auto sourceUrl = info.dir().path();

        FMH::MODEL picMap =
        {
            {FMH::MODEL_KEY::URL, url},
            {FMH::MODEL_KEY::TITLE, title},
            {FMH::MODEL_KEY::FAV, "0"},
            {FMH::MODEL_KEY::RATE, "0"},
            {FMH::MODEL_KEY::SOURCE, sourceUrl},
            {FMH::MODEL_KEY::DATE, info.birthTime().toString()},
            {FMH::MODEL_KEY::MODIFIED, info.lastModified().toString()},
            {FMH::MODEL_KEY::FORMAT, format}
        };

        return this->insertDoc(picMap);
    }

    return false;
}

bool DBActions::removeDoc(const QString &url)
{
    auto queryTxt = QString("DELETE FROM images WHERE url =  \"%1\"").arg(url);
    auto query = this->getQuery(queryTxt);
    if(query.exec())
    {
        queryTxt = QString("DELETE FROM images_tags WHERE url =  \"%1\"").arg(url);
        this->getQuery(queryTxt).exec();

        queryTxt = QString("DELETE FROM images_albums WHERE url =  \"%1\"").arg(url);
        this->getQuery(queryTxt).exec();

        queryTxt = QString("DELETE FROM images_notes WHERE url =  \"%1\"").arg(url);
        this->getQuery(queryTxt).exec();

        return true;
    }
    return false;
}

bool DBActions::deleteDoc(const QString &url)
{
    QFile file(url);
    if(!file.exists()) return false;

    if(file.remove())
        return this->removeDoc(url);

    return false;
}

bool DBActions::favDoc(const QString &url, const bool &fav )
{
    if(!this->checkExistance("documents", "url", url))
        if(!this->addDoc(url))
            return false;

    const FMH::MODEL faved = {{FMH::MODEL_KEY::FAV, fav ? "1" : "0"}};
    return this->update(LIB::TABLEMAP[LIB::TABLE::DOCUMENTS], faved, QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url}}) );
}

bool DBActions::bookmarkDoc(const QString &url, const int &value )
{
    if(!this->checkExistance("documents", "url", url))
        if(!this->addDoc(url))
            return false;

    const QVariantMap map = {{FMH::MODEL_NAME[FMH::MODEL_KEY::BOOKMARK], QString::number(value)}, {FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url}};
    return this->insert(LIB::TABLEMAP[LIB::TABLE::BOOKMARKS], map);
}

bool DBActions::isFav(const QString &url)
{
    const auto data = this->getDBData(QString("select * from images where url = '%1'").arg(url));

    if (data.isEmpty()) return false;

    return data.first()[FMH::MODEL_KEY::FAV] == "1" ? true : false;
}

bool DBActions::addTag(const QString &tag)
{
    if (this->tag->tag(tag))
    {
        emit tagAdded(tag);
        return true;
    }

    return false;
}

bool DBActions::cleanTags()
{
    return false;
}


QVariantList DBActions::searchFor(const QStringList &queries, const QString &queryTxt)
{
    //    QVariantList res;
    //    for(auto query : queries)
    //        res <<  this->get(PIX::getQuery("searchFor_").arg(query));

    //    return res;
}

FMH::MODEL_LIST DBActions::getFolders(const QString &query)
{
    FMH::MODEL_LIST res;
    auto data =  this->getDBData(query);

    /*Data model keys for to be used on MauiKit Icondelegate component */
    for(auto i : data)
        res << FMH::getFileInfoModel(i[FMH::MODEL_KEY::URL]);

    return res;
}

FMH::MODEL_LIST DBActions::getDBData(const QString &queryTxt)
{
    FMH::MODEL_LIST mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            FMH::MODEL data;
            for(auto key : FMH::MODEL_NAME.keys())
                if(query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
                    data.insert(key, query.value(FMH::MODEL_NAME[key]).toString());

            const auto url = data[FMH::MODEL_KEY::URL];
            if(!url.isEmpty())
            {
                if(FMH::fileExists(url))
                {
                    data[FMH::MODEL_KEY::ICON] = FMH::getIconName(url);
                    mapList << data;

                }else
                    this->removeDoc(data[FMH::MODEL_KEY::URL]);
            }else mapList<< data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}


