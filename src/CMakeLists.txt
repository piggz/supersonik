add_executable(supersonik
    qml/components/MediaPlayer.qml)

ecm_add_qml_module(supersonik
    URI
    uk.co.piggz.supersonik
)

target_sources(supersonik
    PRIVATE
    main.cpp
    Helper.cpp
)

ecm_target_qml_sources(supersonik
    SOURCES
    qml/Main.qml
    qml/pages/SettingsPage.qml
    qml/pages/MusicFeed.qml
    qml/components/MediaPlayer.qml
)

target_link_libraries(supersonik
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

install(TARGETS supersonik ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
