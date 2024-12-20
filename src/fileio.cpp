#include "fileio.h"

bool FileIO::write(const QString &source, const QByteArray& data)
{
    qDebug() << Q_FUNC_INFO << source;
    if (source.isEmpty())
        return false;

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/cache/");

    QDir d;
    if (!d.mkpath(cacheDir)) {
        qDebug() << "Unable to creat cache folder";
        return false;
    }
    QFile file(cacheDir + source);
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
    {
        qDebug() << "Unable to open file for write";
        return false;
    }
    QDataStream out(&file);
    out << data;
    file.close();
    return true;
}

bool FileIO::rm(const QString &source)
{
    qDebug() << Q_FUNC_INFO << source;
    if (source.isEmpty())
        return false;

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/cache/");

    QFile f(cacheDir + source);
    if (f.exists()) {
        return f.remove();
    }
    return false;
}
