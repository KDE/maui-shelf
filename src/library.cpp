#include "library.h"
#include <MauiKit/FileBrowsing/fmstatic.h>

Library::Library(QObject *parent) : QObject(parent)
{   
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




