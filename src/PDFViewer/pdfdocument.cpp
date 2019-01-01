#include <QDebug>

#include "pdfdocument.h"

namespace pdf_viewer {

PdfDocument::PdfDocument(QObject *parent) : QObject(parent)
{
}

void PdfDocument::setInformation(QString title, QString author, QString creator, QDateTime creationDate, QDateTime modificationDate)
{
    mTitle = title;
    mAuthor = author;
    mCreator = creator;
    mCreationDate = creationDate;
    mModificationDate = modificationDate;
}

QString PdfDocument::title() const
{
    return mTitle;
}

QString PdfDocument::author() const
{
    return mAuthor;
}

QString PdfDocument::creator() const
{
    return mCreator;
}

QDateTime PdfDocument::creationDate() const
{
    return mCreationDate;
}

QDateTime PdfDocument::modificationDate() const
{
    return mModificationDate;
}

} // namespace pdf_viewer
