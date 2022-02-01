#ifndef LIBRARY_H
#define LIBRARY_H

#include <QObject>

class Library : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(Library)
    Q_PROPERTY(QVariantList sources READ sourcesModel NOTIFY sourcesChanged FINAL)

public:
    static Library * instance();
    QVariantList sourcesModel() const;
    QStringList sources() const;

public slots:
    void openFiles(QStringList files);
    void removeSource(const QString &url);
    void addSources(const QStringList &urls);

private:
    static Library *m_instance;
    explicit Library(QObject *parent = nullptr);
    QStringList m_sources;
signals:
    void requestedFiles(QList<QUrl> files);
    void sourcesChanged(QStringList sources);

};

#endif // LIBRARY_H
