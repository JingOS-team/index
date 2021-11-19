/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Page
{
    id: control
    property url currentUrl: ""

    property alias listView : _listView
    property alias model : _listView.model
    property alias currentIndex: _listView.currentIndex

    property bool isFav : false
    property bool isDir : false
    property bool showInfo: true
    property int type : 0 //那种类型的文件  1--音频

    background: Rectangle
    {
        color: "#00000000"
    }

    ListView
    {
        id: _listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        currentIndex: -1
        clip: true
        focus: true
        spacing: 0
        interactive: false
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        highlightResizeDuration : 0
        snapMode: ListView.SnapOneItem
        cacheBuffer: width
        keyNavigationEnabled : true
        keyNavigationWraps : true

        delegate: Item
        {
            id: _delegate

            height: ListView.view.height
            width: ListView.view.width

            property bool isCurrentItem : ListView.isCurrentItem
            property url currentUrl: model.path
            property var iteminfo : model
            readonly property string title: model.label
            property var loaderSource

            Loader
            {
                id: previewLoader
                active: _delegate.isCurrentItem
                visible: !control.showInfo
                width: parent.width
                height: parent.height
                onActiveChanged: if(active) show(currentUrl)
            }

            Timer {
                id: previewTimer
                interval: 10
                onTriggered: {
                    previewLoader.source = _delegate.loaderSource
                }
            }

            function show(path)//各个文件类型
            {
                leftMenuData.addFileToRecents(path.toString());

                control.isDir = model.isdir == "true"
                control.currentUrl = path
                root.currentTitle = iteminfo.label

                
                var source = "DefaultPreview.qml"
                if(iteminfo.mime.indexOf("audio") != -1)//音频 直接播放
                {
                    source = "AudioPreview.qml"
                    type = 1
                }
                else if(Maui.FM.checkFileType(Maui.FMList.TEXT, iteminfo.mime))
                {
                    source = "TextPreview.qml"
                }
                else if(Maui.FM.checkFileType(Maui.FMList.DOCUMENT, iteminfo.mime))
                {
                    source = "DocumentPreview.qml"
                }
                else
                {
                    root.currentTitle = getCurrentTitle(currentBrowser.currentPath)
                    // source = "DefaultPreview.qml"
                }

                if(source == "DefaultPreview.qml")
                {
                    return
                }
                _delegate.loaderSource = source
                previewTimer.start()
                control.showInfo = source === "DefaultPreview.qml"
            }

            function initModel()
            {
                infoModel.clear()
                infoModel.append({key: "Type", value: iteminfo.mime})
                infoModel.append({key: "Date", value: Qt.formatDateTime(new Date(model.date), "d MMM yyyy")})
                infoModel.append({key: "Modified", value: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")})
                infoModel.append({key: "Last Read", value: Qt.formatDateTime(new Date(model.lastread), "d MMM yyyy")})
                infoModel.append({key: "Owner", value: iteminfo.owner})
                infoModel.append({key: "Group", value: iteminfo.group})
                infoModel.append({key: "Size", value: Maui.FM.formatSize(iteminfo.size)})
                infoModel.append({key: "Symbolic Link", value: iteminfo.symlink})
                infoModel.append({key: "Path", value: iteminfo.path})
                infoModel.append({key: "Thumbnail", value: iteminfo.thumbnail})
                infoModel.append({key: "Icon Name", value: iteminfo.icon})
            }
        }
    }

    footerColumn: [
        Maui.ToolBar
        {
            width: parent.width
            height: 1
            position: ToolBar.Bottom
            background: null
            visible: true
        }
       ]
}
