cmake_minimum_required(VERSION 3.20)
project(supersonik)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMFindQmlModule)
include(ECMQmlModule)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    Test
    Gui
    QuickControls2
    Widgets
    Multimedia
)

find_package(KF6 REQUIRED COMPONENTS
    Kirigami
    I18n
    CoreAddons
    ColorScheme
    IconThemes
)

ecm_find_qmlmodule(org.kde.kirigami REQUIRED)

add_subdirectory(src)

if (SAILFISHOS)
    install(PROGRAMS uk.co.piggz.harbour-supersonik.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES harbour-supersonik.png DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/86x86/apps)
else()
    install(PROGRAMS uk.co.piggz.supersonik.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES supersonik.png DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/)
endif()


feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
