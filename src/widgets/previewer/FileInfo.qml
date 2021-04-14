/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.2 as Maui
import QtGraphicalEffects 1.0

Popup {
    property var item : ({})
    property var localPath: ""
    property var fileSize: ""

    id: control
    parent: Overlay.overlay
    width: 550
    height: 732
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle {
        radius: 18
        ShaderEffectSource {
            id: footerBlur

            width: parent.width
            height: parent.height

            visible: false
            sourceItem: wholeScreen
            sourceRect: Qt.rect(control.x, control.y, width, height)
        }

        FastBlur{
            id:fastBlur

            anchors.fill: parent

            source: footerBlur
            radius: 72
            cached: true
            visible: false
        }

        Rectangle{
            id:maskRect

            anchors.fill:fastBlur

            visible: false
            clip: true
            radius: 18
        }
        OpacityMask{
            id: mask
            anchors.fill: maskRect
            visible: true
            source: fastBlur
            maskSource: maskRect
        }

        Rectangle{
            anchors.fill: footerBlur
            color: "#CCF7F7F7"
            radius: 18
        }

        DropShadow {
            anchors.fill: mask
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12.0
            samples: 24
            cached: true
            color: Qt.rgba(0, 0, 0, 0.1)
            source: mask
            visible: true
        }
    }

    Kirigami.Icon {
        id: iconImage
        anchors{
            top: parent.top
            topMargin: 70
            horizontalCenter: parent.horizontalCenter
        }
        width: 140
        height: 140
        source: getIcon(item)
    }

    Text {
        id: fileNameText
        anchors {
            top: iconImage.bottom
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - 100
        text: item.label
        font.pointSize: textDefaultSize - 3
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAnywhere
        maximumLineCount: 2
        elide: Text.ElideRight
        clip: true
    }

    Text {
        id: fileSizeText
        anchors{
            top: fileNameText.bottom
            topMargin: 3
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        text: fileSize
        font.pointSize: textDefaultSize - 5
        color: "#4D000000"

        Connections {
            target: leftMenuData
            onRefreshDirSize:  {
                fileSize = Maui.FM.formatSize(size)
                if(fileSize.indexOf("KiB") != -1) {
                    fileSize = fileSize.replace("KiB", "K")
                }else if(fileSize.indexOf("MiB") != -1) {
                    fileSize = fileSize.replace("MiB", "M")
                }else if(fileSize.indexOf("GiB") != -1) {
                    fileSize = fileSize.replace("GiB", "G")
                }
            }
        }

    }

    Text {
        id: infoNameText
        anchors{
            top: fileSizeText.bottom
            topMargin: 55
            left: parent.left
            leftMargin: 50
        }
        text: "Infomation"
        font.pointSize: textDefaultSize + 6
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        clip: true
    }

    Rectangle{
        id: kindRect
        width: parent.width
        height: 60
        anchors{
            top: infoNameText.bottom
            topMargin: 30
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: "Kind"
            font.pointSize: textDefaultSize - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }

        TextField  {
            anchors{
                right: parent.right
                rightMargin: 50
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle
            {
                color: "#00000000"
            }
            text: item.mime
            horizontalAlignment: Text.AlignRight
            width: parent.width / 5 * 3
            font.pointSize: textDefaultSize - 3
            color: "#4D000000"
            readOnly : true
            selectByMouse: true
        }
    }

    Kirigami.JMenuSeparator { 
        anchors.top: kindRect.bottom
    }

    Rectangle {
        id: createdRect
        width: parent.width
        height: 60
        anchors{
            top: kindRect.bottom
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: "Created"
            font.pointSize: textDefaultSize  - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }

        Text {
            anchors{
                right: parent.right
                rightMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.date), "dd.MM.yyyy")
            font.pointSize: textDefaultSize  - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator { 
        anchors.top: createdRect.bottom
    }

    Rectangle {
        id: modifiedRect
        width: parent.width
        height: 60
        anchors{
            top: createdRect.bottom
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: "Modified"
            font.pointSize: textDefaultSize  - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }

        Text {
            anchors{
                right: parent.right
                rightMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.modified), "dd.MM.yyyy")
            font.pointSize: textDefaultSize  - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator  { 
        anchors.top: modifiedRect.bottom
    }

    Rectangle {
        id: lastopenedRect
        width: parent.width
        height: 60
        anchors{
            top: modifiedRect.bottom
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: "Last opened"
            font.pointSize: textDefaultSize  - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }

        Text {
            anchors{
                right: parent.right
                rightMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.lastread), "dd.MM.yyyy")
            font.pointSize: textDefaultSize  - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator  { 
        anchors.top: lastopenedRect.bottom
    }

    Rectangle {
        id: whereRect
        width: parent.width
        height: 60
        anchors{
            top: lastopenedRect.bottom
        }
        color: "#00000000"

        Text {
            id: whereTextId
            anchors{
                left: parent.left
                leftMargin: 50
                verticalCenter: parent.verticalCenter
            }
            text: "Where"
            font.pointSize: textDefaultSize - 3
            color: "#4D000000"
            elide: Text.ElideRight
        }

        TextField  {
            anchors{
                right: parent.right
                rightMargin: 50
                top: whereTextId.top
                topMargin: -10
            }
            background: Rectangle
            {
                color: "#00000000"
            }
            text: localPath
            horizontalAlignment: Text.AlignRight
            width: parent.width / 5 * 3
            font.pointSize: textDefaultSize - 3
            color: "#4D000000"
            readOnly : true
            selectByMouse: true
        }
    }

    function show(index) {
        if(index == -1) {
            item = Maui.FM.getFileInfo(root.currentPath)
        }else {
            item = root.currentBrowser.currentFMModel.get(index)
        }
        if(item.path.indexOf("file://") >= 0) {
            localPath = item.path.replace("file://", "")
        }else {
            localPath = item.path
        }

        if(item.isdir == "true") {
            leftMenuData.getDirSize(localPath)
        }else  {
            fileSize = Maui.FM.formatSize(item.size)
            if(fileSize.indexOf("KiB") != -1) {
                fileSize = fileSize.replace("KiB", "K")
            }else if(fileSize.indexOf("MiB") != -1) {
                fileSize = fileSize.replace("MiB", "M")
            }else if(fileSize.indexOf("GiB") != -1) {
                fileSize = fileSize.replace("GiB", "G")
            }
        }

        var lastg = localPath.lastIndexOf("/") 
        if(lastg >= 0) {
            localPath = localPath.substring(0, lastg)
        }
        
        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }

    onClosed: {
        leftMenuData.cancelGetDirSize()
    }
}
