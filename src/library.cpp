#include "library.h"
#include <MauiKit3/FileBrowsing/fmstatic.h>
#include <MauiKit3/Core/utils.h>

Library *Library::m_instance = nullptr;

Library::Library(QObject *parent) : QObject(parent)
{   
    static const auto defaultSources = QStringList({FMStatic::DesktopPath, FMStatic::DownloadsPath, FMStatic::DocumentsPath});

    m_sources = UTIL::loadSettings("Sources", "Settings", defaultSources).toStringList();
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
    for (const auto &url : m_sources)
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
    return m_sources;
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
    m_sources.removeOne(url);

    UTIL::saveSettings("Sources", m_sources, "Settings");
    emit this->sourcesChanged(m_sources);
}

void Library::addSources(const QStringList &urls)
{
    m_sources << urls;
    m_sources.removeDuplicates();

    UTIL::saveSettings("Sources", m_sources, "Settings");
    emit this->sourcesChanged(m_sources);
}





