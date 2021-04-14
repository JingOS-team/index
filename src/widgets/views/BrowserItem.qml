/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page {
    id: control
    headBar.visible: false
    title: currentFMList.pathName

    background: Rectangle{
        color: "#FFFFFFFF"
    }

    Timer {
        id: timer
        running: false
        repeat: false
        interval: 10

        onTriggered: {
            for(var i = 0; i < currentFMList.count; i++) {
                var item = currentFMModel.get(i)
                if(item.path == newFolderPath) {
                    root_renameSelectionBar.append(item.path, item)
                    break
                }
            }
        }
    }

    /**
      *
      */
    property url path

    /**
      *
      */
    property bool selectionMode : false

    property int gridItemSize :  Maui.Style.iconSizes.large * 1.7
    property int listItemSize :  Maui.Style.rowHeight


    property int gridItemCount: 0
    /**
      *
      */
    property int currentIndex : -1
    Binding on currentIndex {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    onPathChanged: {
        if(control.currentView) {
            console.log("browseritem onPathChanged")
            root.searchState = false
            control.currentIndex = 0
            control.currentView.forceActiveFocus()
        }
    }

    //group properties from the browser since the browser views are loaded async and
    //their properties can not be accesed inmediately, so they are stored here and then when completed they are set
    /**
      *
      */
    property alias settings : _settings
    BrowserSettings {
        id: _settings
        onGroupChanged: {
            currentView.section.property = ""
        }
    }

    /**
      *
      */
    property Maui.FMList currentFMList

    /**
      *
      */
    property Maui.BaseModel currentFMModel

    /**
      *
      */
    property alias currentView : viewLoader.item

    /**
      *
      */
    property string filter

    /**
      *
      */
    function setCurrentFMList() {
        if(control.currentView) {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            currentView.forceActiveFocus()
        }
    }

    /**
      *
      */
    function groupBy() {
    }

    Menu {
        id: _dropMenu
        property string urls
        property url target

        enabled: Maui.FM.getFileInfo(target).isdir == "true" && !urls.includes(target.toString())

        MenuItem {
            text: i18n("Copy here")
            onTriggered:  {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.copy(urls, _dropMenu.target, false)
            }
        }

        MenuItem {
            text: i18n("Move here")
            onTriggered:  {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.cut(urls, _dropMenu.target)
            }
        }

        MenuItem {
            text: i18n("Link here")
            onTriggered:  {
                const urls = _dropMenu.urls.split(",")
                for(var i in urls)
                    Maui.FM.createSymlink(url[i], _dropMenu.target)
            }
        }

        MenuSeparator {}

        MenuItem  {
            text: i18n("Cancel")
            onTriggered: _dropMenu.close()
        }
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        focus: true
        sourceComponent: switch(settings.viewType){
            case Maui.FMList.ICON_VIEW: return gridViewBrowser
            case Maui.FMList.LIST_VIEW: return listViewBrowser
        }

        onLoaded: setCurrentFMList()
    }

    Maui.FMList {
        id: _commonFMList
        path: control.path
        onSortByChanged: if(settings.group) groupBy()
        onlyDirs: settings.onlyDirs
        filterType: settings.filterType
        filters: settings.filters
        sortOrder: settings.sortOrder
        sortBy: settings.sortBy
        hidden: settings.showHiddenFiles
        foldersFirst: settings.foldersFirst

        onStatusChanged:  {
            if(status.title == "Nothing here!") {
                root.isNothingHere = true
            }else if(!status.empty) {
                root.isNothingHere = false
            }
        }
    }

    Component{
        id: listViewBrowser

        ListBrowser {
            id: _listViewBrowser

            anchors.fill: parent
            objectName: "FM ListBrowser"
            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            selectionMode: control.selectionMode
            property bool checkable: control.selectionMode
            enableLassoSelection: false
            currentIndex: control.currentIndex

            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal itemToggled(int index, bool state)

            model: Maui.BaseModel {
                id: _browserModel
                list: _commonFMList
                filter: control.filter
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            onCountChanged: {
                if(root.isCreateFolfer) {
                    timer.start()
                    root.isCreateFolfer = false
                }
            }

            section.delegate: Maui.LabelDelegate  {
                id: delegate
                width: parent ? parent.width : 0
                height: Maui.Style.toolBarHeightAlt

                label: _listViewBrowser.section.property == "date" || _listViewBrowser.section.property === "modified" ?  Qt.formatDateTime(new Date(section), "d MMM yyyy") : section
                labelTxt.font.pointSize: Maui.Style.fontSizes.big

                isSection: true
            }

            delegate: ListViewDelegate {
                id:listDelegate

                width: ListView.view.width
                height: 88
                iconSource: getIcon(model)
                fileDate : getDate(model.modified)
                fileSize : {
                    if(isFolder)  {
                        if(model.count) {
                            if(model.count.length > 4) {
                                "9999+" + i18n(" items")
                            }else {
                                model.count + i18n(" items")
                            }
                        }else {
                            ""
                        }
                    }else {
                        var fileSizeFormat = Maui.FM.formatSize(model.size)
                        if(fileSizeFormat.indexOf("KiB") != -1)  {
                            fileSizeFormat = fileSizeFormat.replace("KiB", "K")
                        }else if(fileSizeFormat.indexOf("MiB") != -1) {
                            fileSizeFormat = fileSizeFormat.replace("MiB", "M")
                        }else if(fileSizeFormat.indexOf("GiB") != -1) {
                            fileSizeFormat = fileSizeFormat.replace("GiB", "G")
                        }
                    }
                }
                isFolder : model.mime === "inode/directory"
                fileName : model.label
                draggable: true
                visible:  {
                    if(model.hidden == "true") {
                        false
                    }else {
                        true
                    }
                }

                onClicked: {
                    control.currentIndex = index

                    if(String(root.currentPath).startsWith("trash:/"))  {
                        return
                    }

                    if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier)) {
                        _listViewBrowser.itemsSelected([index])
                    }else {
                        _listViewBrowser.itemClicked(index)
                    }
                }

                onDoubleClicked: {
                    control.currentIndex = index
                    _listViewBrowser.itemDoubleClicked(index)
                }

                onPressAndHold: {
                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                    menuX = realMap.x
                    menuY = realMap.y
                    control.currentIndex = index
                    _listViewBrowser.itemRightClicked(index)
                }

                onRightClicked: {
                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                    menuX = realMap.x
                    menuY = realMap.y
                    control.currentIndex = index
                    _listViewBrowser.itemRightClicked(index)
                }

                onToggled: {
                    control.currentIndex = index
                    _listViewBrowser.itemToggled(index, state)
                }

                onContentDropped: {
                    _dropMenu.urls = drop.urls.join(",")
                    _dropMenu.target = model.path
                    _dropMenu.popup()
                }

                ListView.onRemove: {
                    if(selectionBar && !Maui.FM.fileExists(delegate.path)) {
                        selectionBar.removeAtUri(delegate.path)
                    }
                }

                Connections {
                    target: selectionBar

                    function onUriRemoved(uri)   {
                        if(uri === model.path)
                            delegate.checked = false
                    }

                    function onUriAdded(uri) {
                        if(uri === model.path)
                            delegate.checked = true
                    }

                    function onCleared() {
                        delegate.checked = false
                    }
                }
            }
        }
    }

    Component{
        id: gridViewBrowser

        GrideBrowser  {
            id: _gridViewBrowser
            objectName: "FM GridBrowser"

            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            itemSize : control.gridItemSize
            itemWidth: 200
            itemHeight: 230
            
            property bool checkable: control.selectionMode
            enableLassoSelection: true
            currentIndex: control.currentIndex

            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal itemToggled(int index, bool state)

            model: Maui.BaseModel {
                id: _browserModel
                list: _commonFMList
                filter: control.filter
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            onCountChanged: {
                if(root.isCreateFolfer) {
                    timer.start()
                    root.isCreateFolfer = false
                }
            }

            delegate: Rectangle {

                property bool isCurrentItem : GridView.isCurrentItem

                width: 200
                height: 230
                color: "#FFFFFFFF"
                clip: true

                visible:  {
                    if(model.hidden == "true") {
                        false
                    }else  {
                        true
                    }
                }

               anchors  {
                    left:  {
                        if(visible) {
                            parent.left
                        }else  {
                            wholeScreen.left
                        }
                    }
                    leftMargin: {
                        if(visible) {
                            (index % 6) * (width + (parent.width - (width * 6)) / 5)
                        }else {
                            0
                        }
                    } 

                    top:  {
                        if(visible) {
                            parent.top
                        }else {
                            wholeScreen.top
                        }
                    }
                    topMargin:  {
                        if(visible)  {
                            Math.floor(index / 6) * (height + 40)
                        }else {
                            0
                        }
                    }
               }
                
                GridView.onRemove: {
                    if(selectionBar && !Maui.FM.fileExists(delegate.path))  {
                        selectionBar.removeAtUri(delegate.path)
                    }
                }

               GridDelegate {
                    id: delegate

                    anchors.centerIn: parent
                    width: 200
                    height: 230
                    iconSource: getIcon(model)
                    fileDate : getDate(model.modified)
                    fileSize :  {
                        if(isFolder) {
                            if(model.count) {
                                if(model.count.length > 4) {
                                    "9999+" + i18n(" items")
                                }else {
                                    model.count + i18n(" items")
                                }
                            }else {
                                ""
                            }
                        }else {
                            var fileSizeFormat = Maui.FM.formatSize(model.size)
                            if(fileSizeFormat.indexOf("KiB") != -1){
                                fileSizeFormat = fileSizeFormat.replace("KiB", "K")
                            }else if(fileSizeFormat.indexOf("MiB") != -1) {
                                fileSizeFormat = fileSizeFormat.replace("MiB", "M")
                            }else if(fileSizeFormat.indexOf("GiB") != -1)  {
                                fileSizeFormat = fileSizeFormat.replace("GiB", "G")
                            }else {
                                fileSizeFormat
                            }
                        }
                    }
                    isFolder : model.mime === "inode/directory"
                    fileName : model.label
                    draggable: true

                    onClicked: {
                        control.currentIndex = index

                        if(String(root.currentPath).startsWith("trash:/"))  {
                            return
                        }

                        if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier)) {
                            _gridViewBrowser.itemsSelected([index])
                        }else {
                            _gridViewBrowser.itemClicked(index)
                        }
                    }

                    onDoubleClicked: {
                        control.currentIndex = index
                        _gridViewBrowser.itemDoubleClicked(index)
                    }

                    onPressAndHold:  {
                        var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                        menuX = realMap.x
                        menuY = realMap.y
                        control.currentIndex = index
                        _gridViewBrowser.itemRightClicked(index)
                    }

                    onRightClicked: {
                        var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                        menuX = realMap.x
                        menuY = realMap.y
                        control.currentIndex = index
                        _gridViewBrowser.itemRightClicked(index)
                    }

                    onToggled:  {
                        control.currentIndex = index
                        _gridViewBrowser.itemToggled(index, state)
                    }

                    onContentDropped: {
                        _dropMenu.urls = drop.urls.join(",")
                        _dropMenu.target = model.path
                        _dropMenu.popup()
                    }
                }
            }
        }
    }

    function getDate(fileDate) {
        var tmp = fileDate ? Maui.FM.formatDate(fileDate, "yyyy.MM.dd hh:mm AP") : ""
        tmp = tmp.replace("上午", "AM")
        tmp = tmp.replace("下午", "PM")
        return tmp
    }
}

