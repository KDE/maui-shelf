/*
 * Copyright (C) 2015
 *          Stefano Verzegnassi <verzegnassi.stefano@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "pdftocmodel.h"
#include <QDebug>


PdfTocModel::PdfTocModel(QAbstractListModel *parent):
    QAbstractListModel(parent)
{
//    connect(this, SIGNAL(documentChanged()), this, SLOT(fillModel()));
}

void PdfTocModel::setDocument(Poppler::Document *document)
{
    if (document != m_document) {
        m_document = document;
        Q_EMIT documentChanged();
    }
}

QHash<int, QByteArray> PdfTocModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[PageIndexRole] = "pageIndex";
    roles[LevelRole] = "level";
    return roles;
}

int PdfTocModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return m_entries.count();
}

QVariant PdfTocModel::data(const QModelIndex & index, int role) const
{
    if (index.row() < 0 || index.row() > m_entries.count())
        return QVariant();

    const TocEntry &tocEntry = m_entries.at(index.row());

    switch (role) {
    case TitleRole:
        return tocEntry.title;
    case PageIndexRole:
        return tocEntry.pageIndex;
    case LevelRole:
        return tocEntry.level;
    default:
        return 0;
    }
}

QVariantMap PdfTocModel::get(int index) const
{
    if (index < 0 || index > m_entries.length() - 1) {
        qWarning() << Q_FUNC_INFO << "Index not valid, return undefined";
        return QVariantMap();
    }

    const TocEntry &item = m_entries.at(index);

    QVariantMap map;
    map["title"] = item.title;
    map["pageIndex"] = item.pageIndex;
    map["level"] = item.level;

    return map;
}

void PdfTocModel::fillModel() {
    if (m_entries.count() != 0) {
        m_entries.clear();
        Q_EMIT countChanged();
    }

    if (!m_document->outline().isEmpty()) {
        qDebug() << "[PDF] Parsing toc model";

        recursiveGetEntries(m_document->outline(), 0);
    }
}

void PdfTocModel::recursiveGetEntries(QVector<Poppler::OutlineItem> data, int nodeLevel)
{

    for(const auto &node : data) {

        if(node.isNull())
            continue;

        TocEntry entry;
        entry.title = node.name();
        entry.level = nodeLevel;

        QString dest = node.destination().get()->destinationName();
        if (!dest.isEmpty()) {
            Poppler::LinkDestination dl(dest);
            entry.pageIndex = dl.pageNumber() - 1;
        } else {
            QString destName = node.externalFileName();
            if (!destName.isEmpty()) {
                Poppler::LinkDestination* l = m_document->linkDestination(destName);
                entry.pageIndex = l->pageNumber() - 1;
            }
        }

        m_entries.append(entry);
        Q_EMIT countChanged();

        // Look for children entries
        if(node.hasChildren())
        recursiveGetEntries(node.children(), nodeLevel + 1);
    }
}

PdfTocModel::~PdfTocModel()
{
}
