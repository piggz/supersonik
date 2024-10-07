#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QQuickStyle>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KIconTheme>

#include "Helper.h"

int main(int argc, char *argv[])
{
    KIconTheme::initTheme();
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("supersonik");
    QApplication::setOrganizationName(QStringLiteral("piggz"));
    QApplication::setOrganizationDomain(QStringLiteral("piggz.co.uk"));
    QApplication::setApplicationName(QStringLiteral("Supersonik"));
    QApplication::setDesktopFileName(QStringLiteral("uk.co.piggz.supersonik"));

    QApplication::setStyle(QStringLiteral("breeze"));
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterSingletonType<Helper>("uk.co.piggz", 1, 0, "Helper", [](QQmlEngine *, QJSEngine *) {
        return new Helper;
    });

    engine.loadFromModule("uk.co.piggz.supersonik", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
