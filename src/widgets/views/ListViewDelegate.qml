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
import QtQuick.Controls 2.14

Rectangle {
    id: listViewDelegate
    implicitHeight: 44 * appScaleSize
    property string iconSource
    property string tagSource
    property string fileSize
    property string fileName
    property string fileDate
    property string tagColor
    property bool isFolder
    property int textDefaultSize: theme.defaultFont.pointSize
    property bool checked: _selectionBar.contains(model.nickname)
    property bool isRename: root_renameSelectionBar.contains(path)

    property bool menuSelect: false
    property string tmpName
    property var clickMouse
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"

    property bool draggable: false
    signal pressed(var mouse)
    signal pressAndHold(var mouse)
    signal clicked(var mouse)

    signal rightClicked(var mouse)

    signal doubleClicked(var mouse)

    signal contentDropped(var drop)
    signal toggled(bool state)

    color: "transparent"
    radius: 10

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

    Kirigami.JIconButton
    {
        id: checkStatusImage
        anchors.verticalCenter: parent.verticalCenter
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        visible: root.selectionMode
        source: checked ? "qrc:/assets/select_all.png" : "qrc:/assets/unselect_rect.png"
        hoverEnabled: false
    }

    Image {
        id: iconImage
        width: 44 * appScaleSize
        height: 44 * appScaleSize
        anchors.left: root.selectionMode ? checkStatusImage.right : parent.left
        anchors.leftMargin: checkStatusImage.visible ? 5 * appScaleSize : 0
        visible: !root_zipList._uris.includes(model.path)
        fillMode: Image.PreserveAspectFit
        source: iconSource
        asynchronous: true
        Connections {
            target: leftMenuData

            function onRefreshImageSource(imagePath) {
                if (iconSource === imagePath) {
                    if (mime.indexOf("image") !== -1) {
                        iconImage.source = "qrc:/assets/image_default.png"
                    } else if (mime.indexOf("video") !== -1) {
                        iconImage.source = "qrc:/assets/video_default.png"
                    }
                    iconImage.source = imagePath
                }
            }
        }
    }

    AnimatedImage {
        id: gifImage
        width: 44 * appScaleSize
        height: 44 * appScaleSize
        anchors.left: root.selectionMode ? checkStatusImage.right : parent.left
        anchors.leftMargin: checkStatusImage.visible ? 5 * appScaleSize : 0
        source: model.label.indexOf(
                    ".zip") !== -1 ? "qrc:/assets/zip.gif" : "qrc:/assets/unzip.gif"

        visible: root_zipList._uris.includes(model.path)
        playing: visible
    }

    Kirigami.Icon {
        height: 44 * appScaleSize
        width: 44 * appScaleSize

        anchors.left: root.selectionMode ? checkStatusImage.right : parent.left
        anchors.leftMargin: checkStatusImage.visible ? 5 * appScaleSize : 0
        visible: iconImage.status !== Image.Ready
        source: mime.indexOf(
                    "image") !== -1 ? "qrc:/assets/image_default.png" : (mime.indexOf("video") !== -1 ? "qrc:/assets/video_default.png" : "qrc:/assets/default.png")
        isMask: false
        opacity: 0.5
    }

    Item {
        anchors {
            left: iconImage.right
            leftMargin: 12 * appScaleSize
            top: parent.top
            topMargin: 3 * appScaleSize
        }
        width: parent.width / 2
        height: fileSizeText.height + fileText.height + 13 * appScaleSize //iconImage.height - 20

        Text {
            id: fileText
            width: parent.width
            visible: !isRename
            text: fileName
            font.pixelSize: 13 * appFontSize
            color: Kirigami.JTheme.majorForeground
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        Kirigami.JTextField {
            id: fileNameText

            width: parent.width
            anchors {
                left: parent.left
                leftMargin: -8 * appScaleSize
            }
            clearButtonShown: false

            visible: isRename
            text: fileName
            maximumLength: 50
            font.pixelSize: 12 * appFontSize
            horizontalAlignment: Text.AlignLeft

            background: Item {}

            onEditingFinished: {
                if ((fileNameText.text.indexOf("#") != -1)
                        || (fileNameText.text.indexOf("/") != -1)
                        || (fileNameText.text.indexOf("?") != -1)) {
                    //不允许包含特殊字符
                    fileNameText.text = tmpName
                    showToast(i18n(
                                  "The file name cannot contain the following characters: '# / ?'"))
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
                            var collectionList = leftMenuData.getCollectionList(
                                        )
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

                            if (item.mime.indexOf("image/jpeg") !== -1
                                    || item.mime.indexOf(
                                        "video") !== -1)
                            {
                                var index = item.path.lastIndexOf(".")
                                var newPath = item.path.substring(
                                            0, index) //path/name
                                index = newPath.lastIndexOf("/")
                                var startPath = newPath.substring(0, index + 1)
                                //path/
                                var endPath = newPath.substring(
                                            index + 1, newPath.length) //name
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

        Text {
            id: fileSizeText

            anchors.top: fileText.bottom
            anchors.topMargin: 2 * appScaleSize
            text: fileSize

            font.pixelSize: 10 * appFontSize
            color: Kirigami.JTheme.minorForeground //"#4D000000

            visible: {
                if (String(root.currentPath).startsWith("trash:/")
                        && model.isdir == "true") {
                    false
                } else {
                    true
                }
            }
        }
    }

    Image {
        id: tagRect
        anchors {
            right: fileDateText.left
            rightMargin: 6 * appScaleSize
            verticalCenter: fileDateText.verticalCenter
        }
        width: tagSource !== "" ? 16 * appScaleSize : 0
        height: 16 * appScaleSize
        source: tagSource
    }

    Text {
        id: fileDateText

        anchors {
            right: parent.right
            rightMargin: (22 + 10) * appScaleSize
            verticalCenter: parent.verticalCenter
        }
        text: fileDate
        font.pixelSize: 11 * appFontSize
        color: Kirigami.JTheme.minorForeground
    }

    Loader {
        id: rightArrowLoader
        sourceComponent: rightArrowComponent
        active: isFolder
    }
    Component {
        id: rightArrowComponent
        Item {
            width: listViewDelegate.width
            height: listViewDelegate.height
            Kirigami.Icon {
                id: rightArrowImage

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: 22 * appScaleSize
                height: 22 * appScaleSize
                source: "qrc:/assets/right_arrow.png"
                color: Kirigami.JTheme.majorForeground
            }
        }
    }

    DropArea {
        id: _dropArea
        anchors.fill: parent
        enabled: listViewDelegate.draggable

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "blue"
            visible: parent.containsDrag
            opacity: 0.3
        }

        onDropped: {
            listViewDelegate.contentDropped(drop)
        }
    }

    Connections {
        target: root_selectionBar
        function onUriRemoved(uri) {
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

        function onUriAdded(uri) {
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
        function onCleared() {
            listViewDelegate.checked = false
        }
    }

    Connections {
        target: root_renameSelectionBar
        function onUriRemoved(uri) {
            if (uri === model.path) {
                fileNameText.focus = false
                isRename = false
            }
        }

        function onUriAdded(uri) {
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

        function onCleared() {
            fileNameText.focus = false
            isRename = false
        }
    }

    Connections {
        target: root_menuSelectionBar

        function onUriRemoved(uri) {
            if (uri === model.path)
                listViewDelegate.color = "transparent"
        }

        function onUriAdded(uri) {
            if (uri === model.path)
                listViewDelegate.color = "#1F9F9FAA"
        }

        function onCleared() {
            listViewDelegate.color = "transparent"
        }
    }

    Timer {
        id: timer
        running: false
        repeat: false
        interval: 50
        onTriggered: {
            listViewDelegate.color = "transparent"
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
