#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QQmlContext>
#include <QQuickStyle>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KIconTheme>

#include <QMediaDevices>
#include <QAudioDevice>

#include "Helper.h"
#include "fileio.h"

int main(int argc, char *argv[])
{
    KIconTheme::initTheme();
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("supersonik");
    QApplication::setOrganizationName(QStringLiteral("piggz"));
    QApplication::setOrganizationDomain(QStringLiteral("piggz.co.uk"));
    QApplication::setApplicationName(QStringLiteral("Supersonik"));
    QApplication::setDesktopFileName(QStringLiteral("uk.co.piggz.supersonik"));

    QQuickStyle::setStyle(QStringLiteral("Material"));

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterSingletonType<Helper>("uk.co.piggz", 1, 0, "Helper", [](QQmlEngine *, QJSEngine *) {
        return new Helper;
    });

    qmlRegisterSingletonType<FileIO>("uk.co.piggz", 1, 0, "FileIO", [](QQmlEngine *, QJSEngine *) {
        return new FileIO;
    });

    engine.loadFromModule("uk.co.piggz.supersonik", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    qDebug() << "Audio devices:";
    for (auto d : QMediaDevices::audioOutputs()) {
        qDebug() << d.description();
    }

    qDebug() << "Defualt device:" << QMediaDevices::defaultAudioOutput().description();

    return app.exec();
}
