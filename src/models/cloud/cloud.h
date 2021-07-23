#ifndef CLOUD_H
#define CLOUD_H

#include <QObject>

class Cloud : public QObject
{
    Q_OBJECT

public:   

    explicit Cloud(QObject *parent = nullptr);

};

#endif // CLOUD_H
