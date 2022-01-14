#ifndef LIBRARYMODEL_H
#define LIBRARYMODEL_H

#include <QObject>

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/mauilist.h>

namespace FMH
{
class FileLoader;
}

class LibraryModel : public MauiList
{
    Q_OBJECT

public:
    explicit LibraryModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override;
    void componentComplete() override final;

private:
    FMH::FileLoader *m_fileLoader;
    FMH::MODEL_LIST list;  

    void setList(const QStringList &sources);

public slots:
    bool remove(const int &index);
    bool deleteAt(const int &index);
    bool bookmark(const int &index, const int &value);
    void clear();
};

#endif // LIBRARYMODEL_H
