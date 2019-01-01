#ifndef PDFVIEWER_H
#define PDFVIEWER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QRegion>
#include <QPixmap>
#include <QList>
#include <QGraphicsSceneMouseEvent>
#include <QStyleOptionGraphicsItem>

#include "pdfdocument.h"
#include "polynomial.h"

#ifdef STATIC_MAUIKIT
#else
#include <poppler-qt5.h>
#endif

namespace Poppler {
    class Document;
    class Page;
}
class QTimer;

typedef Poppler::Page PdfPage;
typedef QList<Poppler::Page*> PdfPages;

namespace pdf_viewer
{

class PdfViewer : public QQuickItem
{
    Q_OBJECT
      Q_ENUMS(Status PageOrientation)

  public:

      /*!
       * \brief The document file path.
       * To open another document, simply set a new source.
       */
      Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)

      /*!
       * \brief The currently visible page's number, zero based.
       * When changed, page is completely exchanged by another, which may or may not have other dimensions.
       * The page number cannot be larger than the last page number, i.e. decrement of total page count.
       */
      Q_PROPERTY(int pageNumber READ pageNumber WRITE setPageNumber NOTIFY pageNumberChanged)

      /*!
       * \brief The current document status.
       * The status is set to *not opened* as long as no document has
       * tried to be set. If doing so with success, it will be set to *ok*, otherwise it will hold
       * a value indicating the reason for failure.
       * @sa Status, statusMessage
       */
      Q_PROPERTY(Status status READ status NOTIFY statusChanged)

