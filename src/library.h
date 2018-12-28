#ifndef LIBRARY_H
#define LIBRARY_H

#include <QObject>
#include <QVariantMap>

class FileLoader;
class Library : public QObject
{
    Q_OBJECT
public:
    explicit Library(QObject *parent = nullptr);

private:
    FileLoader *fileLoader;

signals:
    void refreshViews(QVariantMap tables);

public slots:
};

#endif // LIBRARY_H
