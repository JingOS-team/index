/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import Qt.labs.settings 1.0
import QtQml.Models 2.3

import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.index 1.0 as Index
import jingos.display 1.0
import "titlebar"

Rectangle {
    id: rightRect
    property alias rightCurrentTab:_browserList.currentItem
    property alias currentPageContent:_browserList
    property alias musicPageview: musicPage
    property alias nullPageView: nullPage
    FileTopBarView  {
        id: topRect
        visible: {
            if (selectionMode) {
                false
            } else {
                true
            }
        }
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 78 * appScaleSize
        color: "#00ff0000"
    }

    FileEditBarView {
        id: editRect
        visible: {
            if (selectionMode && !String(root.currentPath).startsWith(
                        "trash:/")) {
                true
            } else {
                false
            }
        }

        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 78 * appScaleSize
        color: "#00000000"
    }

    FileTrashBarView {
        visible: {
            if (selectionMode && String(root.currentPath).startsWith(
                        "trash:/")) {
                true
            } else {
                false
            }
        }

        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 78 * appScaleSize
        color: "#00000000"
   }

    ListView
    {
        id: _browserList
        anchors.top: parent.top
        anchors.topMargin: 85 * appScaleSize
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        height: parent.height

        clip: true
        focus: true

        model: tabsObjectModel
        spacing: 0
        boundsBehavior: Flickable.StopAtBounds

        MouseArea
        {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            propagateComposedEvents: true
            onClicked: {
                if (mouse.button == Qt.RightButton) {

                    if (mouse.x <= 90
                            || mouse.x >= _browserList.width - 90) {
                        if (String(root.currentPath).startsWith(
                                    "trash:/")) {
                            var realMap = mapToItem(wholeScreen,
                                                    mouse.x, mouse.y)
                            menuX = realMap.x
                            menuY = realMap.y
                            currentBrowser.trashNormalMenu.show(
                                        _browserList)
                        } else if (!isSpecialPath) {
                            var realMap = mapToItem(wholeScreen,
                                                    mouse.x, mouse.y)
                            menuX = realMap.x
                            menuY = realMap.y
                            currentBrowser.browserMenu.show()
                        }
                    } else {
                        mouse.accepted = false
                    }
                } else if (mouse.button == Qt.LeftButton) {
                    if (selectionMode
                            || (mouse.x > 90
                                && mouse.x < _browserList.width - 90)) {
                        mouse.accepted = false
                    }
                }
            }

            onPressAndHold: {
                if (mouse.x <= 90
                        || mouse.x >= _browserList.width - 90) {
                    if (String(root.currentPath).startsWith(
                                "trash:/")) {
                        var realMap = mapToItem(wholeScreen,
                                                mouse.x, mouse.y)
                        menuX = realMap.x
                        menuY = realMap.y
                        currentBrowser.trashNormalMenu.show(
                                    _browserList)
                    } else if (!isSpecialPath) {
                        var realMap = mapToItem(wholeScreen,
                                                mouse.x, mouse.y)
                        menuX = realMap.x
                        menuY = realMap.y
                        currentBrowser.browserMenu.show()
                    }
                } else {
                    mouse.accepted = false
                }
            }

            onPressed: {
                if (mouse.button == Qt.RightButton) {
                    if (mouse.x <= 60 || mouse.x >= 1425) {

                    } else {
                        mouse.accepted = false
                    }
                } else if (mouse.button == Qt.LeftButton) {
                    if (mouse.x > 60 && mouse.x < 1425) {
                        mouse.accepted = false
                    }
                }
            }

            onReleased: {
                if (mouse.button == Qt.RightButton) {
                    if (mouse.x <= 60 || mouse.x >= 1425) {

                    } else {
                        mouse.accepted = false
                    }
                } else if (mouse.button == Qt.LeftButton) {
                    if (mouse.x > 60 && mouse.x < 1425) {
                        mouse.accepted = false
                    }
                }
            }
        }
    }

    Item
    {
        id: nullPage
        visible: isNothingHere
        anchors.top: parent.top
        anchors.topMargin: 140 * appScaleSize
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        height: parent.height

        Kirigami.Icon {
            id: emptyImage
            anchors.top: parent.top
            anchors.topMargin: wholeScreen.height / 3.55
            anchors.horizontalCenter: parent.horizontalCenter
            width: 60 * appScaleSize
            height: 60 * appScaleSize
            source: "qrc:/assets/empty.png"
            color: Kirigami.JTheme.majorForeground
        }

        Text {
            anchors {
                top: emptyImage.bottom
                topMargin: 15 * appScaleSize
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (searchState) {
                    i18n("No Results")
                } else {
                    i18n("There are no files at present.")
                }
            }
            font.pixelSize: 14 * appFontSize
            color: Kirigami.JTheme.minorForeground
        }
    }

    Kirigami.JMusicView {
        id: musicPage
        visible: false
        anchors.bottom: parent.bottom
        onBackBtnClick: {
            musicPage.resetList()
            musicPage.setPause(false)
            visible = false
        }
        onVisibleChanged: {
            inx.setEnableBackground(visible)
        }
    }
}
