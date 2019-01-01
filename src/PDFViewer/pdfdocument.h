#ifndef PDFDOCUMENT_H
#define PDFDOCUMENT_H

#include <QObject>
#include <QDateTime>
#include <QString>

#ifndef Q_NULLPTR
#define Q_NULLPTR NULL
#endif // Q_NULLPTR

namespace pdf_viewer {

/*!
 * \class PdfDocument
 * \brief Encapsulates information of a single document, while not having a handle to the document itself.
 * The information is not inteded to be set manually, but rather indirectly by settings a new PDF file
 * through the viewer instance.
 */
class PdfDocument : public QObject
{
    Q_OBJECT

public:

    /*!
     * \brief The document's title. The title has nothing to do with the documents file path or name.
     */
    Q_PROPERTY(QString title READ title NOTIFY informationChanged)

    /*!
     * \brief The document's author.
     */
    Q_PROPERTY(QString author READ author NOTIFY informationChanged)

    /*!
     * \brief The document's creator.
     */
    Q_PROPERTY(QString creator READ creator NOTIFY informationChanged)

    /*!
     * \brief The document's creation date.
     */
    Q_PROPERTY(QDateTime creationDate READ creationDate NOTIFY informationChanged)

    /*!
     * \brief The document's date of last modification.
     */
    Q_PROPERTY(QDateTime modificationDate READ modificationDate NOTIFY informationChanged)

    explicit PdfDocument(QObject *parent = Q_NULLPTR);

    void setInformation(QString title,
                        QString author,
                        QString creator,
                        QDateTime creationDate,
                        QDateTime modificationDate);

    QString title() const;
    QString author() const;
    QString creator() const;
    QDateTime creationDate() const;
    QDateTime modificationDate() const;

signals:

    void informationChanged();

private:

    QString mTitle;
    QString mAuthor;
    QString mCreator;
    QDateTime mCreationDate;
    QDateTime mModificationDate;

};

} // namespace pdf_viewer

#endif // PDFDOCUMENT_H
