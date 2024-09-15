// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-FileCopyrightText: 2023 Adam Pigg <adam@piggz.co.uk>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import uk.co.piggz 1.0

Kirigami.ScrollablePage {
    id: page

    property bool initial: false
    property string _serverMessage: ""

    title: i18n("Supersonik Media Player")

    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        width: parent.width

        FormCard.FormCard {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true


            FormCard.FormHeader {
                title: i18n("Supersonic Settings")
            }

            FormCard.FormTextFieldDelegate {
                id: txtServerURL
                label: i18n("Subsonic Server Url:")
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoPredictiveText
                onAccepted: txtUsername.forceActiveFocus();
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextFieldDelegate {
                id: txtUsername
                label: i18n("Username:")
                onAccepted: txtPassword.forceActiveFocus();
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextFieldDelegate {
                id: txtPassword
                label: i18n("Password:")
                onAccepted: done.clicked();
                echoMode: TextInput.PasswordEchoOnEdit
            }

            FormCard.FormDelegateSeparator { above: btnContinue }

            FormCard.FormButtonDelegate {
                id: btnContinue
                text: i18n("Connect")
                onClicked: {
                    _serverURL = txtServerURL.text;
                    _username = txtUsername.text;
                    _password = txtPassword.text;

                    saveSettings();

                    doRequest(buildSubsonicUrl("ping.view"), "GET", parsePing );
                }
            }

            FormCard.FormDelegateSeparator {}

            FormCard.FormTextDelegate {
                id: txtServerMessage
                text: _serverMessage
            }

        }
    }

    Component.onCompleted: {
        loadSettings();
    }

    function parsePing(xhr) {
        var doc = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText, doc.documentElement.tagName, doc.documentElement.attributes.length);

        if (attributeValue(doc.documentElement, "status") === "ok") {
            console.log("Ping Ok");
            if (page.initial) {
                applicationWindow().pageStack.replace(Qt.resolvedUrl("MusicFeed.qml"))
                musicpage.refresh();
            } else {
                page.closeDialog();
            }
        } else {
            console.log("Ping failed");
            _serverMessage = serverError(doc);
        }
    }

    function loadSettings() {
        console.log("Loading Settings");
        _serverURL = Helper.getSetting("serverURL", "");
        _username = Helper.getSetting("username", "");
        _password = Helper.getSetting("password", "");

        console.log(_serverURL, _username, _password);

        if (_serverURL != "") {
            txtServerURL.text = _serverURL;
        }

        if (_username != "") {
            txtUsername.text = _username;
        }

        if (_password != "") {
            txtPassword.text = _password;
        }
    }

    function saveSettings() {
        console.log("Saving Settings");
        Helper.setSetting("serverURL", _serverURL);
        Helper.setSetting("username", _username);
        Helper.setSetting("password", _password);

        console.log(_serverURL, _username, _password);
    }
}
