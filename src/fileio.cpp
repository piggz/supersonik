#include <QRegularExpression>
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

    file.write(data);
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

QString FileIO::makeFilename(QString input)
{  
    QString output = input;
    output.remove(QRegularExpression(QString::fromUtf8("[`~!@#$%^&*()—+=|:;<>«»,?/{}\'\"\\[\\]\\\\]")));
    return output;
}

QString FileIO::findFilePath(const QString &source)
{
    qDebug() << Q_FUNC_INFO << source;
    if (source.isEmpty())
        return QString();

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/cache/");

    QDir d(cacheDir);

    QStringList filter;
    filter << (source + QString::fromUtf8("*"));
    d.setNameFilters(filter);

    if(d.entryList().size() > 0)
    {
        QFile f(cacheDir + d.entryList()[0]);
        if (f.exists()) {
            qDebug() << QLatin1String(f.filesystemFileName().c_str());
            return QLatin1String(f.filesystemFileName().c_str());
        }
    }
    return QString();
}

QString FileIO::filePath(const QString &source)
{
    qDebug() << Q_FUNC_INFO << source;
    if (source.isEmpty())
        return QString();

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/cache/");

    QFile f(cacheDir + source);
    if (f.exists()) {
        qDebug() << QLatin1String(f.filesystemFileName().c_str());
        return QLatin1String(f.filesystemFileName().c_str());
    }
    return QString();
}
