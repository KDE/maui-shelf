#include "library.h"
#include <MauiKit/FileBrowsing/fmstatic.h>

Library *Library::m_instance = nullptr;

Library::Library(QObject *parent) : QObject(parent)
{   
}

Library *Library::instance()
{
    if(m_instance)
    {
        return m_instance;
    }

    m_instance = new Library();
    return m_instance;
}

QVariantList Library::sourcesModel() const
{
    QVariantList res;
    const auto urls = sources();
    for (const auto &url : urls)
    {
        if(FMStatic::fileExists(url))
        {
            res << FMStatic::getFileInfo(url);
        }
    }

    return res;
}

QStringList Library::sources() const
{
    return QStringList({FMStatic::DesktopPath, FMStatic::DownloadsPath, FMStatic::DocumentsPath, FMStatic::CloudCachePath});
}

void Library::openFiles(QStringList files)
{
    QList<QUrl> res;
    for(const auto &file : files)
    {
        const auto url = QUrl::fromUserInput(file);
        if(FMStatic::isDir(url))
        {
            continue;
        }else
        {
            if(FMStatic::checkFileType(FMStatic::FILTER_TYPE::DOCUMENT, FMStatic::getMime(url)))
            {
                res << url;
            }
        }
    }

    emit this->requestedFiles(res);
}

void Library::removeSource(const QString &url)
{

}

void Library::addSource(const QString &url)
{

}

void Library::addSources(const QStringList &urls)
{

}

void Library::rescan()
{

}




