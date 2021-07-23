#include "cloud.h"

Cloud::Cloud(QObject *parent) : QObject (parent)
{


//    connect(this->fm, &FM::cloudServerContentReady, [this](const FMH::MODEL_LIST &list, const QString &url)
//    {
//        Q_UNUSED(url);
//        emit this->preListChanged();
//        this->list = list;
////        this->formatList();
//        emit this->postListChanged();
//    });

//    connect(this->fm, &FM::warningMessage, [this](const QString &message)
//    {
//        emit this->warning(message);
//    });

//    connect(this->fm, &FM::cloudItemReady, [this](const FMH::MODEL &item, const QString &path)
//    {
//        qDebug()<< "REQUESTED CLOUD IMAGE READY << " << item;
//        Q_UNUSED(path);
//        auto newItem = item;
//        auto url = item[FMH::MODEL_KEY::URL];
//        auto thumbnail = item[FMH::MODEL_KEY::THUMBNAIL];

//        newItem[FMH::MODEL_KEY::FAV] = QString("0");
//        newItem[FMH::MODEL_KEY::URL] = FMH::fileExists(thumbnail)? thumbnail : item[FMH::MODEL_KEY::URL];
//        newItem[FMH::MODEL_KEY::SOURCE] = FMH::fileExists(thumbnail)? thumbnail : item[FMH::MODEL_KEY::PATH];
//        newItem[FMH::MODEL_KEY::TITLE] = item[FMH::MODEL_KEY::LABEL];

//        this->update(FMH::toMap(newItem), this->pending.take(QString(item[FMH::MODEL_KEY::PATH]).replace(FMH::CloudCachePath+"opendesktop", FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH])));
//        emit this->cloudItemReady(FMH::toMap(newItem));
//    });
}
