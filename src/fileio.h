#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QDataStream>
#include <QStandardPaths>
#include <QDir>

class FileIO : public QObject
{
    Q_OBJECT

public Q_SLOTS:
    bool write(const QString& source, const QByteArray& data);
    bool rm(const QString& source);

public:
    FileIO() {}
};

#endif // FILEIO_H
