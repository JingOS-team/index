/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.9
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

Rectangle {
    id: listViewDelegate

    property string iconSource
    property string fileSize
    property string fileName
    property string fileDate
    property string tagColor
    property bool isFolder
    property int textDefaultSize: theme.defaultFont.pointSize
    property bool checked: _selectionBar.contains(path)
    property bool menuSelect: false
    property string tmpName
    property var clickMouse
    /**
      * draggable :
      */
    property bool draggable: false


    /**
      * pressed :
      */
    signal pressed(var mouse)

    /**
      * pressAndHold :
      */
    signal pressAndHold(var mouse)

    /**
      * clicked :
      */
    signal clicked(var mouse)

    /**
      * rightClicked :
      */
    signal rightClicked(var mouse)

    /**
      * doubleClicked :
      */
    signal doubleClicked(var mouse)

    signal contentDropped(var drop)

    /**
      * toggled :
      */
    signal toggled(bool state)

    width: parent.width
    height: 88

    color: "#FFFFFFFF"
    radius: 20

    Image {
        id: checkStatusImage

        anchors{
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        width: 44
        height: 44

        cache: false
        source:  {
            if(checked) {
                "qrc:/assets/select_all.png"
            }else{
                "qrc:/assets/unselect_rect.png"
            }
        }
        
        visible:  {
            if(root.selectionMode) {
                true
            }else{
                false
            }
        }
    }

    Image {
        id: iconImage

        width: 88
        height: 88

        asynchronous: true
        cache: true
        smooth: false
        sourceSize.width: 88
        sourceSize.height: 88

        fillMode: Image.PreserveAspectCrop
        anchors{
            left:{
                if(root.selectionMode) {
                    checkStatusImage.right
                }else {
                    parent.left
                }
            }
            leftMargin:  {
                if(root.selectionMode) {
                    10
                }else {
                    0
                }
            }
            verticalCenter: parent.verticalCenter
        }

        source: {
            iconSource
        }

        Connections {
            target: leftMenuData
            onRefreshImageSource:  {
                if(iconSource == imagePath) {
                    if(mime.indexOf("image") != -1) {
                        iconImage.source = "qrc:/assets/image_default.png"
                    }else if(mime.indexOf("video") != -1) {
                        iconImage.source = "qrc:/assets/video_default.png"
                    }
                    iconImage.source = imagePath
                }
            }
        }
    }

    Kirigami.Icon {
        height: 88
        width: 88

        isMask: false
        opacity: 0.5
        visible: iconImage.status !== Image.Ready

        anchors.left: root.selectionMode ? checkStatusImage.right : parent.left
        anchors.leftMargin: root.selectionMode ? 10 : 0
        anchors.verticalCenter: parent.verticalCenter

        source:  {
            if(mime.indexOf("image") != -1) {
                "qrc:/assets/image_default.png"
            }else if(mime.indexOf("video") != -1) {
                "qrc:/assets/video_default.png"
            }else {
                "qrc:/assets/default.png"
            }
        }
    }

    Rectangle{
        id:fileNameSize

        anchors{
            left: iconImage.right
            leftMargin: 30
            verticalCenter: parent.verticalCenter
        }
        width: parent.width / 2
        height: fileSizeText.height + fileNameText.height + 13
        color: "transparent"

        TextInput  {
            id: fileNameText
            anchors{
                top: parent.top
            }
            text:   {
                if(fileName.length > maximumLength) {
                    fileName.substring(0, 15) + "..." + fileName.substring(fileName.length - 8, fileName.length)
                }else {
                    fileName
                }
            }
            font.pointSize: textDefaultSize - 3
            color: "black"
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.NoWrap
            clip: true
            maximumLength: 26
            selectionColor: "#FF3C4BE8"

            onEditingFinished: {
                if((fileNameText.text.indexOf("#") != -1)
                || (fileNameText.text.indexOf("/") != -1)
                || (fileNameText.text.indexOf("?") != -1)) {
                    fileNameText.text = tmpName
                    showToast("The file name cannot contain the following characters: '# / ?'")
                }else {
                    var canRename = true
                    var userNotRename = false
                    for(var i = 0; i < currentBrowser.currentFMList.count; i++) {
                        var item = currentFMModel.get(i)
                        if(item.label == fileNameText.text)  {
                            if(item.path != model.path) {
                                canRename = false
                            }else {
                                userNotRename = true
                            }
                            break
                        }
                    }

                    if(!userNotRename) {
                        if(canRename) {
                            Maui.FM.rename(path, fileNameText.text)
                        }else {
                            fileNameText.text = tmpName
                            showToast("The file name already exists.")
                        }
                    }
                }
                root_renameSelectionBar.clear()
            }

            onFocusChanged: {
                if(focus) {
                    tmpName = fileNameText.text
                }
            }
        }

        Text {
            id: fileSizeText

            anchors{
                top: fileNameText.bottom
                topMargin: 13
            }
            text: fileSize

            font.pointSize: textDefaultSize - 5
            color: "#4D000000"

            visible: !(String(root.currentPath).startsWith("trash:/") && model.isdir == "true")
        }
    }

    Rectangle{
        id:tagRect
        anchors{
            right: fileDateText.left
            rightMargin: 10
            verticalCenter: fileDateText.verticalCenter
        }
        width: tagColor !== "" ? 10 : 0
        height: width
        radius: width/2
        color: "#FFFF0000"
    }

    Text {
        id: fileDateText

        anchors{
            right: parent.right
            rightMargin: 44 + 40
            verticalCenter: parent.verticalCenter
        }
        text: fileDate
        font.pointSize:  textDefaultSize - 3
        color: "#4D000000"
    }

    Loader{
        id:rightArrowLoader
        sourceComponent: rightArrowComponent
        active: isFolder
    }
    Component{
        id:rightArrowComponent
        Item{
            width: listViewDelegate.width
            height: listViewDelegate.height
            Image {
                id: rightArrowImage

                anchors{
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: 44
                height: 44
                asynchronous: true
                source: "qrc:/assets/right_arrow.png"
            }
        }
    }

    DropArea {
        id: _dropArea
        anchors.fill: parent
        enabled: listViewDelegate.draggable

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: "blue"
            visible: parent.containsDrag
            opacity: 0.3
        }

        onDropped: {
            listViewDelegate.contentDropped(drop)
        }
    }

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        property bool pressAndHoldIgnored : false
        drag.axis: Drag.XAndYAxis

        onCanceled: {
            if(listViewDelegate.draggable) {
                drag.target = null
            }
        }

        onClicked:  {
            if(mouse.button === Qt.RightButton) {
                listViewDelegate.rightClicked(mouse)
            } else {
                listViewDelegate.color = "#1F767680"
                clickMouse = mouse
                timer.start()
            }
        }

        onDoubleClicked: {
            listViewDelegate.doubleClicked(mouse)
        }

        onPressAndHold : {
                drag.target = null
                listViewDelegate.pressAndHold(mouse)
        }
    }

    Connections {
        target: root_selectionBar

        onUriRemoved: {
            if(uri === model.path)
                listViewDelegate.checked = false
        }

        onUriAdded: {
            if(uri === model.path)
                listViewDelegate.checked = true
        }

        onCleared: listViewDelegate.checked = false
    }

    Connections {
        target: root_renameSelectionBar
        
        onUriRemoved: {
            if(uri === model.path)  {
                fileNameText.focus = false
            }
        }

        onUriAdded: {
            if(uri === model.path) {
                fileNameText.forceActiveFocus()
                fileNameText.selectAll()
            }
        }

        onCleared:  {
            fileNameText.focus = false
        }
    }

    Connections {
        target: root_menuSelectionBar

        onUriRemoved: {
            if(uri === model.path)
                listViewDelegate.color = "#FFFFFFFF"
        }

        onUriAdded:{
            if(uri === model.path)
                listViewDelegate.color = "#1F767680"
        }

        onCleared:  {
            listViewDelegate.color = "#FFFFFFFF"
        }
    }

    Timer {
        id: timer
        
        running: false
        repeat: false
        interval: 50
        onTriggered: {
            listViewDelegate.color = "#FFFFFFFF"
            listViewDelegate.clicked(clickMouse)
        }
    }
}
