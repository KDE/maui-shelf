/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
 * Author: Anthony Granger <grangeranthony@gmail.com>
 *         Stefano Verzegnassi <stefano92.100@gmail.com>
 */

#ifndef PDFIMAGEPROVIDER_H
#define PDFIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <poppler/qt5/poppler-qt5.h>

class PdfImageProvider : public QQuickImageProvider
{
public:
    PdfImageProvider(Poppler::Document *pdfDocument);
    QImage requestImage(const QString & id, QSize * size, const QSize & requestedSize) override;

private:
    Poppler::Document *document;
};

#endif // PDFIMAGEPROVIDER_H
