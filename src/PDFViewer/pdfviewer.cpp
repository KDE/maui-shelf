#include "pdfviewer.h"
#include <QTimer>
#include <QPainter>
#include <qmath.h>
#include <QGraphicsSceneMouseEvent>
#include <QDebug>
#include <QGraphicsItem>


namespace pdf_viewer {
// Compare to floating points value up to a given precision.
// The `log10(precision)`th digit following the comma is guaranteed to be equal.
bool
equalReals(qreal const a, qreal const b, int const precision = 1000);

const qreal PdfViewer::SLIDE_ANIMATION_DURATION = 150.0;
const int PdfViewer::SLIDE_PULL_THRESHOLD = 100;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        PDF Viewer
/////////////////////////////////////////////////////////////////////////////////////////////////////////

PdfViewer::PdfViewer(QQuickItem * const parent)
    : QQuickItem(parent)
    , mStatus(NOT_OPEN)
    , mDocument(Q_NULLPTR)
    , mPage(Q_NULLPTR)
    , mPageNumber(-1)
    , mInfo(new PdfDocument(this))
    , mZoom(fitZoom())
    , mMaxZoom(6)
    , mPageOrientation(ZERO_PI)
    , mRenderTextAntiAliased(false)
    , mSlidingOutPage(false)
    , mSlidingPolynomial(3)
{
    setFlag(QQuickItem::ItemHasContents, true);
    setFlag(QQuickItem::ItemIsFocusScope, true);
    setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton | Qt::MiddleButton);
    setAcceptTouchEvents(true);
    setAcceptHoverEvents(false);
    setSmooth(false); // Anti-aliasing is done by Poppler itself
    setFocus(true);

