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
 *         Stefano Verzegnassi <stefano92.100@gmail.com
 */

#include <QQuickImageProvider>
#include <QDebug>

#include "pdfimageprovider.h"

PdfImageProvider::PdfImageProvider(Poppler::Document *pdfDocument)
    : QQuickImageProvider(QQuickImageProvider::Image, QQuickImageProvider::ForceAsynchronousImageLoading)
    , document(pdfDocument)
{
}

QImage PdfImageProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
{
    // If the requestedSize.width is 0, avoid Poppler rendering
    // FIXME: Actually it works correctly, but an error is anyway shown in the application output.
//    if (requestedSize.width() > 0)
//    {
    qDebug() << "REQUESTED PDF" << id ;

        const QString type = id.section("/", 0, 0);
        QImage result;
        Poppler::Page *page;

        if (type == "page")
        {
            int numPage = id.section("/", 1, 1).toInt();

            // Useful for debugging, keep commented unless you need it.
              qDebug() << "Page" << numPage + 1 << "requested";

//            if(numPage + 1 > document->numPages())
//                numPage = 0;

            page = document->page(numPage);
            if(!page)
            {
                return result;
            }

            size->setHeight(page->pageSize().height());
            size->setWidth(page->pageSize().width());

            QSizeF pageSizePhys;
            QSizeF pageSize = page->pageSizeF();

            pageSizePhys.setWidth(pageSize.width() / 72);
            pageSizePhys.setHeight(pageSize.height() / 72);

            auto resH = (requestedSize.isValid() ? requestedSize.height() : size->height()) / pageSizePhys.height() ;
            auto resW = (requestedSize.isValid() ? requestedSize.width() : size->width()) / pageSizePhys.width() ;
            // Useful for debugging, keep commented unless you need it.

//            qDebug() << "Requested size :" << requestedSize.width() << ";" << requestedSize.height();
//            qDebug() << "Size 1:" << size->width() << ";" << size->height();
//            qDebug() << "Size :" << pageSizePhys.width() << ";" << pageSizePhys.height();
//            qDebug() << "Resolution :" << res;


            // Render the page to QImage
            result = page->renderToImage(resW, resH);

        }

//    }

    // Requested size is 0, so return a null image.
    return result;
}
