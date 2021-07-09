#include "librarymodel.h"

#include <MauiKit/FileBrowsing/tagging.h>
#include <MauiKit/FileBrowsing/fileloader.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

#include <MauiKit/Core/fmh.h>

LibraryModel::LibraryModel(QObject *parent) : MauiList(parent)
  , m_fileLoader(new FMH::FileLoader(parent))
{
    qDebug()<< "CREATING GALLERY LIST";
    qRegisterMetaType<LibraryModel*>("const LibraryModel*");

    connect(m_fileLoader, &FMH::FileLoader::itemsReady,[this](FMH::MODEL_LIST items)
    {
        emit this->preItemsAppended(items.size());
        this->list << items;
        emit this->postItemAppended();
        emit this->countChanged();
    });

}

void LibraryModel::setList()
{
    this->m_fileLoader->requestPath({FMStatic::DesktopPath, FMStatic::DownloadsPath, FMStatic::DocumentsPath, FMStatic::CloudCachePath}, true, FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::DOCUMENT]);
}

const FMH::MODEL_LIST &LibraryModel::items() const
{
    return this->list;
}

bool LibraryModel::remove(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    this->list.remove(index);
    emit this->postItemRemoved();

    return true;
}

bool LibraryModel::deleteAt(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto url = this->list.at(index).value(FMH::MODEL_KEY::URL);
    if(remove(index))
    {
        if(FMStatic::removeFiles({url}))
        {
            return true;
        }
    }

    return false;
}

bool LibraryModel::bookmark(const int &index, const int &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

    //    return this->dba->bookmarkDoc(this->list[index][FMH::MODEL_KEY::URL], value);
    return false;
}

void LibraryModel::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();
}

void LibraryModel::componentComplete()
{
    this->setList();
}
