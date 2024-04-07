/*
 *   Copyright 2018 Marian Arlt <marianarlt@icloud.com>
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.15
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import SddmComponents 2.0
import "components"

Rectangle {
    id: root

    property string notificationMessage
    property string generalFontColor: config.FontColor ? config.FontColor : 'white'
    property int generalFontSize: config.FontPointSize ? config.FontPointSize : root.height / 80

    width: config.ScreenWidth
    height: config.ScreenHeight

    TextConstants {
        id: textConstants
    }

    Repeater {
        model: screenModel

        Wallpaper {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height
            imageSource: config.background
        }

    }

    ColumnLayout {
        id: container

        anchors.fill: parent
        LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        RowLayout {
            id: header

            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: false
            Layout.topMargin: generalFontSize
            Layout.rightMargin: generalFontSize * 1.5

            KeyboardLayoutButton {
                Layout.topMargin: -1
                implicitHeight: clockLabel.height * 1.2
                implicitWidth: clockLabel.height * 1.8
            }

            Item {
                id: clock

                Layout.fillHeight: true
                Layout.minimumWidth: clockLabel.width
                Component.onCompleted: {
                    clockLabel.updateTime();
                }

                Label {
                    id: clockLabel

                    function updateTime() {
                        text = new Date().toLocaleString(Qt.locale("it_IT"), "dd/MM/yyyy hh:mm");
                    }

                    color: generalFontColor
                    font.pointSize: root.generalFontSize
                    renderType: Text.QtRendering
                }

                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    onTriggered: {
                        clockLabel.updateTime();
                    }
                }

            }

        }

        StackView {
            id: loginFormStack

            Layout.fillHeight: true
            Layout.fillWidth: true
            focus: true

            initialItem: LoginForm {
                id: userListComponent

                userListModel: userModel
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                usernameFontSize: root.generalFontSize
                usernameFontColor: root.generalFontColor
                faceSize: config.AvatarPixelSize ? config.AvatarPixelSize : root.width / 15
                showUserList: {
                    if (!userListModel.hasOwnProperty("count") || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                        return (userList.y + loginFormStack.y) > 0;

                    if (userListModel.count == 0)
                        return false;

                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + loginFormStack.y) > 0;
                }
                notificationMessage: {
                    var text = "";
                    text += root.notificationMessage;
                    return text;
                }
                onLoginRequest: {
                    root.notificationMessage = "";
                    sddm.login(username, password, sessionMenu.currentIndex);
                }
                actionItems: [
                    ActionButton {
                        iconSource: "assets/suspend.svg"
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        iconSize: root.generalFontSize * 3

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: root.generalFontSize * 3 + 10
                            text: config.translationSuspend ? config.translationSuspend : "Suspend"
                            color: root.generalFontColor
                            font.pointSize: root.generalFontSize
                        }

                    },
                    ActionButton {
                        iconSource: "assets/reboot.svg"
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        iconSize: root.generalFontSize * 3

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: root.generalFontSize * 3 + 10
                            text: config.translationReboot ? config.translationReboot : textConstants.reboot
                            color: root.generalFontColor
                            font.pointSize: root.generalFontSize
                        }

                    },
                    ActionButton {
                        iconSource: "assets/shutdown.svg"
                        onClicked: sddm.powerOff()
                        enabled: sddm.canPowerOff
                        iconSize: root.generalFontSize * 3

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: root.generalFontSize * 3 + 10
                            text: config.translationPowerOff ? config.translationPowerOff : textConstants.shutdown
                            color: root.generalFontColor
                            font.pointSize: root.generalFontSize
                        }

                    }
                ]
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: 150
                }

            }

        }

        Loader {
            id: inputPanel

            property bool keyboardActive: item ? item.active : false

            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }

            state: "hidden"
            onKeyboardActiveChanged: {
                if (keyboardActive)
                    state = "visible";
                else
                    state = "hidden";
            }
            source: "components/VirtualKeyboard.qml"
            states: [
                State {
                    name: "visible"

                    PropertyChanges {
                        target: loginFormStack
                        y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                    }

                    PropertyChanges {
                        target: inputPanel
                        y: root.height - inputPanel.height
                        opacity: 1
                    }

                },
                State {
                    name: "hidden"

                    PropertyChanges {
                        target: loginFormStack
                        y: 0
                    }

                    PropertyChanges {
                        target: inputPanel
                        y: root.height - root.height / 4
                        opacity: 0
                    }

                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"

                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: loginFormStack
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }

                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }

                        }

                    }

                },
                Transition {
                    from: "visible"
                    to: "hidden"

                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: loginFormStack
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }

                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }

                        }

                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }

                    }

                }
            ]

            anchors {
                left: parent.left
                right: parent.right
            }

        }

        RowLayout {
            id: footer

            Layout.fillHeight: false
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: generalFontSize
            Layout.leftMargin: generalFontSize * 1.5

            SessionMenu {
                id: sessionMenu

                rootFontSize: root.generalFontSize
                rootFontColor: root.generalFontColor
            }

        }

        Connections {
            target: sddm
            onLoginFailed: {
                notificationMessage = textConstants.loginFailed;
                notificationResetTimer.start();
            }
        }

        Timer {
            id: notificationResetTimer

            interval: 3000
            onTriggered: notificationMessage = ""
        }

    }

}
