/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.9
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.14

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
    property bool isRename: _renameSelectionBar.contains(path)
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

    radius: 20
    color: "#FFFFFFFF"

    Item {
        id:iconItem

        anchors{
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: 140
        height: width

        Image  {
            id: iconImage

            asynchronous: true
            cache: true
            smooth: false
            width: 140
            height: width

            sourceSize.width: 140
            sourceSize.height: 140

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            fillMode: Image.PreserveAspectCrop
            
            source:  {
                iconSource
            }

            layer.enabled: Maui.Style.radiusV
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: iconImage.width
                    height: iconImage.height
                    
                    Rectangle  {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, iconImage.paintedWidth)
                        height: Math.min(parent.height, iconImage.paintedHeight)
                        radius: Maui.Style.radiusV
                    }
                }
            }

            Connections  {
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
            visible: iconImage.status !== Image.Ready
            anchors.centerIn: iconItem.centerIn
            height: width
            width: 140
            source:  {
                if(mime.indexOf("image") != -1) {
                     "qrc:/assets/image_default.png"
                }else if(mime.indexOf("video") != -1) {
                    "qrc:/assets/video_default.png"
                }else {
                    "qrc:/assets/default.png"
                }
            }
            isMask: false
            opacity: 0.5
        }
    }

    Rectangle{
        id:fileNameSize

        anchors{
            top: iconItem.bottom
            topMargin: 5
            horizontalCenter : iconItem.horizontalCenter
        }
        width: parent.width
        height: fileNameText.contentHeight + fileSizeText.contentHeight + 4
        color: "transparent"

        Image {
            id: checkStatusImage

            anchors{
                left: parent.left
                top: fileNameText.top
                topMargin: -10
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
                }else {
                    false
                }
            }
        }

        Rectangle {
            id:tagRect

            anchors{
                left: parent.left
                leftMargin: 10
                verticalCenter: fileNameText.verticalCenter
            }
            width: tagColor !== "" ? 10 : 0
            height: width
            radius: width/2
            color: tagColor
        }

        TextInput {
            id: fileNameText

            anchors {
                top: parent.top
                left: {
                    if(tagRect.width > 0)  {
                        tagRect.right
                    }else if(root.selectionMode) {
                        checkStatusImage.right
                    }else  {
                        parent.left
                    }
                }
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 5

            text: {
                if(fileName.length > maximumLength) {
                    fileName.substring(0, 15) + "..." + fileName.substring(fileName.length - 8, fileName.length)
                }else {
                    fileName
                }
            } 
            font.pointSize: textDefaultSize - 3
            color: "black"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAnywhere
            clip: true
            maximumLength: 26
            selectionColor: "#FF3C4BE8"

            onEditingFinished: {
                if((fileNameText.text.indexOf("#") != -1)
                || (fileNameText.text.indexOf("/") != -1)
                || (fileNameText.text.indexOf("?") != -1)) {
                    fileNameText.text = tmpName
                    showToast("The file name cannot contain the following characters: '# / ?'")
                }else  {
                    var canRename = true
                    var userNotRename = false
                    for(var i = 0; i < currentBrowser.currentFMList.count; i++)  {
                        var item = currentFMModel.get(i)
                        if(item.label == fileNameText.text) {
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
                        }else  {
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
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 5
            horizontalAlignment: Text.AlignHCenter
            text: fileSize
            font.pointSize: textDefaultSize - 5
            color: "#4D000000"
            visible:  {
                if(String(root.currentPath).startsWith("trash:/") && model.isdir == "true") {
                    false
                }else {
                    true
                }
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

        onClicked: {
            if(mouse.button === Qt.RightButton) {
                listViewDelegate.rightClicked(mouse)
            } else {
                listViewDelegate.color = "#1F767680"
                clickMouse = mouse
                timer.start()
            }
        }

        onDoubleClicked:  {
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

        onCleared:  {
            listViewDelegate.checked = false
        }
    }

    Connections {
        target: root_renameSelectionBar
        
        onUriRemoved: {
            if(uri === model.path) {
                fileNameText.focus = false
            }
        }

        onUriAdded:  {
            if(uri === model.path) {
                fileNameText.forceActiveFocus()
                var indexOfd = fileNameText.text.lastIndexOf(".")
                if(indexOfd != -1) {
                    fileNameText.select(0, indexOfd)
                }else {
                    fileNameText.selectAll()
                }
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

        onUriAdded: {
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
