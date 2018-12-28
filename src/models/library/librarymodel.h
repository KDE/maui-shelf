#ifndef GALLERY_H
#define GALLERY_H

#include <QObject>
#include "./src/models/baselist.h"

class FileLoader;
class DBActions;
class LibraryModel : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(uint sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:
    explicit LibraryModel(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const override;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const uint &sort);
    uint getSortBy() const;

private:
    DBActions *dba;
    FileLoader *fileLoader;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    QString query;
    uint sort = FMH::MODEL_KEY::DATE;

    bool addDoc(const FMH::MODEL &doc);
    void refreshCollection();


signals:
    void queryChanged();
    void orderChanged();
    void sortByChanged();

public slots:    
    QVariantMap get(const int &index) const override;
    bool update(const int &index, const QVariant &value, const int &role) override; //deprecrated
    bool update(const QVariantMap &data, const int &index) override;
    bool update(const FMH::MODEL &pic) override;
    bool remove(const int &index) override;
    bool deleteAt(const int &index);
    bool fav(const int &index, const bool &value);
    void append(const QVariantMap &pic);
    void append(const QString &url);
    void refresh();
    void clear();

    void populateDB(const QStringList &paths);

};

#endif // GALLERY_H
