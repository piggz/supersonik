// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import uk.co.piggz 1.0
import QtMultimedia as QTMM
import Amber.Mpris 1.0
import uk.co.piggz.supersonik

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: root

    width: 600
    height: 800

    // Window title
    // i18nc() makes a string translatable
    // and provides additional context for the translators
    title: i18nc("@title:window", "Supersonik")

    property string _serverURL: ""
    property string _username: ""
    property string _password: ""
    property int mpHeight: mediaPlayer.height

    pageStack {
        defaultColumnWidth: Kirigami.Units.gridUnit * 20
        globalToolBar {
            style: Kirigami.ApplicationHeaderStyle.ToolBar
            showNavigationButtons: if (root.pageStack.currentIndex > 0 || root.pageStack.layers.currentIndex > 0) {
                                       return Kirigami.ApplicationHeaderStyle.ShowBackButton
                                   } else {
                                       return 0
                                   }
        }
    }

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true
        actions: [
            Kirigami.Action {
                text: i18nc("@action:button", "All Albums by Name")
                icon.name: "view-media-album-cover"
                onTriggered: {
                    switchList("alphabeticalByName")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "All Albums by Artist")
                icon.name: "view-media-artist"
                onTriggered: {
                    switchList("alphabeticalByArtist")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Random Albums")
                icon.name: "media-playlist-shuffle"
                onTriggered: {
                    switchList("random")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Favorite Albums")
                icon.name: "view-media-favorite"
                onTriggered: {
                    switchList("starred")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Latest Albums")
                icon.name: "view-media-recent"
                onTriggered: {
                    switchList("newest")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Top Rated Albums")
                icon.name: "view-media-playcount"
                onTriggered: {
                    switchList("highest")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Frequently Played Albums")
                icon.name: "media-playlist-play"
                onTriggered: {
                    switchList("frequent")
                }
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Settings")
                icon.name: "configure"
                onTriggered: {
                    root.pageStack.pushDialogLayer(Qt.resolvedUrl("./pages/SettingsPage.qml"))
                }
            }
        ]
    }

    MediaPlayer {
        id: mediaPlayer
        parent: root.overlay
        width: parent.width
        height: maximised ? parent.height : minHeight
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    MprisPlayer {
        id: mprisPlayer
        serviceName: "supersonik"
        identity: "Supersonik Media Player"

        playbackStatus: {
            console.log("xx", mediaPlayer.playbackState);
            switch (mediaPlayer.playbackState) {
            case QTMM.MediaPlayer.PlayingState:
                return Mpris.Playing
            case QTMM.MediaPlayer.PausedState:
                return Mpris.Paused
            default:
                return Mpris.Stopped
            }
        }

        canControl: true
        canGoNext: mediaPlayer.canGoNext
        canGoPrevious: mediaPlayer.canGoPrevious
        canPause: playbackStatus == Mpris.Playing
        canPlay: playbackStatus != Mpris.Playing
        canSeek: false

        onPlayRequested: mediaPlayer.play()
        onStopRequested: mediaPlayer.stop()
        onPauseRequested: mediaPlayer.pause()
        //onPlayPauseRequested: if (player.playbackState == Audio.PlayingState) { player.pause() } else { player.play() }
        onNextRequested: mediaPlayer.nextTrack()
        onPreviousRequested: mediaPlayer.previousTrack()

        metaData {
            url: mediaPlayer.url
            trackId: mediaPlayer.urrentIndex
            albumTitle: mediaPlayer.currentAlbum
            albumArtist: mediaPlayer.currentArtist
            year: mediaPlayer.currentYear
            title: mediaPlayer.currentTitle
        }
    }

    Component.onCompleted: {
        console.log("Loading Settings");
        _serverURL = Helper.getSetting("serverURL", "");
        _username = Helper.getSetting("username", "");
        _password = Helper.getSetting("password", "");

        if (!_serverURL || !_username || !_password) {
            pageStack.push(Qt.resolvedUrl("./pages/SettingsPage.qml"), {
                               initial: true
                           })
        } else {
            pageStack.push(Qt.resolvedUrl("./pages/MusicFeed.qml"));
        }
    }

    function switchList(type) {
        const musicpage = getMusicPage();

        if (musicpage) {
            musicpage.switchViewType(type);
        }
    }

    function doRequest(url, method, callback) {
        console.log("doRequest:", url, method);

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function (response) {
            return function () {
                if (xhr.readyState === XMLHttpRequest.DONE)
                    callback(response)
            }
        })(xhr)
        xhr.open(method, url, true)
        xhr.send('')
    }

    function buildSubsonicUrl(path) {
        const salt = makeSalt()
        let qry = "?";
        if (path.indexOf("?") > 0) {
            qry = "&";
        }

        return _serverURL + "/rest/" + path + qry + "u=" + _username + "&t=" + Helper.md5(_password + salt) + "&s=" + salt + "&v=1.16.0" + "&c=supersonik"
    }

    function attributeValue(node, attribute) {
        for (var i = 0; i < node.attributes.length; ++i) {
            if (node.attributes[i].name === attribute) {
                return node.attributes[i].value;
            }
        }
        return "";
    }

    function serverError(document) {
        console.log(document.documentElement.childNodes.length);
        for (var i = 0; i < document.documentElement.childNodes.length; ++i) {
            console.log(document.documentElement.childNodes[i].nodeName);
            if (document.documentElement.childNodes[i].nodeName == "error") {
                return attributeValue(document.documentElement.childNodes[i], "message");
            }
        }
        return "Unknown error";
    }

    function makeSalt() {
        const length = 8;
        let result = '';
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        const charactersLength = characters.length;
        let counter = 0;
        while (counter < length) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
            counter += 1;
        }
        return result;
    }

    function getMusicPage() {
        return pageStack.items.find(function(page) {
            return page.uid === "musicpage";
        });
    }
}
