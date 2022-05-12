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

#ifndef PDFDOCUMENT_H
#define PDFDOCUMENT_H

#include <QAbstractListModel>

#include <poppler/qt5/poppler-qt5.h>

#include "pdfitem.h"
#include "pdftocmodel.h"
#include <QUrl>

typedef QList<Poppler::Page*> PdfPagesList;

class PdfDocument : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(PdfDocument)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QUrl path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(int pages READ pageCount NOTIFY pagesCountChanged)
    Q_PROPERTY(int providersNumber READ providersNumber NOTIFY providersNumberChanged)
    Q_PROPERTY(QObject* tocModel READ tocModel NOTIFY tocModelChanged)
    Q_PROPERTY(bool isLocked READ isLocked NOTIFY isLockedChanged FINAL)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged FINAL)
    Q_PROPERTY(QString id READ id CONSTANT FINAL)

public:
    enum Roles {
        WidthRole = Qt::UserRole + 1,
        HeightRole
    };

    explicit PdfDocument(QAbstractListModel *parent = 0);
    virtual ~PdfDocument();

    QUrl path() const { return m_path; }
    void setPath(QUrl &pathName);

    int pageCount() const;
    int providersNumber() const { return m_providersNumber; }

    QHash<int, QByteArray> roleNames() const override;

    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override final;

    Q_INVOKABLE QDateTime getDocumentDate(QString data);
    Q_INVOKABLE QString getDocumentInfo(QString data) const;

    QObject *tocModel() const { return m_tocModel; }

    QString title() const;

    bool isLocked() const;

    bool isValid() const;

    QString id() const;

Q_SIGNALS:
    void pathChanged();
    void error(const QString& errorMessage);
    void pagesLoaded();
    void providersNumberChanged();
    void tocModelChanged();
    void pagesCountChanged();
    void documentLocked();
    void titleChanged();

    void isLockedChanged();

    void isValidChanged();

private slots:
    void _q_populate(PdfPagesList pagesList);

public slots:
    void unlock(const QString &ownerPassword, const QString &password);

private:
    QUrl m_path;
    QString m_id; //id of this document for the provider
    int m_providersNumber;
    int pages;

    bool loadDocument(const QString &pathName, const QString &password = QString(), const QString &userPassword = QString());
    void loadProvider();
    bool loadPages();

    Poppler::Document *m_document;
    QList<PdfItem> m_pages;
    PdfTocModel* m_tocModel;
    bool m_isValid = false;
};

#endif // PDFDOCUMENT_H
