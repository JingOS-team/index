/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

Rectangle
{
    id: leftMenu

    color: "#00000000"
    property bool isDarkTheme: {
        console.log(" theme name::::" + Kirigami.JTheme.colorScheme)
        Kirigami.JTheme.colorScheme === "jingosDark"
    }
    ListView {
        id: menuListView
        clip: true
        anchors.fill: parent
        model: ListModel {
            id: leftMenuModel
        }
        delegate: leftMenuDelegate

        Connections {
            target: leftMenuData
            onAddCollection: {
                refreshCollectionMenu()
            }

            onRemoveCollection: {
                var node = leftMenuModel.get(2).subNode
                for (var j = 0; j < node.count; ++j) {
                    if (node.get(j).path == folderPath) {
                        node.remove(j)
                        break
                    }
                }
            }
        }
    }

    Connections {
        target: leftMenuData
        onDeviceAdded: {
            refreshUSBMenu(deviceList)
        }

        onTipMessage: {
            showToast(tipInfo)
        }

        onDeviceRemoved: {
            refreshUSBMenu(deviceList)

            if (currentPath.toString().startsWith(
                        "file:///media/" + leftMenuData.getUserName()
                        + "/"))
            {
                for (var i = 0; i < leftMenuModel.count; ++i) {
                    var node = leftMenuModel.get(i).subNode
                    for (var j = 0; j < node.count; ++j) {
                        if (node.get(j).subItemChecked) {
                            node.get(j).subItemChecked = false
                        }
                    }
                }
                var userNameNode = leftMenuModel.get(1).subNode.get(1)
                userNameNode.subItemChecked = true
                currentTitle = userNameNode.subName
                clearSelectionBar()
                root.selectionMode = false
                currentBrowser.openFolder(userNameNode.path)
                root.searchState = false
                root.isSpecialPath = false
            }
        }
    }

    Component.onCompleted: {
        leftMenuModel.append({
                                 "menuName": i18n("Type"),
                                 "openState": true,
                                 "subNode": []
                             })
        addSubNode(0, i18n("Document"), "assets/leftmenu/documentSelect.png",
                   "assets/leftmenu/documentUnselect.png", false,
                   "qrc:/widgets/views/Document", "null")
        addSubNode(0, i18n("Picture"), "assets/leftmenu/picSelect.png",
                   "assets/leftmenu/picUnselect.png", false,
                   "qrc:/widgets/views/Picture", "null")
        addSubNode(0, i18n("Video"), "assets/leftmenu/videoSelect.png",
                   "assets/leftmenu/videoUnselect.png", false,
                   "qrc:/widgets/views/Video", "null")
        addSubNode(0, i18n("Music"), "assets/leftmenu/musicSelect.png",
                   "assets/leftmenu/musicUnselect.png", false,
                   "qrc:/widgets/views/Music",
                   "null")

        //Location
        leftMenuModel.append({
                                 "menuName": i18n("Location"),
                                 "openState": true,
                                 "subNode": []
                             })
        addSubNode(1, i18n("Recents"), "assets/leftmenu/recentsSelect.png",
                   "assets/leftmenu/recentsUnselect.png", false,
                   "qrc:/widgets/views/Recents", "null")
        addSubNode(1, leftMenuData.getUserName(),
                   "assets/leftmenu/jingosSelect.png",
                   "assets/leftmenu/jingosUnselect.png", true,
                   leftMenuData.getHomePath(), "null")
        addSubNode(1, i18n("Downloads"), "assets/leftmenu/downloadSelect.png",
                   "assets/leftmenu/downloadUnselect.png", false,
                   leftMenuData.getDownloadsPath(),
                   "null")
        addSubNode(1, i18n("Trash"), "assets/leftmenu/trashSelect.png",
                   "assets/leftmenu/trashUnselect.png", false,
                   leftMenuData.getTrashPath(), "null")

        leftMenuModel.append({
                                 "menuName": i18n("Favorite"),
                                 "openState": true,
                                 "subNode": []
                             })
        var collectionList = leftMenuData.getCollectionList()
        for (var i in collectionList) {
            addSubNode(2, collectionList[i].label,
                       "assets/leftmenu/folderSelect.png",
                       "assets/leftmenu/folderUnselect.png", false,
                       collectionList[i].path, "null")
        }

        leftMenuModel.append({
                                 "menuName": i18n("Tags"),
                                 "openState": true,
                                 "subNode": []
                             })
        addSubNode(3, tagsSettings.tag0, "assets/leftmenu/tag0Select.png",
                   "assets/leftmenu/tag0.png", false,
                   "qrc:/widgets/views/tag0", "null")
        addSubNode(3, tagsSettings.tag1, "assets/leftmenu/tag1Select.png",
                   "assets/leftmenu/tag1.png", false,
                   "qrc:/widgets/views/tag1", "null")
        addSubNode(3, tagsSettings.tag2, "assets/leftmenu/tag2Select.png",
                   "assets/leftmenu/tag2.png", false,
                   "qrc:/widgets/views/tag2", "null")
        addSubNode(3, tagsSettings.tag3, "assets/leftmenu/tag3Select.png",
                   "assets/leftmenu/tag3.png", false,
                   "qrc:/widgets/views/tag3", "null")
        addSubNode(3, tagsSettings.tag4, "assets/leftmenu/tag4Select.png",
                   "assets/leftmenu/tag4.png", false,
                   "qrc:/widgets/views/tag4", "null")
        addSubNode(3, tagsSettings.tag5, "assets/leftmenu/tag5Select.png",
                   "assets/leftmenu/tag5.png", false,
                   "qrc:/widgets/views/tag5", "null")
        addSubNode(3, tagsSettings.tag6, "assets/leftmenu/tag6Select.png",
                   "assets/leftmenu/tag6.png", false,
                   "qrc:/widgets/views/tag6", "null")
        addSubNode(3, tagsSettings.tag7, "assets/leftmenu/tag7Select.png",
                   "assets/leftmenu/tag7.png", false,
                   "qrc:/widgets/views/tag7", "null")

        var deviceList = leftMenuData.getUSBDevice(true)
        for (var i in deviceList) {
            var index = deviceList[i].lastIndexOf("/")
            var usbTitle = "USB"
            if (index != -1) {
                usbTitle = deviceList[i].substring(index + 1)
            }
            addSubNode(1, usbTitle, "assets/leftmenu/usbSelect.png",
                       "assets/leftmenu/usbUnselect.png", false, deviceList[i],
                       "usb_device")
        }
        currentTitle = leftMenuData.getUserName()
        isMenuPath = true
    }

    Component {
        id: leftMenuDelegate

        Column {
            id: objColumn

            Component.onCompleted: {
                for (var i = 1; i < objColumn.children.length - 1; ++i) {
                    objColumn.children[i].visible = true
                }
            }

            Rectangle {
                visible: {
                    if (subNode.count > 0) {
                        true
                    } else {
                        false
                    }
                }
                width: typeRect.width
                height: typeRect.height
                color: "#00000000"
                Rectangle {
                    id: typeRect

                    color: "#00000000"

                    width: menuListView.width
                    height: 45 * appScaleSize

                    Text {
                        id: typeText

                        text: menuName
                        elide: Text.ElideRight
                        color: Kirigami.JTheme.minorForeground
                        font {
                            pixelSize: 12 * appFontSize
                        }

                        anchors.left: parent.left
                        anchors.leftMargin: 25 * appScaleSize
                        anchors.bottom: typeRect.bottom
                        anchors.bottomMargin: 5 * appScaleSize

                        width: parent.width
                    }

                    Kirigami.JIconButton {
                        id: typeIcon
                        width: (22 + 10) * appScaleSize
                        height: (22 + 10) * appScaleSize
                        source: {
                            if (openState) {
                                "qrc:/assets/leftmenu/downArrow.png"
                            } else {
                                "qrc:/assets/leftmenu/upArrow.png"
                            }
                        }

                        anchors.right: parent.right
                        anchors.rightMargin: 20 * appScaleSize
                        anchors.bottom: typeRect.bottom
                        color: Kirigami.JTheme.majorForeground

                        onClicked: {
                            openState = !openState
                            contentRect.isChildReapterVisible = !contentRect.isChildReapterVisible
                        }
                    }
                }

                Connections {
                    target: leftMenuData
                    onDeviceAdded: {
                        if (openState) {
                            for (var i = 1; i < objColumn.children.length - 1; ++i) {
                                objColumn.children[i].visible = true
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: menuContentRect
                property bool hideHight: false
                width: parent.width
                height: hideHight ? 0 : childReapter.count * 39 * appScaleSize
                color: "transparent"
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 75
                    }
                }
                Rectangle {
                    id: contentRect
                    property bool isChildReapterVisible: true

                    width: parent.width
                    height: parent.height
                    color: "transparent"
                    clip: true
                    ParallelAnimation {
                        id: menuAnimations
                        PropertyAnimation {
                            id: yAnimation
                            target: contentRect
                            properties: "y"
                            easing.type: Easing.InOutQuad
                            duration: 200
                            from: contentRect.y
                            to: from === 0 ? -contentRect.height : 0
                        }

                        PropertyAnimation {
                            id: opacityAnimation
                            target: contentRect
                            properties: "opacity"
                            easing.type: Easing.InOutQuad
                            duration: 100
                            from: contentRect.opacity
                            to: !contentRect.isChildReapterVisible ? 1 : 0
                        }
                        onFinished: {
                        }
                    }

                    onOpacityChanged: {
                    }

                    onIsChildReapterVisibleChanged: {
                        if (isChildReapterVisible) {
                            menuContentRect.hideHight = false
                        } else {
                            menuContentRect.hideHight = true
                        }
                        if (menuAnimations.running) {
                            menuAnimations.stop()
                        }
                        menuAnimations.start()
                    }
                    Column {
                        id: childColumn
                        anchors.fill: parent
                        Repeater {
                            id: childReapter
                            model: subNode
                            delegate: Rectangle {
                                id: subDelegateRow

                                color: model.subItemChecked ? Kirigami.JTheme.highlightColor : "#00000000" //"#FF3C4BE8" : "#00000000"
                                radius: 15 * appFontSize
                                anchors.left: parent.left
                                anchors.leftMargin: wholeScreen.width / 76.8

                                width: parent.width - parent.width / 9.6
                                height: 39 * appScaleSize
                                clip: true

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (!model.subItemChecked) {
                                            for (var i = 0; i < leftMenuModel.count; ++i) {
                                                var node = leftMenuModel.get(
                                                            i).subNode
                                                for (var j = 0; j < node.count; ++j) {
                                                    if (node.get(j).subItemChecked) {
                                                        node.get(j).subItemChecked = false
                                                    }
                                                }
                                            }
                                            model.subItemChecked = true
                                            currentTitle = model.subName
                                            clearSelectionBar()
                                            root.selectionMode = false
                                            root.isOpenWithUrl = false
                                            currentBrowser.openFolder(
                                                        model.path)
                                            root.searchState = false
                                            if (model.path == "qrc:/widgets/views/Document"
                                                    || model.path == "qrc:/widgets/views/Picture"
                                                    || model.path == "qrc:/widgets/views/Video"
                                                    || model.path == "qrc:/widgets/views/Music"
                                                    || model.path == "qrc:/widgets/views/Recents"
                                                    || model.path.indexOf(
                                                        "qrc:/widgets/views/tag") != -1) {
                                                root.isSpecialPath = true
                                            } else {
                                                root.isSpecialPath = false
                                            }
                                        }
                                    }

                                    onPressed: {
                                        if (!model.subItemChecked) {
                                            subDelegateRow.color
                                                    = Kirigami.JTheme.pressBackground
                                        }
                                    }
                                    onReleased: {
                                        if (!model.subItemChecked) {
                                            subDelegateRow.color = "#00000000"
                                        }
                                    }

                                    onEntered:
                                    {
                                        if (!model.subItemChecked) {
                                            subDelegateRow.color
                                                    = Kirigami.JTheme.hoverBackground
                                        }
                                    }
                                    onExited:
                                    {
                                        if (!model.subItemChecked) {
                                            subDelegateRow.color = "#00000000"
                                        }
                                    }
                                    onCanceled:
                                    {
                                        if (!model.subItemChecked) {
                                            subDelegateRow.color = "#00000000"
                                        }
                                    }
                                }

                                Image {
                                    id: subDelegateIcon

                                    source: isDarkTheme ? model.subIconSelect : (model.subItemChecked ? model.subIconSelect : model.subIconUnselect)
                                    fillMode: Image.PreserveAspectFit

                                    anchors.left: parent.left
                                    anchors.leftMargin: 25 * appScaleSize
                                    anchors.verticalCenter: parent.verticalCenter

                                    width: 16 * appScaleSize
                                    height: 16 * appScaleSize
                                }

                                Text {
                                    text: model.subName
                                    elide: Text.ElideRight
                                    color: isDarkTheme ? '#FFFFFFFF' : (model.subItemChecked ? '#FFFFFFFF' : '#FF000000')
                                    font {
                                        pixelSize: 14 * appFontSize
                                    }

                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: subDelegateIcon.right
                                    anchors.leftMargin: 10 * appScaleSize

                                    width: subDelegateRow.width - 77 * appScaleSize
                                           - wholeScreen.width / 76.8
                                }
                                Kirigami.JIconButton {
                                    id: ejectImage
                                    width: 26 * appScaleSize
                                    height: width
                                    color: "transparent"
                                    anchors {
                                        right: parent.right
                                        rightMargin: 8 * appScaleSize
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: isDarkTheme ? Qt.resolvedUrl(
                                                              "assets/select_eject.svg") : (model.subItemChecked ? Qt.resolvedUrl("assets/select_eject.svg") : Qt.resolvedUrl("assets/unselect_eject.svg"))
                                    visible: model.tag === "usb_device"
                                             && leftMenuData.supportEjectDevice(
                                                 model.path)
                                    MouseArea {
                                        width: parent.width + 10 * appScaleSize
                                        height: parent.height + 5 * appScaleSize
                                        onClicked: {
                                            leftMenuData.ejectDevice(model.path)
                                        }
                                    }
                                }

                                states: [
                                    State {
                                        name: "selected"
                                        when: model.subItemChecked == true
                                        PropertyChanges {
                                            target: subDelegateRow
                                            color: Kirigami.JTheme.highlightColor
                                        } //"#FF3C4BE8"}
                                    },

                                    State {
                                        name: "unselected"
                                        when: model.subItemChecked == false
                                        PropertyChanges {
                                            target: subDelegateRow
                                            color: "#00000000"
                                        }
                                    }
                                ]
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: ejectComponent
        Item {
            id: ejectItem
            width: 16 * appScaleSize
            height: width
            Image {
                id: ejectImage
                anchors.fill: parent
                source: "assets/eject.svg"
            }
        }
    }

    function addSubNode(menuIndex, subName, subIconSelect, subIconUnselect, subItemChecked, path, tag) {
        leftMenuModel.get(menuIndex).subNode.append({
                                                        "subName": subName,
                                                        "subIconSelect": subIconSelect,
                                                        "subIconUnselect": subIconUnselect,
                                                        "subItemChecked": subItemChecked,
                                                        "path": path,
                                                        "tag": tag
                                                    })
    }

    function removeModelData(menuIndex, nodeIndex) {
        leftMenuModel.get(menuIndex).subNode.remove(nodeIndex)
    }

    function syncSidebar(path) {
        isMenuPath = false
        for (var i = 0; i < leftMenuModel.count; ++i) {
            var node = leftMenuModel.get(i).subNode
            for (var j = 0; j < node.count; ++j) {
                node.get(j).subItemChecked = false
                if (node.get(j).path == path) {
                    node.get(j).subItemChecked = true
                    isMenuPath = true
                }
            }
        }
    }

    function refreshCollectionMenu() {
        var node = leftMenuModel.get(2).subNode
        node.clear()

        var collectionList = leftMenuData.getCollectionList()
        for (var i in collectionList) {
            addSubNode(2, collectionList[i].label,
                       "assets/leftmenu/folderSelect.png",
                       "assets/leftmenu/folderUnselect.png", false,
                       collectionList[i].path, "null")
        }
    }

    function dealUsbCollectionMenu() {
        var node = leftMenuModel.get(2).subNode
        node.clear()

        var collectionList = leftMenuData.getCollectionList()
        for (var i in collectionList) {
            if (collectionList[i].path.startsWith(
                        "file:///media/" + leftMenuData.getUserName() + "/")) {
                leftMenuData.addFolderToCollection(selectItem.path.toString(),
                                                   true, false)
            } else {
                addSubNode(2, collectionList[i].label,
                           "assets/leftmenu/folderSelect.png",
                           "assets/leftmenu/folderUnselect.png", false,
                           collectionList[i].path, "null")
            }
        }
    }

    function refreshUSBMenu(deviceList) {
        var node = leftMenuModel.get(1).subNode

        while (node.count > 4)
        {
            node.remove(4)
        }

        for (var i in deviceList) {
            var index = deviceList[i].lastIndexOf("/")
            var usbTitle = "USB"
            if (index != -1) {
                usbTitle = deviceList[i].substring(index + 1)
            }
            addSubNode(1, usbTitle, "assets/leftmenu/usbSelect.png",
                       "assets/leftmenu/usbUnselect.png", false, deviceList[i],
                       "usb_device")
        }
    }

    function refreshTagsMenu() {
        var node = leftMenuModel.get(3).subNode
        for (var i = 0; i < node.count; ++i) {
            var subNode = node.get(i)
            switch (i) {
            case 0:
                subNode.subName = tagsSettings.tag0
                break
            case 1:
                subNode.subName = tagsSettings.tag1
                break
            case 2:
                subNode.subName = tagsSettings.tag2
                break
            case 3:
                subNode.subName = tagsSettings.tag3
                break
            case 4:
                subNode.subName = tagsSettings.tag4
                break
            case 5:
                subNode.subName = tagsSettings.tag5
                break
            case 6:
                subNode.subName = tagsSettings.tag6
                break
            case 7:
                subNode.subName = tagsSettings.tag7
                break
            }
        }
    }
}
