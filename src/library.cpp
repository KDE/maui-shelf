#include "library.h"
#include <MauiKit/FileBrowsing/fmstatic.h>

Library::Library(QObject *parent) : QObject(parent)
{   
}

void Library::openFiles(QList<QUrl> files)
{
    QList<QUrl> res;
    for(const auto &file : files)
    {
        if(FMStatic::isDir(file))
        {
            continue;
        }else
        {
            if(FMStatic::checkFileType(FMStatic::FILTER_TYPE::DOCUMENT, FMStatic::getMime(file)))
            {
                res << file;
            }
        }
    }

    emit this->requestedFiles(res);
}




