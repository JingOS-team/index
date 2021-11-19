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
import "../"

Rectangle {
    id: topRect

    Kirigami.JIconButton
    {
        id: backImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        anchors.left: parent.left
        anchors.leftMargin: 12 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/assets/back_arrow.png"
        color: Kirigami.JTheme.majorForeground
        visible: {
            if (isMenuPath && !searchState
                    && !currentTab.currentItem.previewerVisible) {
                false
            } else {
                true
            }
        }
        onClicked: {
            if (currentTab.currentItem.previewerVisible) {
                currentTab.currentItem.popPreviewer()
                if (searchState) {
                    currentTitle = i18n("Search")
                } else {
                    currentTitle = getCurrentTitle(
                                currentBrowser.currentPath)
                }
            } else if (searchState)
            {
                currentBrowser.refreshCurrentPath()
                searchState = false
                searchRect.focus = false
                currentTitle = getCurrentTitle(
                            currentBrowser.currentPath)
            } else {
                currentBrowser.goBack()
            }
        }
    }

    Text
    {
        id: contentTitle
        text: {
            currentTitle
        }
        elide: Text.ElideRight
        color: Kirigami.JTheme.majorForeground
        font {
            pixelSize: 20 * appFontSize
            bold: true
        }
        visible: true
        width: parent.width / 3
        anchors.left: parent.left
        anchors.leftMargin: 44 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter
    }

    Kirigami.JIconButton {
        id: searchImage
        visible: {
            if (currentTab.currentItem.previewerVisible
                    || searchState) {
                false
            } else {
                true
            }
        }
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        source: {
            "qrc:/assets/search_icon.png"
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 21 * appScaleSize
        onClicked: {
            searchState = true
            currentTitle = i18n("Search")
            searchRect.clear()
            searchRect.forceActiveFocus()
        }
    }

    Kirigami.JIconButton {
        id: menuListImage
        visible: {
            if (currentTab.currentItem.previewerVisible
                    || searchState) {
                false
            } else {
                true
            }
        }
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        source: {
            if (settings.viewType == 0) {
                "qrc:/assets/menu_grid.png"
            } else {
                "qrc:/assets/menu_list.png"
            }
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: searchImage.left
        anchors.rightMargin: 35 * appScaleSize
        onClicked: {
            customPopup.show(
                        wholeScreen.width - (190 + 20) * appScaleSize,
                        93 * appScaleSize)
        }
    }

    Kirigami.JIconButton {
        id: addFolderImage
        visible: {
            if (String(root.currentPath).startsWith("trash:/")
                    || currentTab.currentItem.previewerVisible
                    || searchState || isSpecialPath) {
                false
            } else {
                true
            }
        }
        width: visible ? (22 + 10) * appScaleSize : 0
        height: (22 + 10) * appScaleSize
        source: {
            "qrc:/assets/add_folder.png"
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: menuListImage.left
        anchors.rightMargin: 35 * appScaleSize
        onClicked: {
            addFolderImage.forceActiveFocus()
            newFolderPath = leftMenuData.createDir(
                        currentBrowser.currentPath,
                        i18n("Untitled Folder"))
            isCreateFolfer = true
        }
    }

    AnimatedImage {
        id: pasteAnimated
        width: 22 * appScaleSize
        height: 22 * appScaleSize
        anchors.right: deleteAllImage.visible ? deleteAllImage.left : addFolderImage.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 35 * appScaleSize
        source: isDarkTheme ? "qrc:/assets/paste_black.gif" : "qrc:/assets/paste.gif"

        visible: menuListImage.visible & Index.ProcessModel.isCopying
        opacity: playing ? 1 : 0
        playing: menuListImage.visible & Index.ProcessModel.isCopying
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }
        onVisibleChanged: {
            if (!visible) {
                processShowView.close()
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var globalItem = mapToItem(wholeScreen,
                                           mouse.x, mouse.y)
                processShowView.x = globalItem.x - processShowView.width
                processShowView.y = globalItem.y
                if (processShowView.opened) {
                    processShowView.close()
                } else {
                    processShowView.open()
                }
            }
        }
    }
    ProcessView {
        id: processShowView
    }

    Kirigami.JIconButton {
        id: deleteAllImage
        visible: {
            if (String(root.currentPath).startsWith("trash:/")
                    && !searchState) {
                true
            } else {
                false
            }
        }
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        source: {
            "qrc:/assets/select_delete_all.png"
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: menuListImage.left
        anchors.rightMargin: 35 * appScaleSize
        onClicked: {
            if (root.currentBrowser.currentFMList.count > 1) {
                jDialog.text = i18n(
                            "Are you sure you want to delete these files?")
            } else {
                jDialog.text = i18n(
                            "Are you sure you want to delete the file?")
            }
            jDialogType = 2
            jDialog.open()
        }
    }

    Kirigami.JSearchField
    {
        id: searchRect

        visible: searchState
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 28 * appScaleSize

        width: 314 * appScaleSize

        focus: false
        placeholderText: ""
        Accessible.name: i18n("Search")
        Accessible.searchEdit: true
        // focusSequence: "Ctrl+F"
        font.pixelSize: 17 * appFontSize

        onRightActionTrigger:
        {
            searchState = false
            searchRect.focus = false
            currentTitle = getCurrentTitle(
                        currentBrowser.currentPath)
        }

        onTextChanged: {
            searchTimer.stop()
            searchText = text
            searchTimer.start()
        }
    }
}
