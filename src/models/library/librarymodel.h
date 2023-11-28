#pragma once

#include <QObject>

#include <MauiKit3/Core/fmh.h>
#include <MauiKit3/Core/mauilist.h>

namespace FMH
{
class FileLoader;
}

class LibraryModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QStringList sources READ sources WRITE setSources NOTIFY sourcesChanged RESET resetSources)

public:
    explicit LibraryModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override;
    void componentComplete() override final;

    QStringList sources() const;
    void resetSources();

private:
    FMH::FileLoader *m_fileLoader;
    FMH::MODEL_LIST list;  

    void setList(const QStringList &sources);

    QStringList m_sources;

public Q_SLOTS:
    bool remove(const int &index);
    bool deleteAt(const int &index);
    bool bookmark(const int &index, const int &value);
    void clear();
    void rescan();
    void setSources(QStringList sources);

Q_SIGNALS:
    void sourcesChanged(QStringList sources);
};
