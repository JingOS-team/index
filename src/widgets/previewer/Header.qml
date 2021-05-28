/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.12


ToolBar {

    property var wallpaperUrl
    Loader{
        id:wallpaperLoader
        // sourceComponent: wallpaperComponent
        active: false
    }

    property var currentname

    position: ToolBar.Header
    hoverEnabled: true
    visible: true
    Kirigami.JIconButton
    {
        id: backImage
        width: 22 + 10
        height: width
        source: "qrc:/assets/image_back.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        onClicked: {
            root.hideImageViewer()
        }
    }

    Text {
        id:name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: backImage.right
        anchors.leftMargin: 8
        text: currentname
        font.pixelSize: 20
        style: Text.Gilroy
        color: 
        {
            "#FFFFFFFF"
        }
        width: parent.width - backImage.width * 2
        elide: Text.ElideRight
    }

    Kirigami.JIconButton
    {
        id: deleteImage
        width: 22 + 10
        height: width
        source: "qrc:/assets/image_delete.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 13
        onClicked: {
            const item = root.currentBrowser.currentFMModel.get(root.imageIndex)
            currentBrowser.moveToTrash(item)
            root.hideImageViewer()
        }
    }

    Kirigami.JIconButton
    {
        id: setWallPaperImage
        width: 22 + 10
        height: width
        source: "qrc:/assets/image_set_wallpaper.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: deleteImage.left
        anchors.rightMargin: 35
        onClicked: {
            openWallpaperView(root.imageUrl)
        }
        
    }

    function openWallpaperView(imageUrl){
        wallpaperUrl = imageUrl
        wallpaperLoader.active = true
    }

    function popWallpaperView(){
        wallpaperLoader.active = false
    }
}
