add_executable(supersonik)

ecm_add_qml_module(supersonik
    URI
    uk.co.piggz.supersonik
    QML_FILES
    qml/Main.qml
    qml/pages/SettingsPage.qml
    qml/pages/MusicFeed.qml
    qml/components/AlbumArt.qml
    qml/components/MediaPlayer.qml
    qml/components/OfflineFiles.qml
    RESOURCES
    qml/pics/cassette.png
    qml/pics/artist.png
    qml/pics/star-outline.png
    qml/pics/star-filled.png
)

target_sources(supersonik
    PRIVATE
    main.cpp
    Helper.cpp
    fileio.cpp
)

target_link_libraries(supersonik
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::Multimedia
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

install(TARGETS supersonik ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