      /*!
       * \brief The current document status reported as a string instead of a numeric constant.
       */
      Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)

      /*!
       * \brief The document information like title or creation date.
       * The information is updates as soon as a new document is set.
       * Exposed information is read-only.
       */
      Q_PROPERTY(pdf_viewer::PdfDocument *info READ info NOTIFY infoChanged)

      /*!
       * \brief The current page orientation, which can be 0π, 0.5π, 1π or 1.5π.
       * Convinient functions can be used to rotate the page relative to its current orientation,
       * as setting this property is absolute.
       * \sa rotatePageClockwise(), rotatePageCounterClockwise()
       */
      Q_PROPERTY(PageOrientation pageOrientation READ pageOrientation WRITE setPageOrientation NOTIFY pageOrientationChanged)

      /*!
       * \brief Controls text anti-aliasing done by Poppler renderer.
       */
      Q_PROPERTY(bool renderTextAntiAliased READ renderTextAntiAliased WRITE setRenderTextAntiAliased NOTIFY renderTextAntiAliasedChanged)

      /*!
       * \brief Controls image anti-aliasing done by Poppler renderer.
       */
      Q_PROPERTY(bool renderImageAntiAliased READ renderImageAntiAliased WRITE setRenderImageAntiAliased NOTIFY renderImageAntiAliasedChanged)

      /*!
       * Rotate page clockwise by π/2 or 45°.
       */
      Q_INVOKABLE void rotatePageClockwise();

      /*!
       * Rotate page counter-clockwise by π/2 or 45°.
       */
      Q_INVOKABLE void rotatePageCounterClockwise();

      /*!
       * \brief The current page pan, i.e. the translation.
       * There are convinient functions to set the pan to special positions, as fit- or cover-pan.
       * @note Panning to fit-pan is only reasonable if page is at fit-zoom. Same semantics applies to cover-pan.
       */
      Q_PROPERTY(QPoint pan READ pan WRITE setPan NOTIFY panChanged)

      /*!
       * \brief The pan at which the page would be centralized at fit zoom.
       */
      Q_PROPERTY(QPointF fitPan READ fitPan NOTIFY coverZoomChanged)

      /*!
       * \brief The pan at which the page should sit when cover zoom is requested.
       */
      Q_PROPERTY(QPointF coverPan READ coverPan NOTIFY coverZoomChanged)

      /*!
       * \brief The current page zoom.
       * Zoom refers to a logical unit, where a zoom of 1 is equiliteral to fit-zoom.
       * Any zoom larger than that scales the page up, increasing the total amount of theoratically rendered page-pixels.
       * A zoom smaller than 1 is not allowed.
       * \sa zoomIn(), zoomOut(), maxZoom, coverZoom, fitZoom
       */
      Q_PROPERTY(qreal zoom READ zoom WRITE setZoom NOTIFY zoomChanged)

      /*!
       * \brief Maximum zoom.
       * \note Minimum zoom is implicitly 1.
       * \attention If the upper zoom limit is smaller than cover-zoom, covering will not work properly, as it is not fully allowed to zoom.
       */
      Q_PROPERTY(qreal maxZoom READ maxZoom WRITE setMaxZoom NOTIFY maxZoomChanged)

      /*!
       * \brief The smallest zoom at which the page would cover the whole viewport.
       */
      Q_PROPERTY(qreal coverZoom READ coverZoom NOTIFY coverZoomChanged)

      /*!
       * \brief The zoom at which the page would fit exactly into the view.
       * Returns always 1.
       */
      Q_PROPERTY(qreal fitZoom READ fitZoom NOTIFY coverZoomChanged)

      /*!
       * \brief The view's background, filling space that is not obscured by the page.
       */
      Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)

      /*!
       * Zoom in by a give factor.
       * \param factor Factor to zoom in.
       */
      Q_INVOKABLE void zoomIn(qreal const factor);

      /*!
       * Zoom out by a give factor.
       * \param factor Factor to zoom out.
       */
      Q_INVOKABLE void zoomOut(qreal const factor);

      /*!
       * \brief The page status.
       */
      enum Status {
          NOT_OPEN,               //!< Initial state the viewer resides in, until the source is set
          OK,                     //!< Everything is okay. Implies that the document pointer is not Q_NULLPTR.
          CANNOT_OPEN_DOCUMENT,   //!< The document cannot be opened, e.g. the path is invalid or the file just doesn't exist
          NO_PAGES,               //!< The document has no pages to display
          DOCUMENT_IS_LOCKED      //!< A password is required to open the document
      };

      /*!
       * \brief The possible page orientations.
       */
      enum PageOrientation {
          ZERO_PI,                //!< 0π, initial state
          HALF_PI,                //!< 0.5π, counter-clockwise
          ONE_PI,                 //!< 1π, headfirst orientation
          ONE_HALF_PI             //!< 1.5π, counter-clockwise
      };

      PdfViewer(QQuickItem * const parent = Q_NULLPTR);

      virtual ~PdfViewer();

      QString source() const;
      int pageNumber() const;
      Status status() const;
      QString statusMessage() const;
      PdfDocument *info() const;
      QPoint pan() const;
      QPoint fitPan() const;
      QPoint coverPan() const;
      qreal zoom() const;
      qreal maxZoom() const;
      qreal coverZoom() const;
      qreal fitZoom() const;
      PageOrientation pageOrientation() const;
      QColor backgroundColor() const;
      bool renderTextAntiAliased() const;
      bool renderImageAntiAliased() const;

  public slots:

      void setSource(QString const &source);
      void setPageNumber(int pageNumber);
      void setPan(QPoint pan);
      void setZoom(qreal zoom);
      void setMaxZoom(qreal maxZoom);
      void setPageOrientation(PageOrientation orientation);
      void setBackgroundColor(QColor const backgroundColor);
      void setRenderTextAntiAliased(bool const on);
      void setRenderImageAntiAliased(bool const on);

  signals:

      void sourceChanged();
      void infoChanged();
      void pageNumberChanged();
      void statusChanged();
      void panChanged();
      void zoomChanged();
      void pageOrientationChanged();
      void coverZoomChanged();
      void maxZoomChanged();
      void backgroundColorChanged();
      void renderTextAntiAliasedChanged();
      void renderImageAntiAliasedChanged();

  protected:

      virtual void paint(QPainter * const painter, QStyleOptionGraphicsItem const * const option, QWidget * const widget);
      virtual void mousePressEvent(QGraphicsSceneMouseEvent * const event);
      virtual void mouseReleaseEvent(QGraphicsSceneMouseEvent * const event);
      virtual void mouseMoveEvent(QGraphicsSceneMouseEvent * const event);
      virtual void mouseDoubleClickEvent(QGraphicsSceneMouseEvent * const event);
      virtual void timerEvent(QTimerEvent *event);

  private slots:

      void setStatus(Status const status);
      QSize pageQuad() const;
      QSize scaledPageQuad() const;
      QSize viewport() const;
      qreal computeScale() const;
      qreal fitScale() const;
      qreal coverScale() const;
      void resetToFitPanIfFitZoom();
      void resetPageViewToFit();
      void requestRenderWholePdf();
      void allocateFramebuffer();
      void renderPdfIntoFramebuffer(QRect const viewportSpaceRect);
      QPoint zoomPan() const;
      QRect visiblePdfRect(QRect const viewportSpaceClip) const;

  private:

      Status mStatus;
      QString mSource;
      Poppler::Document *mDocument;
      Poppler::Page const *mPage;
      int mPageNumber;
      PdfDocument *mInfo;

      QPoint mPan;
      qreal mZoom;
      qreal mMaxZoom;
      PageOrientation mPageOrientation;

      QPixmap mFramebuffer;
      QRegion mRenderRegion;
      QColor mBackgroundColor;
      bool mRenderTextAntiAliased;
      bool mRenderImageAntiAliased;

      int mSlidingPull;
      bool mSlidingOutPage;
      QTime mSlidingTStart;
      Polynomial mSlidingPolynomial;
      QImage mSlidingImage;
      bool mSlidingInPage;

      static const qreal SLIDE_ANIMATION_DURATION;
      static const int SLIDE_PULL_THRESHOLD;

  };
};



#endif // PDFVIEWER_H
