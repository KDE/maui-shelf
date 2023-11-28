#include "librarymodel.h"

#include <QDebug>

#include <MauiKit3/FileBrowsing/fileloader.h>
#include <MauiKit3/FileBrowsing/fmstatic.h>

#include <MauiKit3/Core/fmh.h>

#include "library.h"

static FMH::MODEL fileData(const QUrl &url)
{
    FMH::MODEL model;
    model = FMStatic::getFileInfoModel(url);

    const auto fileName = url.fileName();
    if(fileName.toLower().endsWith("cbr") || fileName.toLower().endsWith("cbz"))
    {
        model.insert(FMH::MODEL_KEY::PREVIEW, QString("image://comiccover/").append(url.toLocalFile()));

    }else
    {
        model.insert(FMH::MODEL_KEY::PREVIEW, "image://preview/"+url.toString());

    }

    return model;
}

LibraryModel::LibraryModel(QObject *parent) : MauiList(parent)
  , m_fileLoader(new FMH::FileLoader(parent))
  , m_sources({"collection:///"})
{
    qRegisterMetaType<LibraryModel*>("const LibraryModel*");

    //    connect(Library::instance(), &Library::sourcesChanged, this, &LibraryModel::setList);

    connect(m_fileLoader, &FMH::FileLoader::itemsReady,[this](FMH::MODEL_LIST items)
    {
        Q_EMIT this->preItemsAppended(items.size());
        this->list << items;
        Q_EMIT this->postItemAppended();
        Q_EMIT this->countChanged();
    });

    connect(this, &LibraryModel::sourcesChanged, this, &LibraryModel::setList);
}

void LibraryModel::setList(const QStringList &sources)
{
    this->clear();
    QStringList paths = sources;
    QStringList filters;

    if(sources.count() == 1 )
    {
        QString source = sources.first();
        paths = Library::instance()->sources();

        if(source == "collection:///")
        {
            filters = FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::DOCUMENT];

        }else if( source == "comics:///")
        {
            QMimeDatabase mimedb;
            QStringList types = mimedb.mimeTypeForName("application/vnd.comicbook+zip").suffixes();
            types << mimedb.mimeTypeForName("application/vnd.comicbook+rar").suffixes();

            for(const auto &type : types)
            {
                filters << "*."+type;
            }

        }else if( source == "documents:///")
        {
            QMimeDatabase mimedb;
            QStringList types = mimedb.mimeTypeForName("application/pdf").suffixes();

            for(const auto &type : types)
            {
                filters << "*."+type;
            }
        }
    }else
    {
        filters = FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::DOCUMENT];
    }

    this->m_fileLoader->informer = &fileData;
    this->m_fileLoader->requestPath(QUrl::fromStringList(paths), true, filters);
}

const FMH::MODEL_LIST &LibraryModel::items() const
{
    return this->list;
}

bool LibraryModel::remove(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    Q_EMIT this->preItemRemoved(index);
    this->list.remove(index);
    Q_EMIT this->postItemRemoved();

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

bool LibraryModel::bookmark(const int &index, const int &)
{
    if(index >= this->list.size() || index < 0)
        return false;

    //    return this->dba->bookmarkDoc(this->list[index][FMH::MODEL_KEY::URL], value);
    return false;
}

void LibraryModel::clear()
{
    if(this->list.isEmpty())
    {
        return;
    }

    Q_EMIT this->preListChanged();
    this->list.clear();
    Q_EMIT this->postListChanged();
    Q_EMIT this->countChanged();
}

void LibraryModel::rescan()
{
    this->setList(m_sources);
}

void LibraryModel::setSources(QStringList sources)
{
    if (m_sources == sources)
        return;

    m_sources = sources;
    Q_EMIT sourcesChanged(m_sources);
}

void LibraryModel::componentComplete()
{
    this->setList(m_sources);
}

QStringList LibraryModel::sources() const
{
    return m_sources;
}

void LibraryModel::resetSources()
{
    setSources({"collection:///"});
}
