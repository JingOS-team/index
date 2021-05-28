// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.14

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.index 1.0 as Index

import "../previewer"
import ".."

Item
{
    id: control

    readonly property int _index : ObjectModel.index

    property alias browser : _browser
    property alias currentPath: _browser.currentPath
    property alias settings : _browser.settings
    property alias title : _browser.title

    // property var audioItem: ""

    readonly property bool previewerVisible : _stackView.depth === 2
    //    property bool terminalVisible : Maui.FM.loadSettings("TERMINAL", "EXTENSIONS", false) == "true"
    property bool terminalVisible : false
    readonly property bool supportsTerminal : terminalLoader.item

    SplitView.fillHeight: true
    SplitView.fillWidth: true

    SplitView.preferredHeight: _splitView.orientation === Qt.Vertical ? _splitView.height / (_splitView.count) :  _splitView.height
    SplitView.minimumHeight: _splitView.orientation === Qt.Vertical ?  200 : 0

    SplitView.preferredWidth: _splitView.orientation === Qt.Horizontal ? _splitView.width / (_splitView.count) : _splitView.width
    SplitView.minimumWidth: _splitView.orientation === Qt.Horizontal ? 300 :  0

    opacity: _splitView.currentIndex === _index ? 1 : 0.7

    onCurrentPathChanged:
    {
        if(currentBrowser)
        {
            syncTerminal(currentBrowser.currentPath)
        }
        if(previewerVisible)
        {
            _stackView.pop()
        }
    }

    Component
    {
        id: _previewerComponent

        FilePreviewer
        {
            model: _browser.currentFMModel
            headBar.visible: false
            footBar.visible: false
            // headBar.farLeftContent: ToolButton
            // {
            //     icon.name: "go-previous"
            //     onClicked:
            //     {
            //         _stackView.pop(StackView.Immediate)
            //     }
            // }
            Component.onCompleted:
            {
                listView.forceActiveFocus()
                listView.currentIndex = Qt.binding(function() { return _browser.currentIndex })
            }
        }


        // AudioPreview
        // {
        //     iteminfo: audioItem
        //     headBar.visible: false
        //     footBar.visible: false
        // }
    }

    SplitView
    {
        anchors.fill: parent
        anchors.bottomMargin: 0//_selectionBar.visible && (terminalVisible | _stackView.depth == 2) ? _selectionBar.height : 0
        spacing: 0
        orientation: Qt.Vertical

        handle: Rectangle
        {
            implicitWidth: 6
            implicitHeight: 6
            color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                       : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

            Rectangle
            {
                anchors.centerIn: parent
                width: 48
                height: parent.height
                color: _splitSeparator.color
            }

            Kirigami.Separator
            {
                id: _splitSeparator
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
            }

            Kirigami.Separator
            {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
            }
        }

        StackView
        {
            id: _stackView

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            initialItem: FileBroswerView
            {
                id: _browser

                headerBackground.color: "transparent"

                selectionBar: root.selectionBar
                gridItemSize: 
                {
                    switch(appSettings.gridSize)
                    {
                    case 0: return Math.floor(48 * 1.5);
                    case 1: return Math.floor(64 * 1.5);
                    case 2: return Math.floor(80 * 1.5);
                    case 3: return Math.floor(124 * 1.5);
                    default: return Math.floor(96 * 1.5);
                    }
                }

                listItemSize: 
                {
                    switch(appSettings.listSize)
                    {
                    case 0: return 32;
                    case 1: return 48;
                    case 2: return 64;
                    case 3: return 96;
                    default: return 96;
                    }
                }

                selectionMode: root.selectionMode

                onSelectionModeChanged:
                {
                    root.selectionMode = selectionMode
                    selectionMode = Qt.binding(function() { return root.selectionMode })
                } // rebind this property in case filebrowser breaks it

                settings.showHiddenFiles: appSettings.showHiddenFiles
                settings.showThumbnails: appSettings.showThumbnails
                settings.foldersFirst: sortSettings.globalSorting ? sortSettings.foldersFirst : true
                settings.sortBy: sortSettings.sortBy
                settings.sortOrder: sortSettings.sortOrder
                settings.group: sortSettings.group

                Binding
                {
                    target: _browser.settings
                    property: "sortBy"
                    when: sortSettings.globalSorting
                    value: sortSettings.sortBy
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Binding
                {
                    target: _browser.settings
                    property: "sortOrder"
                    when: sortSettings.globalSorting
                    value: sortSettings.sortOrder
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Binding
                {
                    target: _browser.settings
                    property: "group"
                    when: sortSettings.globalSorting
                    value: sortSettings.group
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Rectangle
                {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    opacity: 1
                    color: Kirigami.Theme.highlightColor
                    visible: _splitView.currentIndex === _index && _splitView.count === 2
                }

                Connections
                {
                    target: _browser.dropArea
                    ignoreUnknownSignals: true
                    function onEntered()
                    {
                        _splitView.currentIndex = control._index
                    }
                }

                onKeyPress:
                {
                    if (event.key == Qt.Key_Forward)
                    {
                        _browser.goForward()
                    }

                    if((event.key == Qt.Key_T) && (event.modifiers & Qt.ControlModifier))
                    {
                        openTab(control.currentPath)
                    }

                    // Shortcut for closing tab
                    if((event.key == Qt.Key_W) && (event.modifiers & Qt.ControlModifier))
                    {
                        if(tabsObjectModel.count > 1)
                            root.closeTab(tabsBar.currentIndex)
                    }

                    if((event.key == Qt.Key_K) && (event.modifiers & Qt.ControlModifier))
                    {
                        _pathBar.showEntryBar()
                    }

                    if(event.key === Qt.Key_F4)
                    {
                        toogleTerminal()
                    }

                    if(event.key === Qt.Key_F3)
                    {
                        toogleSplitView()
                    }

                    if((event.key === Qt.Key_N) && (event.modifiers & Qt.ControlModifier))
                    {
                        newItem()
                    }

                    if(event.key === Qt.Key_Space)
                    {
                        _stackView.push(_previewerComponent, StackView.Immediate)
                    }

                    if(event.button === Qt.BackButton)
                    {
                        _browser.goBack()
                    }

                    //@gadominguez At this moment this function doesnt work because goForward not exist
                    if(event.button === Qt.ForwardButton)
                    {
                        _browser.goForward()
                    }

                }

                onItemClicked:
                {
                    const item = currentFMModel.get(index)

                    if(root.selectionMode)//编辑态下 选中操作
                    {
                        addToSelection(item, index)
                    }else
                    {
                        if(appSettings.singleClick)//左键点击，如果文件管理器自己支持，则直接自己打开。如果不支持，则需要判断外部程序
                        {
                            if(appSettings.previewFiles && item.isdir != "true" && !root.selectionMode)
                            {
                                if(item.mime.indexOf("video") != -1)//视频 直接播放
                                {
                                    leftMenuData.playVideo(item.path.toString())
                                }else if(Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime))//图片直接预览
                                {
                                    root.imageIndex = index
                                    root.showImageViewer(item)
                                    leftMenuData.addFileToRecents(item.path.toString());
                                }else if((item.mime.indexOf("audio") != -1)
                                || Maui.FM.checkFileType(Maui.FMList.TEXT, item.mime))//如果是音频或者txt文件直接内部打开
                                {
                                    root.imageIndex = index
                                    _stackView.push(_previewerComponent, StackView.Immediate)
                                }
                                // else if(item.mime.includes("x-7z-compressed") || item.mime.includes("x-tar") || item.mime.includes("zip"))//如果是压缩文件直接解压缩
                                else if(Maui.FM.checkFileType(Maui.FMList.COMPRESSED, item.mime))
                                {
                                    _compressedFile.url = item.path
                                    _compressedFile.extractWithThread(currentPath, item.label)
                                }else
                                {
                                    root.openWith(item)
                                }
                                return
                            }
                            openItem(index)
                        }
                    } 
                }

                onItemDoubleClicked:
                {
                    const item = currentFMModel.get(index)

                    if(!appSettings.singleClick)
                    {
                        if(appSettings.previewFiles && item.isdir != "true" && !root.selectionMode)
                        {
                            _stackView.push(_previewerComponent)
                            return
                        }

                        openItem(index)
                    }
                }

            }
        }

        Loader
        {
            id: terminalLoader
            SplitView.fillWidth: true
            SplitView.preferredHeight: 200
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : 100
            visible: active && terminalVisible

            active: inx.supportsEmbededTerminal()

            source: "Terminal.qml"

            onVisibleChanged: syncTerminal(control.currentPath)
        }
    }

    MouseArea
    {
        anchors.fill: parent
        enabled: _splitView.currentIndex !== _index
        propagateComposedEvents: false
        preventStealing: true
        onClicked: _splitView.currentIndex = _index
    }

    Component.onCompleted:
    {
        syncTerminal(control.currentPath)
    }

    Component.onDestruction: console.log("Destroyed browsers!!!!!!!!")

    function syncTerminal(path)
    {
        if(terminalLoader.item && terminalVisible)
            terminalLoader.item.session.sendText("cd '" + String(path).replace("file://", "") + "'\n")
    }

    function toogleTerminal()
    {
        terminalVisible = !terminalVisible
        //        Maui.FM.saveSettings("TERMINAL", terminalVisible, "EXTENSIONS")
    }

    function popPreviewer()
    {
        if(previewerVisible)
            _stackView.pop()
    }
}