#ifndef GALLERY_H
#define GALLERY_H

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

private:
    FMH::FileLoader *m_fileLoader;
    FMH::MODEL_LIST list;  

    bool addDoc(const FMH::MODEL &doc);
    void refreshCollection();

public slots:    
    bool update(const int &index, const QVariant &value, const int &role); //deprecrated
    bool update(const QVariantMap &data, const int &index);
    bool update(const FMH::MODEL &pic);
    bool remove(const int &index);
    bool deleteAt(const int &index);
    bool fav(const int &index, const bool &value);
    bool bookmark(const int &index, const int &value);
    void append(const QVariantMap &pic);
    void append(const QString &url);
    void clear();

    void insert(const QString &url);
};

#endif // GALLERY_H