    connect(this, SIGNAL(widthChanged()), this, SLOT(allocateFramebuffer()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(allocateFramebuffer()));

    connect(this, SIGNAL(sourceChanged()), this, SLOT(requestRenderWholePdf()));
    connect(this, SIGNAL(widthChanged()), this, SLOT(requestRenderWholePdf()));
    connect(this, SIGNAL(heightChanged()), this, SLOT(requestRenderWholePdf()));
    connect(this, SIGNAL(pageNumberChanged()), this, SLOT(requestRenderWholePdf()));
    connect(this, SIGNAL(pageOrientationChanged()), this, SLOT(requestRenderWholePdf()));
    connect(this, SIGNAL(zoomChanged()), this, SLOT(requestRenderWholePdf()));

    connect(this, SIGNAL(widthChanged()), this, SIGNAL(coverZoomChanged()));
    connect(this, SIGNAL(heightChanged()), this, SIGNAL(coverZoomChanged()));
    connect(this, SIGNAL(pageOrientationChanged()), this, SIGNAL(coverZoomChanged()));
    connect(this, SIGNAL(pageNumberChanged()), this, SIGNAL(coverZoomChanged()));

    connect(this, SIGNAL(coverZoomChanged()), this, SLOT(resetToFitPanIfFitZoom()));
    connect(this, SIGNAL(pageNumberChanged()), this, SLOT(resetPageViewToFit()));
}

PdfViewer::~PdfViewer()
{
    // Release resources acquired from Poppler:
    delete mPage;
    delete mDocument;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Document loading
/////////////////////////////////////////////////////////////////////////////////////////////////////////

QString
PdfViewer::source() const
{
    return mSource;
}

void
PdfViewer::setSource(
        QString const &source
)
{
    if(source != mSource)
    {
        // Release page object:
        delete mPage;
        mPage = Q_NULLPTR;

        // Open new document:
        delete mDocument;
        mDocument = Poppler::Document::load(source);

        // Emit new source signal as soon as new document object is retrieved:
        mSource = source;
        mInfo->setInformation(mDocument->title(), mDocument->author(), mDocument->creator(), mDocument->creationDate(), mDocument->modificationDate());
        emit sourceChanged();
        emit infoChanged();

        // Check whether document is valid:
        if(!mDocument)
        {
            setStatus(CANNOT_OPEN_DOCUMENT);
            return;
        }
        if(mDocument->isLocked())
        {
            setStatus(DOCUMENT_IS_LOCKED);
            return;
        }
        if(0 == mDocument->numPages())
        {
            setStatus(NO_PAGES);
            return;
        }
        setStatus(OK);

        // Enable anti-aliased rendering in Poppler:
        mDocument->setRenderHint(Poppler::Document::TextAntialiasing, mRenderTextAntiAliased);

        // Reset page number to zero:
        setPageNumber(0);
    }
}

int
PdfViewer::pageNumber() const
{
    return mPageNumber;
}

void
PdfViewer::setPageNumber(
        int pageNumber
)
{
    if(OK != mStatus)
    {
        return;
    }

    pageNumber = qBound(0, pageNumber, mDocument->numPages() - 1);

    if((pageNumber != mPageNumber) || !mPage)
    {
        mPageNumber = pageNumber;

        delete mPage;
        mPage = mDocument->page(mPageNumber);

        emit pageNumberChanged();
        emit coverZoomChanged();
    }
}

PdfViewer::Status
PdfViewer::status() const
{
    return mStatus;
}

QString
PdfViewer::statusMessage() const
{
    switch (mStatus) {

    case OK:
        return "Okay";

    case NOT_OPEN:
        return "No document opened";

    case NO_PAGES:
        return "Document has no pages";

    case CANNOT_OPEN_DOCUMENT:
        return "Unable to open document";

    case DOCUMENT_IS_LOCKED:
        return "Document is locked";
    }

    return "Undefined status";
}

PdfDocument *PdfViewer::info() const
{
    return mInfo;
}

void
PdfViewer::setStatus(
        PdfViewer::Status const status
)
{
    if(status != mStatus)
    {
        mStatus = status;
        emit statusChanged();
    }
}

QSize
PdfViewer::scaledPageQuad() const
{
    return QSize(pageQuad().width(), pageQuad().height()) * computeScale();
}

QSize PdfViewer::viewport() const
{
    return QSize(qRound(width()), qRound(height()));
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Panning
/////////////////////////////////////////////////////////////////////////////////////////////////////////

QPoint
PdfViewer::pan() const
{
    return mPan;
}

void
PdfViewer::setPan(
        QPoint pan
)
{
    static qreal lastZoom;
    if(mPan != pan || !equalReals(lastZoom, zoom()))
    {
        lastZoom = zoom();

        bool const scrolling = zoom() > fitZoom() && zoom() <= coverZoom();
        bool const hScrolling = scrolling && scaledPageQuad().width() > width();
        bool const vScrolling = scrolling && !hScrolling;

        // Restrict pan at certain zoom levels:
        if(equalReals(zoom(), fitZoom()))
        {
            // You cannot pan the page at all when at fit-zoom:
            pan = fitPan();
        }
        if(hScrolling)
        {
            // The page can only be horizontally scrolled:
            pan.setY(fitPan().y());
        }
        else if(vScrolling)
        {
            // The page can only be vertically scrolled:
            pan.setX(fitPan().x());
        }

        // Prevent scrolling over edges:
        if(zoom() > coverZoom() || vScrolling)
        {
            pan.setY(qMin(pan.y(), -zoomPan().y()));
            pan.setY(qMax(pan.y(), -zoomPan().y() - scaledPageQuad().height() + viewport().height()));
        }
        if(zoom() > coverZoom() || hScrolling)
        {
            pan.setX(qMin(pan.x(), -zoomPan().x()));
            pan.setX(qMax(pan.x(), -zoomPan().x() - scaledPageQuad().width() + viewport().width()));
        }

        int dx = pan.x() - mPan.x();
        int const dy = pan.y() - mPan.y();
        int const w = viewport().width();
        int const h = viewport().height();

        mFramebuffer.scroll(dx, dy, mFramebuffer.rect(), Q_NULLPTR);

        mPan = pan;
        emit panChanged();

        if(dy > 0)
        {
            renderPdfIntoFramebuffer(QRect(0, 0, w, dy));
        }
        if(dy < 0)
        {
            renderPdfIntoFramebuffer(QRect(0, h + dy, w, -dy));
        }
        if(dx > 0)
        {
            renderPdfIntoFramebuffer(QRect(0, 0, dx, h));
        }
        if(dx < 0)
        {
            renderPdfIntoFramebuffer(QRect(w + dx, 0, -dx, h));
        }

        update();
    }
}

QPoint
PdfViewer::fitPan() const
{
    return QPoint(
        qRound(viewport().width() - pageQuad().width() * fitScale()) / 2,
        qRound(viewport().height() - pageQuad().height() * fitScale()) / 2
    );
}

QPoint
PdfViewer::coverPan() const
{
    return QPoint(
                (qRound(pageQuad().width() * (coverScale() - fitScale()))) / 2,
                (qRound(pageQuad().height() * (coverScale() - fitScale()))) / 2);
}

void
PdfViewer::resetToFitPanIfFitZoom()
{
    if(!mSlidingOutPage && equalReals(zoom(), fitZoom()))
    {
        setPan(fitPan());
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Zooming
/////////////////////////////////////////////////////////////////////////////////////////////////////////

qreal
PdfViewer::zoom() const
{
    return mZoom;
}

void
PdfViewer::setZoom(
        qreal zoom
)
{
    zoom = qBound(fitZoom(), zoom, mMaxZoom);
    if(!equalReals(mZoom, zoom))
    {
        mZoom = zoom;
        emit zoomChanged();

        setPan(pan());
    }
}

qreal
PdfViewer::maxZoom() const
{
    return mMaxZoom;
}

void
PdfViewer::setMaxZoom(
        qreal maxZoom
)
{
    maxZoom = qMax(fitZoom(), maxZoom);
    if(!equalReals(mMaxZoom, maxZoom))
    {
        mMaxZoom = maxZoom;
        emit maxZoomChanged();

        // Eventually re-clamp the current zoom:
        setZoom(zoom());
    }
}

qreal
PdfViewer::coverZoom() const
{
    return coverScale() / fitScale();
}

qreal PdfViewer::fitZoom() const
{
    return 1;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Render hints
/////////////////////////////////////////////////////////////////////////////////////////////////////////

bool
PdfViewer::renderTextAntiAliased() const
{
    return mRenderTextAntiAliased;
}

void
PdfViewer::setRenderTextAntiAliased(
        bool const on
)
{
    if(mRenderTextAntiAliased != on) {
        mRenderTextAntiAliased = on;
        emit renderTextAntiAliasedChanged();

        if(mDocument)
        {
            mDocument->setRenderHint(Poppler::Document::TextAntialiasing, mRenderTextAntiAliased);
        }
    }
}

bool
PdfViewer::renderImageAntiAliased() const
{
    return mRenderImageAntiAliased;
}

void
PdfViewer::setRenderImageAntiAliased(
        bool const on
)
{
    if(mRenderImageAntiAliased != on) {
        mRenderImageAntiAliased = on;
        emit renderTextAntiAliasedChanged();

        if(mDocument)
        {
            mDocument->setRenderHint(Poppler::Document::Antialiasing, mRenderImageAntiAliased);
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Background color
/////////////////////////////////////////////////////////////////////////////////////////////////////////

QColor
PdfViewer::backgroundColor() const
{
    return mBackgroundColor;
}

void
PdfViewer::setBackgroundColor(
        QColor const backgroundColor
)
{
    if(backgroundColor != mBackgroundColor)
    {
        mBackgroundColor = backgroundColor;
        emit backgroundColorChanged();
    }
}

void PdfViewer::resetPageViewToFit()
{
    if(mSlidingOutPage) return;
    setZoom(fitZoom());
    setPan(fitPan());
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Orientation
/////////////////////////////////////////////////////////////////////////////////////////////////////////

PdfViewer::PageOrientation
PdfViewer::pageOrientation() const
{
    return mPageOrientation;
}

void
PdfViewer::setPageOrientation(
        PageOrientation orientation
)
{
    orientation = static_cast<PageOrientation>(orientation % (ONE_HALF_PI + 1)); // Two pi equals to zero pi
    while(orientation < 0)
    {
        orientation = static_cast<PageOrientation>(orientation + 4);
    }

    if(mPageOrientation != orientation)
    {
        mPageOrientation = orientation;
        emit pageOrientationChanged();
    }
}

void
PdfViewer::rotatePageClockwise()
{
    setPageOrientation(static_cast<PageOrientation>(pageOrientation() + HALF_PI));
}

void
PdfViewer::rotatePageCounterClockwise()
{
    setPageOrientation(static_cast<PageOrientation>(pageOrientation() - HALF_PI));
}

void PdfViewer::zoomIn(
        qreal const factor
)
{
    setZoom(zoom() * factor);
}

void PdfViewer::zoomOut(
        qreal const factor
)
{
    setZoom(zoom() / factor);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Mouse interaction
/////////////////////////////////////////////////////////////////////////////////////////////////////////

void
PdfViewer::mousePressEvent(
        QGraphicsSceneMouseEvent * const
)
{
    // Simply grab mouse focus
}

void
PdfViewer::mouseReleaseEvent(
        QGraphicsSceneMouseEvent * const
)
{
    // Release mouse focus
}

void
PdfViewer::mouseMoveEvent(
        QGraphicsSceneMouseEvent * const event
)
{
    if(mSlidingOutPage)
    {
        // Page slide animation is running:
        return;
    }

    int const dx = qRound(event->pos().x() - event->lastPos().x());
    int const dy = qRound(event->pos().y() - event->lastPos().y());

    // If zoom is not at fit level, movement means panning:
    if(mZoom > 1.0) {
        setPan(pan() + QPoint(dx, dy));
    }

    // If zoom is at fit level, horizontal movement beyond a certain
    // threshold value will trigger a page slide animation, given that
    // the document has any remaining pages in that direction:
    else if(
            (dx < 0 && pageNumber() < mDocument->numPages() - 1) // User pulls to left, and there are following pages
            || (dx > 0 && pageNumber() > 0))                     // User pulls to right, and there are preceeding pages
    {
        // dx negative => next page
        // dx positive => prev page

        // Accumulate slide gesture, since a certain threshold is necessary to trigger the animation:
        mSlidingPull += dx;
        if(std::abs(mSlidingPull) > SLIDE_PULL_THRESHOLD) {

            // Pre-render the whole page:
            mSlidingImage = mPage->renderToImage(
                        72.0 * computeScale(),
                        72.0 * computeScale(),
                        0,
                        0,
                        scaledPageQuad().width(),
                        scaledPageQuad().height(),
                        static_cast<Poppler::Page::Rotation>(pageOrientation()));

            // Setup animation curve, which will move the current page out at an increasing velocity:
            if(mSlidingPull < 0)
            {
                // Animate slide to next page, so the current page will move leftwards.
                // The curve will start its animation at the fit-pan, not at 0, which would be the left viewport edge,
                // and end when the complete page is hidden left of the left viewport edge:
                mSlidingPolynomial.set(0, fitPan().x(), SLIDE_ANIMATION_DURATION, -scaledPageQuad().width());
            }
            else
            {
                // Animate slide to previous page, so the current page will move rightwards.
                // The curve will start its animation at the fit-pan, not at 0, which would be the left viewport edge,
                // and end when the complete page is hidden right of the right viewport edge:
                mSlidingPolynomial.set(0, fitPan().x(), SLIDE_ANIMATION_DURATION, viewport().width());
            }

            mSlidingOutPage = true;
            mSlidingInPage = false;
            mSlidingTStart = QTime::currentTime();
            startTimer(10);
        }
    }
}

void
PdfViewer::timerEvent(QTimerEvent *event)
{
    // The time since the animation started, corresponds to the x value of the animation polynomial:
    int t = mSlidingTStart.msecsTo(QTime::currentTime());

    // How much the page is shifted at the current time:
    int shift = static_cast<int>(mSlidingPolynomial(t));

    // Paint the pre-rendered page at the current shift position:
    QPainter painter(&mFramebuffer);
    painter.fillRect(0, 0, mFramebuffer.width(), mFramebuffer.height(), mBackgroundColor);
    painter.drawImage(shift, fitPan().y(), mSlidingImage);
    update();

    if(t > SLIDE_ANIMATION_DURATION)
    {
        // Animation finished, stop timer:
        killTimer(event->timerId());

        if(mSlidingInPage) {
            // This was the animation for the next/previous page to slide in, so stop the whole sliding state:
            mSlidingOutPage = false;
            mSlidingInPage = false;
            mSlidingPull = 0;
            return;
        }

        // Otherwise, start to slide in the next/previous page:
        if(mSlidingPull < 0) {
            // Go to next page (implicitly guarenteed that there is one, otherwise the slide animation would
            // not start at all. This time, the curve is flipped, so the start point is steep and the end
            // is the curve extrem-point.
            setPageNumber(pageNumber() + 1);
            mSlidingPolynomial.set(SLIDE_ANIMATION_DURATION, fitPan().x(), 0, viewport().width());
        }
        else {
            setPageNumber(pageNumber() - 1);
            mSlidingPolynomial.set(SLIDE_ANIMATION_DURATION, fitPan().x(), 0, -scaledPageQuad().width());
        }

        mSlidingImage = mPage->renderToImage(
                    72.0 * computeScale(),
                    72.0 * computeScale(),
                    0,
                    0,
                    scaledPageQuad().width(),
                    scaledPageQuad().height(),
                    static_cast<Poppler::Page::Rotation>(pageOrientation()));

        mSlidingTStart = QTime::currentTime();
        mSlidingInPage = true;

        // Start timer again, to slide in page
        startTimer(10);
    }
}

void
PdfViewer::mouseDoubleClickEvent(
        QGraphicsSceneMouseEvent * const
)
{
    if(equalReals(zoom(), fitZoom()))
    {
        // Zoom to cover:
        setZoom(coverZoom());
        setPan(coverPan());
    }
    else
    {
        // Zoom to fit:
        setZoom(fitZoom());
        setPan(fitPan());
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Helper functions
/////////////////////////////////////////////////////////////////////////////////////////////////////////

QSize
PdfViewer::pageQuad() const
{
    if(!mPage)
    {
        return viewport();
    }
    return (mPageOrientation == ZERO_PI) || (mPageOrientation == ONE_PI)
            ? mPage->pageSize() // Take page size as is.
            : QSize(mPage->pageSize().height(), mPage->pageSize().width()); // Swap the page's width and height.
}

qreal
PdfViewer::computeScale() const
{
    return zoom() * fitScale(); // Remember, a zoom of 1 *is defined* as the fit scale.
}

qreal
PdfViewer::fitScale() const
{
    if(!mPage)
    {
        return 1;
    }

    qreal const pageWidth = pageQuad().width();
    qreal const pageHeight = pageQuad().height();
    qreal const pageAspectRatio = pageWidth / pageHeight;

    if(width() > height() * pageAspectRatio)
    {
        return height() / pageHeight;
    }
    else
    {
        return width() / pageWidth;
    }
}

qreal
PdfViewer::coverScale() const
{
    if(!mPage)
    {
        return 1;
    }

    qreal const pageWidth = pageQuad().width();
    qreal const pageHeight = pageQuad().height();
    qreal const pageAspectRatio = pageWidth / pageHeight;

    if(width() > height() * pageAspectRatio)
    {
        return width() / pageWidth;
    }
    else
    {
        return height() / pageHeight;
    }
}

bool
equalReals(
        qreal const a,
        qreal const b,
        int const precision
)
{
    return qRound(a * precision) == qRound(b * precision);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        Pdf rendering
/////////////////////////////////////////////////////////////////////////////////////////////////////////

void
PdfViewer::requestRenderWholePdf()
{
    if(mSlidingOutPage) return;
    mRenderRegion = QRect(0, 0, viewport().width(), viewport().height());
    update();
}

void
PdfViewer::allocateFramebuffer()
{
    if(mFramebuffer.isNull())
    {
        // No framebuffer has been allocated yet, so do that now:
        mFramebuffer = QPixmap(viewport().width(), viewport().height());
    }
    else
    {
        // Resize the current framebuffer instead of creating a new one:
        mFramebuffer = mFramebuffer.scaled(viewport().width(), viewport().height());
    }
}

QPoint PdfViewer::zoomPan() const
{
    return -QPoint(pageQuad().width(),pageQuad().height()) * (computeScale() - fitScale()) / 2;
}

QRect
PdfViewer::visiblePdfRect(
        QRect const viewportSpaceClip
) const
{
    // This rect is equally in size as the final Pdf which would appear on screen:
    QRect const pdfRect(0, 0, scaledPageQuad().width(), scaledPageQuad().height());

    // Transform mapping the document onto it's position on screen:
    QPoint const translation = pan() + zoomPan();

    // Now figure out which rect a currently visible to the user by inverting that transform matrix:
    return viewportSpaceClip.translated(-translation) & pdfRect;
}

void PdfViewer::renderPdfIntoFramebuffer(
        QRect const viewportSpaceRect
)
{
    // If no page is set currently, or no framebuffer is allocated yet, skip:
    if(mFramebuffer.isNull())
    {
        return;
    }

    QRect const visiblePdf = visiblePdfRect(viewportSpaceRect);

    QPainter painter(&mFramebuffer);
    painter.setPen(Qt::transparent);
    painter.setBrush(backgroundColor());
    painter.drawRect(viewportSpaceRect);

    // Painter should start drawing the image at the current clipped visible rect position:
    painter.translate(pan() + zoomPan() + visiblePdf.topLeft());

    if(!mPage)
    {
        return;
    }

    QImage const image = mPage->renderToImage(
                72.0 * computeScale(),
                72.0 * computeScale(),
                visiblePdf.x(),
                visiblePdf.y(),
                visiblePdf.width(),
                visiblePdf.height(),
                static_cast<Poppler::Page::Rotation>(pageOrientation()));

    painter.drawImage(0, 0, image);
}

void PdfViewer::paint(
        QPainter * const painter,
        QStyleOptionGraphicsItem const * const,
        QWidget * const
)
{
    if(!mSlidingOutPage) {
        for(int i = 0; i < mRenderRegion.rectCount(); i++)
        {
            renderPdfIntoFramebuffer(mRenderRegion.rects()[i]);
        }
    }
    // Clean render regions:
    mRenderRegion = QRect();

    QPixmap *pix = new QPixmap("/home/camilo/Downloads/WhatsApp Image 2018-11-30 at 1.15.09 PM.jpeg");
    painter->drawPixmap(10, 10, *pix);
}

}
