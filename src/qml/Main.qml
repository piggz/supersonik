// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import uk.co.piggz 1.0

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: root

    width: 400
    height: 300

    // Window title
    // i18nc() makes a string translatable
    // and provides additional context for the translators
    title: i18nc("@title:window", "Supersonik")

    property string _serverURL: ""
    property string _username: ""
    property string _password: ""

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
        actions: Kirigami.Action {
            text: i18nc("@action:button", "Settings")
            icon.name: "configure"
            onTriggered: {
                root.pageStack.pushDialogLayer(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }
    }

    Component.onCompleted: {
        console.log("Loading Settings");
        _serverURL = Helper.getSetting("serverURL", "");
        _username = Helper.getSetting("username", "");
        _password = Helper.getSetting("password", "");

        if (!_serverURL || !_username || !_password) {
            pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), {
                initial: true
            })
        } else {
            pageStack.push(Qt.resolvedUrl("MusicFeed.qml"))
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
}
