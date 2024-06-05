#pragma once

#include <QObject>
#include <QUrl>

class Library : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(Library)
    Q_PROPERTY(QVariantList sources READ sourcesModel NOTIFY sourcesChanged FINAL)

public:
    static Library * instance();
    QVariantList sourcesModel() const;
    QStringList sources() const;

public Q_SLOTS:
    void openFiles(QStringList files);
    void removeSource(const QString &url);
    void addSources(const QStringList &urls);

    bool isPDF(const QString &url);
    bool isPlainText(const QString &url);
    bool isEpub(const QString &url);
    bool isCommicBook(const QString &url);

private:
    static Library *m_instance;
    explicit Library(QObject *parent = nullptr);
    QStringList m_sources;

Q_SIGNALS:
    void requestedFiles(QList<QUrl> files);
    void sourcesChanged(QStringList sources);

};
