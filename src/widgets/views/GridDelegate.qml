/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.9
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.14

Rectangle {
    id: listViewDelegate

    property string iconSource
    property string tagSource
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
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"

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
    color: "transparent"

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        property bool pressAndHoldIgnored: false
        drag.axis: Drag.XAndYAxis

        onPressed: {
            listViewDelegate.color = Kirigami.JTheme.pressBackground
        }

        onReleased: {
            listViewDelegate.color = "#00000000"
        }

        onCanceled: {
            if (listViewDelegate.draggable) {
                drag.target = null
            }
            listViewDelegate.color = "#00000000"
        }

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                listViewDelegate.rightClicked(mouse)
            } else {
                clickMouse = mouse
                timer.start()
            }
        }

        onDoubleClicked: {
            listViewDelegate.doubleClicked(mouse)
        }

        onPressAndHold: {
            drag.target = null
            listViewDelegate.pressAndHold(mouse)
        }
    }

    Item
    {
        id: iconItem
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: 70 * appScaleSize
        height: width

        Image {
            id: iconImage
            asynchronous: true
            cache: true
            smooth: false
            width: 70 * appScaleSize
            height: width

            sourceSize.width: 70 * appScaleSize
            sourceSize.height: 70 * appScaleSize

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            fillMode: Image.PreserveAspectFit
            visible: !root_zipList._uris.includes(model.path)

            source: {
                iconSource
            }

            layer.enabled: Maui.Style.radiusV
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: iconImage.width
                    height: iconImage.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, iconImage.paintedWidth)
                        height: Math.min(parent.height, iconImage.paintedHeight)
                        radius: Maui.Style.radiusV
                    }
                }
            }

            Connections {
                target: leftMenuData
                onRefreshImageSource: {
                    if (iconSource == imagePath) {
                        if (mime.indexOf("image") != -1) {
                            iconImage.source = "qrc:/assets/image_default.png"
                        } else if (mime.indexOf("video") != -1) {
                            iconImage.source = "qrc:/assets/video_default.png"
                        }
                        iconImage.source = imagePath
                    }
                }
            }
        }

        AnimatedImage {
            id: gifImage

            width: 70 * appScaleSize
            height: width

            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent.centerIn

            source: {
                if (model.label.indexOf(".zip") != -1) {
                    isDarkTheme ? "qrc:/assets/black_zip.gif" : "qrc:/assets/zip.gif"
                } else {
                    isDarkTheme ? "qrc:/assets/black_unzip.gif" : "qrc:/assets/unzip.gif"
                }
            }

            visible: root_zipList._uris.includes(model.path)

            playing: visible

            MouseArea {}
        }

        Kirigami.Icon {
            visible: iconImage.status !== Image.Ready
            anchors.centerIn: iconItem.centerIn
            height: width
            width: 70 * appScaleSize
            source: {
                if (mime.indexOf("image") != -1) {
                    "qrc:/assets/image_default.png"
                } else if (mime.indexOf("video") != -1) {
                    "qrc:/assets/video_default.png"
                } else {
                    "qrc:/assets/default.png"
                }
            }
            isMask: false
            opacity: 0.5
        }
    }

    Rectangle {
        id: fileNameSize

        anchors {
            top: iconItem.bottom
            topMargin: 8 * appScaleSize
            horizontalCenter: iconItem.horizontalCenter
        }
        width: parent.width
        height: (115 - 70 - 6) * appScaleSize
        color: "transparent"

        Kirigami.JIconButton
        {
            id: checkStatusImage

            anchors {
                left: parent.left
                top: parent.top
                topMargin: -10 * appScaleSize
            }

            width: (22 + 10) * appScaleSize
            height: (22 + 10) * appScaleSize
            hoverEnabled: false
            source: {
                if (checked) {
                    "qrc:/assets/select_all.png"
                } else {
                    "qrc:/assets/unselect_rect.png"
                }
            }

            visible: {
                if (root.selectionMode) {
                    true
                } else {
                    false
                }
            }
        }

        Item
        {
            id: midRect
            width: {
                if (root.selectionMode) {
                    if (tagRect.width > 0) {
                        parent.width - checkStatusImage.width - tagRect.width
                    } else {
                        parent.width - checkStatusImage.width - 16 * appScaleSize
                    }
                } else {
                    if (fileNameText1.contentWidth + (tagRect.width * 2) > width) {
                        parent.width - (tagRect.width * 2)
                    } else {
                        parent.width
                    }
                }
            }
            height: fileNameText.visible ? fileNameText.height : fileNameText1.height
            anchors.top: parent.top
            anchors.topMargin: -6 * appScaleSize
            anchors.left: root.selectionMode ? checkStatusImage.right : parent.left
            anchors.leftMargin: {
                if (root.selectionMode) {
                    if (tagRect.width > 0) {
                        tagRect.width
                    } else {
                        8 * appScaleSize
                    }
                } else {
                    if (fileNameText1.contentWidth + (tagRect.width * 2) > width) {
                        tagRect.width
                    } else {
                        0
                    }
                }
            }

            Item {
                visible: !fileNameText.visible
                width: parent.width
                height: fileNameText1.height
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: root.selectionMode ? 0 : (midRect.width
                                                              - fileNameText1.contentWidth) / 2
                Image {
                    id: tagRect
                    anchors {
                        top: fileNameText1.top
                        topMargin: -3 * appScaleSize
                        right: fileNameText1.left
                    }
                    width: (tagSource !== "" && visible) ? 16 * appScaleSize : 0
                    height: 16 * appScaleSize
                    source: tagSource
                    visible: !isRename ? true : false
                }

                Text {
                    visible: !isRename ? true : false
                    id: fileNameText1
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    width: parent.width
                    text: fileName
                    font.pixelSize: 11 * appFontSize
                    color: Kirigami.JTheme.majorForeground
                    wrapMode: Text.WrapAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    clip: true
                }
            }

            Kirigami.JTextField {
                id: fileNameText
                anchors {
                    top: parent.top
                    topMargin: -6 * appScaleSize
                    left: parent.left
                }
                clearButtonShown: false
                visible: !isRename ? false : true
                text: fileName
                maximumLength: 50
                font.pixelSize: 11 * appFontSize
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                background: Item {}
                onEditingFinished: {
                    if ((fileNameText.text.indexOf("#") != -1)
                            || (fileNameText.text.indexOf("/") != -1)
                            || (fileNameText.text.indexOf("?") != -1)) {
                        fileNameText.text = tmpName
                        showToast(i18n("The file name cannot contain the following characters: '# / ?'"))
                    } else if (fileNameText.text.startsWith(".")) {
                        fileNameText.text = tmpName
                        showToast(i18n("The file name cannot starts whit character: '.'"))
                    } else {
                        var canRename = true
                        var userNotRename = false
                        for (var i = 0; i < currentBrowser.currentFMList.count; i++) {
                            var item = currentFMModel.get(i)
                            if (item.label == fileNameText.text) {
                                if (item.path != model.path) {
                                    canRename = false
                                } else {
                                    userNotRename = true
                                }
                                break
                            }
                        }

                        if (!userNotRename) {
                            if (canRename) {
                                var collectionList = leftMenuData.getCollectionList()
                                var needRefreshCollection = false
                                var needRefresh = false
                                if (leftMenuData.isCollectionFolder(path)) {
                                    leftMenuData.addFolderToCollection(
                                                path.toString(), true, false)
                                    needRefreshCollection = true
                                }

                                if (leftMenuData.isTagFile(path) !== -1) {
                                    needRefresh = true
                                }

                                Maui.FM.rename(path, fileNameText.text)

                                if (item.mime.indexOf("image/jpeg") != -1
                                        || item.mime.indexOf(
                                            "video") != -1)
                                {
                                    var index = item.path.lastIndexOf(".")
                                    var newPath = item.path.substring(
                                                0, index)
                                    index = newPath.lastIndexOf("/")
                                    var startPath = newPath.substring(0,
                                                                      index + 1)
                                    var endPath = newPath.substring(
                                                index + 1,
                                                newPath.length)
                                    var tmpPreview = startPath + "." + endPath + ".jpg"
                                    Maui.FM.rename(tmpPreview,
                                                   "." + fileNameText.text)
                                }

                                if (root.isSpecialPath || needRefresh)
                                {
                                    timer_refresh.start()
                                }

                                if (needRefreshCollection) {
                                    timer_fav.start()
                                }
                            } else {
                                fileNameText.text = tmpName
                                showToast(i18n("The file name already exists."))
                            }
                        }
                    }
                    root_renameSelectionBar.clear()
                }

                onFocusChanged: {
                    if (focus) {
                        tmpName = fileNameText.text
                    }
                }
            }
        }

        Text {
            id: fileSizeText
            anchors {
                top: midRect.bottom
                topMargin: !isRename ? 5 * appScaleSize : -10 * appScaleSize
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 5 * appScaleSize
            horizontalAlignment: Text.AlignHCenter
            text: fileSize
            font.pixelSize: 10 * appFontSize
            color: Kirigami.JTheme.minorForeground
            visible: {
                if (String(root.currentPath).startsWith("trash:/")
                        && model.isdir == "true") {
                    false
                } else {
                    true
                }
            }
        }

        Text {
            id: fileSizeText1
            anchors {
                top: midRect.bottom
                topMargin: 5 * appScaleSize
                left: parent.left
                leftMargin: tagRect.width > 0 ? checkStatusImage.width
                                                + tagRect.width : checkStatusImage.width
                                                + 16 * appScaleSize
            }
            width: contentWidth
            text: fileSize
            font.pixelSize: 10 * appFontSize
            color: Kirigami.JTheme.minorForeground
            visible: false
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

    Connections
    {
        target: root_selectionBar

        onUriRemoved: {
            if (String(root.currentPath).startsWith("trash:/")) {
                if (uri === model.nickname) {
                    listViewDelegate.checked = false
                }
            } else {
                if (uri === model.path) {
                    listViewDelegate.checked = false
                }
            }
        }

        onUriAdded: {
            if (String(root.currentPath).startsWith("trash:/")) {
                if (uri === model.nickname) {
                    listViewDelegate.checked = true
                }
            } else {
                if (uri === model.path) {
                    listViewDelegate.checked = true
                }
            }
        }

        onCleared: {
            listViewDelegate.checked = false
        }
    }

    Connections //重命名
    {
        target: root_renameSelectionBar

        onUriRemoved: {
            if (uri === model.path) {
                fileNameText.focus = false
                isRename = false
            }
        }

        onUriAdded: {
            if (uri === model.path) {
                fileNameText.forceActiveFocus()
                var indexOfd = fileNameText.text.lastIndexOf(".")
                if (indexOfd != -1) {
                    fileNameText.select(0, indexOfd)
                } else {
                    fileNameText.selectAll()
                }
                isRename = true
            }
        }

        onCleared: {
            fileNameText.focus = false
            isRename = false
        }
    }

    Connections
    {
        target: root_menuSelectionBar

        onUriRemoved: {
            if (uri === model.path)
                listViewDelegate.color = "transparent"
        }

        onUriAdded: {
            if (uri === model.path)
                listViewDelegate.color = "#1F9F9FAA"
        }

        onCleared: {
            listViewDelegate.color = "transparent"
        }
    }

    Timer {
        id: timer
        running: false
        repeat: false
        interval: 50
        onTriggered: {
            listViewDelegate.color = "transparent" //"#FFFFFFFF"
            listViewDelegate.clicked(clickMouse)
        }
    }

    Timer {
        id: timer_fav
        running: false
        repeat: false
        interval: 50
        onTriggered: {
            var index = path.lastIndexOf("/")
            var startPath = path.substring(0, index + 1)
            leftMenuData.addFolderToCollection(
                        (startPath + fileNameText.text).toString(), false, true)
        }
    }

    Timer {
        id: timer_refresh
        running: false
        repeat: false
        interval: 100
        onTriggered: {
            leftMenuData.updateTagUrl()
            root.currentBrowser.currentFMList.refresh()
        }
    }
}
