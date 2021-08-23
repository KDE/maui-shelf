#ifndef LIBRARY_H
#define LIBRARY_H

#include <QObject>

class Library : public QObject
{
    Q_OBJECT
public:
    explicit Library(QObject *parent = nullptr);

public slots:
    void openFiles(QStringList files);

signals:
    void requestedFiles(QList<QUrl> files);

public slots:
};

#endif // LIBRARY_H
