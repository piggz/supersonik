#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QSettings>

class Helper : public QObject
{
    Q_OBJECT
public:
    explicit Helper(QObject *parent = nullptr);

public Q_SLOTS:
    QVariant getSetting(const QString &settingname, QVariant def);

    void setSetting(const QString& settingname, QVariant val);
    bool settingExists(const QString &settingname);

    QString adjustedContent(const int width, const int fontSize, const QString &text);

    QString md5(const QString &input) const;

private:
    QSettings settings;

};

#endif // HELPER_H
