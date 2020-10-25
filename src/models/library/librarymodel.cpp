#include "librarymodel.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fmh.h"
#include "fileloader.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fmh.h>
#include <MauiKit/fileloader.h>
#endif


LibraryModel::LibraryModel(QObject *parent) : MauiList(parent)
  , m_fileLoader(new FMH::FileLoader())
{
    qDebug()<< "CREATING GALLERY LIST";
    qRegisterMetaType<LibraryModel*>("const LibraryModel*");
    connect(m_fileLoader, &FMH::FileLoader::itemsReady,[this](FMH::MODEL_LIST items)
    {
        emit this->preListChanged();
        this-> list << items;
        emit this->postListChanged();
        emit countChanged(); //TODO this is a bug from mauimodel not changing the count right //TODO
    });

    this->refreshCollection();
}


void LibraryModel::refreshCollection()
{
    this->m_fileLoader->requestPath({/*FMH::DesktopPath,*/ FMH::DownloadsPath, FMH::DocumentsPath, FMH::CloudCachePath}, true, FMH::FILTER_LIST[FMH::FILTER_TYPE::DOCUMENT]);
}

FMH::MODEL_LIST LibraryModel::items() const
{
    return this->list;
}

bool LibraryModel::update(const int &index, const QVariant &value, const int &role)
{
    return false;
}

bool LibraryModel::update(const QVariantMap &data, const int &index)
{
    return false;
}

bool LibraryModel::update(const FMH::MODEL &pic)
{
    return false;
}

bool LibraryModel::remove(const int &index)
{
    return false;
}

bool LibraryModel::deleteAt(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    auto item = this->list.takeAt(index);
//    this->dba->deleteDoc(item[FMH::MODEL_KEY::URL]);
    emit this->postItemRemoved();

    return true;
}

bool LibraryModel::fav(const int &index, const bool &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

//    if(this->dba->favDoc(this->list[index][FMH::MODEL_KEY::URL], value))
//    {
//        this->list[index].insert(FMH::MODEL_KEY::FAV, value ? "1" : "0");
//        return true;
//    }

    return false;
}

bool LibraryModel::bookmark(const int &index, const int &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

//    return this->dba->bookmarkDoc(this->list[index][FMH::MODEL_KEY::URL], value);
    return false;
}

void LibraryModel::append(const QVariantMap &pic)
{
    emit this->preItemAppended();

    for(auto key : pic.keys())
        this->list << FMH::MODEL {{FMH::MODEL_NAME_KEY[key], pic[key].toString()}};

    emit this->postItemAppended();
}

void LibraryModel::append(const QString &url)
{
    emit this->preItemAppended();
    qDebug()<< QString("select * from images where url = '%1'").arg(url);
    this->list << FMH::getFileInfoModel(url);
    emit this->postItemAppended();
}

void LibraryModel::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();
}

void LibraryModel::insert(const QString &url)
{
    if(!FMH::fileExists(url))
        return;
}
