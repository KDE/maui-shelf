#include "librarymodel.h"
#include "./src/db/dbactions.h"
#include "./src/db/fileloader.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

LibraryModel::LibraryModel(QObject *parent) : BaseList(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->dba = DBActions::getInstance();
    this->sortList();

    connect(this, &LibraryModel::sortByChanged, this, &LibraryModel::sortList);
    connect(this, &LibraryModel::orderChanged, this, &LibraryModel::sortList);

    connect(this, &LibraryModel::queryChanged, this, &LibraryModel::setList);
    connect(this, &LibraryModel::sortByChanged, this, &LibraryModel::setList);

    this->fileLoader = new FileLoader;
    connect(this->fileLoader, &FileLoader::finished, [this](int newDocs)
    {
        if(newDocs)
            this->setList();
    });

    this->refreshCollection();
}

void LibraryModel::populateDB(const QStringList &paths)
{
    qDebug() << "Function Name: " << Q_FUNC_INFO
             << "new path for database action: " << paths;
    QStringList newPaths;

    for(auto path : paths)
        if(path.startsWith("file://"))
            newPaths << path.replace("file://", "");
        else
            newPaths << path;

    qDebug()<<"paths to scan"<<newPaths;

    this->fileLoader->requestPath(newPaths);
}


void LibraryModel::refreshCollection()
{
    this->populateDB({/*FMH::DesktopPath,*/ FMH::DownloadsPath, FMH::DocumentsPath, FMH::CloudCachePath});
}

void LibraryModel::setSortBy(const uint &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

uint LibraryModel::getSortBy() const
{
    return this->sort;
}

FMH::MODEL_LIST LibraryModel::items() const
{
    return this->list;
}

void LibraryModel::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    qDebug()<< "setting query"<< this->query;

    emit this->queryChanged();
}

QString LibraryModel::getQuery() const
{
    return this->query;
}

void LibraryModel::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

        switch(role)
        {
        case FMH::MODEL_KEY::SIZE:
        {
            if(e1[role].toDouble() > e2[role].toDouble())
                return true;
            break;
        }

        case FMH::MODEL_KEY::DATE:
        case FMH::MODEL_KEY::ADDDATE:
        case FMH::MODEL_KEY::MODIFIED:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case FMH::MODEL_KEY::TITLE:
        case FMH::MODEL_KEY::PLACE:
        case FMH::MODEL_KEY::FORMAT:
        {
            const auto str1 = QString(e1[role]).toLower();
            const auto str2 = QString(e2[role]).toLower();

            if(str1 < str2)
                return true;
            break;
        }

        default:
            if(e1[role] < e2[role])
                return true;
        }

        return false;
    });
}

void LibraryModel::setList()
{
    emit this->preListChanged();

    this->list = this->dba->getDBData(this->query);

    qDebug()<< "my LIST" << list;
    this->sortList();

    emit this->postListChanged();
}

QVariantMap LibraryModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto pic = this->list.at(index);

    for(auto key : pic.keys())
        res.insert(FMH::MODEL_NAME[key], pic[key]);

    return res;
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
    this->dba->deleteDoc(item[FMH::MODEL_KEY::URL]);
    emit this->postItemRemoved();

    return true;
}

bool LibraryModel::fav(const int &index, const bool &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

    if(this->dba->favDoc(this->list[index][FMH::MODEL_KEY::URL], value))
    {
        this->list[index].insert(FMH::MODEL_KEY::FAV, value ? "1" : "0");
        return true;
    }

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
    this->list << this->dba->getDBData(QString("select * from images where url = '%1'").arg(url));
    emit this->postItemAppended();
}

void LibraryModel::refresh()
{
    this->setList();
}

void LibraryModel::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();
}
