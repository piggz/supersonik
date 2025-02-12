#include "Helper.h"
#include <QDebug>
#include <QRegularExpression>
#include <QCryptographicHash>

Helper::Helper(QObject *parent) :
    QObject(parent)
{
}

QVariant Helper::getSetting(const QString &settingname, QVariant def)
{
    QVariant v = settings.value(QStringLiteral("settings/") + settingname, def);
    if (v.toString().toLower() == QStringLiteral("false") || v.toString().toLower() == QStringLiteral("true")) {
        return v.toBool();
    }
    return v;
}

void Helper::setSetting(const QString &settingname, QVariant val)
{
    settings.setValue(QStringLiteral("settings/") + settingname, val);
}

bool Helper::settingExists(const QString &settingname)
{
    return settings.contains(QStringLiteral("settings/") + settingname);
}

QString Helper::md5(const QString &input) const
{
    return QString::fromLatin1(QCryptographicHash::hash(input.toLocal8Bit(), QCryptographicHash::Md5).toHex());
}
