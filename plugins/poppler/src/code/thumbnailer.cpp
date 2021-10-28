#include "thumbnailer.h"
#include <poppler/qt5/poppler-qt5.h>
#include <QImage>
#include <QUrl>

Thumbnailer::Thumbnailer() : QQuickImageProvider(QQuickImageProvider::Image, QQuickImageProvider::ForceAsynchronousImageLoading)

{

}

QImage Thumbnailer::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QScopedPointer<Poppler::Document> document;
    QImage result;

    document.reset( Poppler::Document::load(QUrl::fromUserInput(id).toLocalFile()));

    if(!document || document->isLocked())
    {
        return result;
    }

    // If the requestedSize.width is 0, avoid Poppler rendering
    // FIXME: Actually it works correctly, but an error is anyway shown in the application output.
    if (requestedSize.width() > 0)
    {
        document->setRenderHint(Poppler::Document::Antialiasing);
        document->setRenderHint(Poppler::Document::TextAntialiasing);

        QScopedPointer<Poppler::Page> page;
        page.reset(document->page(0));

        if(!page)
        {
            return result;
        }

        size->setHeight(requestedSize.height());
        size->setWidth(requestedSize.width());

        const qreal fakeDpiX = requestedSize.width() / page->pageSizeF().width() * 72.0;
        const qreal fakeDpiY = requestedSize.height() / page->pageSizeF().height() * 72.0;

        // Preserve aspect fit
        const qreal fakeDpi = std::min(fakeDpiX, fakeDpiY);

        // Render the page to QImage
        result = page->renderToImage(fakeDpi, fakeDpi);

        return result;
    }

    // Requested size is 0, so return a null image.
    return QImage();
}


