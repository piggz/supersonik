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
    return settings.value(QStringLiteral("settings/") + settingname, def);
}

void Helper::setSetting(const QString &settingname, QVariant val)
{
    settings.setValue(QStringLiteral("settings/") + settingname, val);
}

bool Helper::settingExists(const QString &settingname)
{
    return settings.contains(QStringLiteral("settings/") + settingname);
}

QString Helper::adjustedContent(const int width, const int fontSize, const QString &text)
{
    QString ret(text);
    static QRegularExpression imgRegex(QStringLiteral("<img ((?!width=\"[0-9]+(px)?\").)*(width=\"([0-9]+)(px)?\")?[^>]*>"));

    QRegularExpressionMatchIterator i = imgRegex.globalMatch(ret);
    while (i.hasNext()) {
        QRegularExpressionMatch match = i.next();

        QString imgTag(match.captured());
        if (imgTag.contains(QStringLiteral("wp-smiley")) || imgTag.contains(QStringLiteral("twemoji"))) {
            imgTag.insert(4, QStringLiteral(" width=\"%1\"").arg(fontSize));
        }

        QString widthParameter = match.captured(4);

        if (widthParameter.length() != 0) {
            if (widthParameter.toInt() > width) {
                imgTag.replace(match.captured(3), QStringLiteral("width=\"%1\"").arg(width));
                imgTag.replace(QRegularExpression(QStringLiteral("height=\"([0-9]+)(px)?\"")), QString());
            }
        } else {
            imgTag.insert(4, QStringLiteral(" width=\"%1\"").arg(width));
        }
        ret.replace(match.captured(), imgTag);
    }

    ret.replace(QStringLiteral("<img"), QStringLiteral("<br /> <img"));
    return ret;
}

QString Helper::md5(const QString &input) const
{
    return QString::fromLatin1(QCryptographicHash::hash(input.toLocal8Bit(), QCryptographicHash::Md5).toHex());
}
