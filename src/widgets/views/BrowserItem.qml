
/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page {
    id: control

    headBar.visible: false
    title: currentFMList.pathName

    background: Rectangle {
        color: Kirigami.JTheme.colorScheme === "jingosLight" ? "#ffffffff" : "#ff000000"
    }

    Timer {
        id: timer
        running: false
        repeat: false
        interval: 10

        onTriggered: {
            for (var i = 0; i < currentFMList.count; i++) {
                var item = currentFMModel.get(i)
                if (item.path == newFolderPath) {
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
    property bool selectionMode: false

    property int gridItemSize: Maui.Style.iconSizes.large * 1.7
    property int listItemSize: Maui.Style.rowHeight

    property int gridItemCount: 0


    /**
      *
      */
    property int currentIndex: -1
    Binding on currentIndex {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    onPathChanged: {
        if (control.currentView) {
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
    property alias settings: _settings
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
    property alias currentView: viewLoader.item


    /**
      *
      */
    property string filter


    /**
      *
      */
    function setCurrentFMList() {
        if (control.currentView) {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            currentView.forceActiveFocus()
        }
    }


    /**
      *
      */
    function groupBy() {}

    Menu {
        id: _dropMenu
        property string urls
        property url target

        enabled: Maui.FM.getFileInfo(target).isdir == "true" && !urls.includes(
                     target.toString())

        MenuItem {
            text: i18n("Copy here")
            onTriggered: {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.copy(urls, _dropMenu.target, false)
            }
        }

        MenuItem {
            text: i18n("Move here")
            onTriggered: {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.cut(urls, _dropMenu.target)
            }
        }

        MenuItem {
            text: i18n("Link here")
            onTriggered: {
                const urls = _dropMenu.urls.split(",")
                for (var i in urls)
                    Maui.FM.createSymlink(url[i], _dropMenu.target)
            }
        }

        MenuSeparator {}

        MenuItem {
            text: i18n("Cancel")
            onTriggered: _dropMenu.close()
        }
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        focus: true
        sourceComponent: switch (settings.viewType) {
                         case Maui.FMList.ICON_VIEW:
                             return gridViewBrowser
                         case Maui.FMList.LIST_VIEW:
                             return listViewBrowser
                         }

        onLoaded: setCurrentFMList()
    }

    Maui.FMList {
        id: _commonFMList
        path: control.path
        onSortByChanged: if (settings.group)
                             groupBy()
        onlyDirs: settings.onlyDirs
        filterType: settings.filterType
        filters: settings.filters
        sortOrder: settings.sortOrder
        sortBy: settings.sortBy
        hidden: settings.showHiddenFiles
        foldersFirst: settings.foldersFirst

        onStatusChanged: {
            if (status.title == "Nothing here!") {
                root.isNothingHere = true
            } else if (!status.empty) {
                root.isNothingHere = false
            }
        }
    }

    Component {
        id: listViewBrowser

        ListBrowser {
            id: _listViewBrowser

            anchors.fill: parent
            objectName: "FM ListBrowser"
            property alias currentFMList: _browserModel.list
            property alias currentFMModel: _browserModel
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
                if (root.isCreateFolfer) {
                    timer.start()
                    root.isCreateFolfer = false
                }
            }

            section.delegate: Maui.LabelDelegate {
                id: delegate
                width: parent ? parent.width : 0
                height: Maui.Style.toolBarHeightAlt

                label: _listViewBrowser.section.property == "date"
                       || _listViewBrowser.section.property
                       === "modified" ? Qt.formatDateTime(
                                            new Date(section),
                                            "d MMM yyyy") : section
                labelTxt.font.pointSize: Maui.Style.fontSizes.big

                isSection: true
            }

            delegate: Item {
                id: listDelegate
                width: ListView.view.width
                height: 44 * appScaleSize
                ListViewDelegate {
                    anchors.fill: parent
                    anchors.leftMargin: 42 * appScaleSize
                    anchors.rightMargin: 28 * appScaleSize
                    iconSource: getIcon(model)
                    fileDate: getDate(model.modified)
                    fileSize: {
                        if (isFolder) {
                            if (model.count) {
                                if (model.count.length > 4) {
                                    "9999+ " + i18n("items")
                                } else {
                                    model.count + " " + i18n("items")
                                }
                            } else {
                                ""
                            }
                        } else {
                            var fileSizeFormat = Maui.FM.formatSizeForQulonglong(
                                        model.size) //格式化文件大小
                            if (fileSizeFormat.indexOf("KiB") !== -1) {
                                fileSizeFormat = fileSizeFormat.replace("KiB",
                                                                        "K")
                            } else if (fileSizeFormat.indexOf("MiB") !== -1) {
                                fileSizeFormat = fileSizeFormat.replace("MiB",
                                                                        "M")
                            } else if (fileSizeFormat.indexOf("GiB") !== -1) {
                                fileSizeFormat = fileSizeFormat.replace("GiB",
                                                                        "G")
                            } else {
                                fileSizeFormat
                            }
                        }
                    }
                    tagSource: getTagSource(model)

                    isFolder: model.mime === "inode/directory"
                    fileName: model.label
                    draggable: true
                    visible: {
                        if (model.hidden == "true")
                        {
                            false
                        } else {
                            true
                        }
                    }

                    onClicked: {
                        control.currentIndex = index
                        if (String(root.currentPath).startsWith("trash:/")
                                && !root.selectionMode) {
                            return
                        }

                        if ((mouse.button == Qt.LeftButton)
                                && (mouse.modifiers & Qt.ControlModifier))
                        {
                            root.selectionMode = true
                            _listViewBrowser.itemsSelected([index])
                        } else {
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
                        console.log("browser item 111111 item right clicked idnex " + index)
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
                        if (selectionBar && !Maui.FM.fileExists(
                                    delegate.path)) {
                            selectionBar.removeAtUri(delegate.path)
                        }
                    }

                    Connections {
                        target: selectionBar

                        function onUriRemoved(uri) {
                            if (uri === model.path)
                                delegate.checked = false
                        }

                        function onUriAdded(uri) {
                            if (uri === model.path)
                                delegate.checked = true
                        }

                        function onCleared() {
                            delegate.checked = false
                        }
                    }
                }
            }
        }
    }

    Component {
        id: gridViewBrowser

        GrideBrowser {
            id: _gridViewBrowser
            objectName: "FM GridBrowser"

            property alias currentFMList: _browserModel.list
            property alias currentFMModel: _browserModel
            itemSize: control.gridItemSize
            itemWidth: 100 * appScaleSize
            itemHeight: (115 + 10) * appScaleSize

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
                if (root.isCreateFolfer) {
                    timer.start()
                    root.isCreateFolfer = false
                }
            }

            delegate: Item {
                property bool isCurrentItem: GridView.isCurrentItem
                width: 100 * appScaleSize
                height: (115 + 10) * appScaleSize
                clip: true
                visible: model.hidden === true ? false : true
                anchors.left: visible ? parent.left : wholeScreen.left
                anchors.leftMargin: visible ? (index % 5)
                                              * (width + (parent.width - (width * 5)) / 4) : 0
                anchors.top: visible ? parent.top : wholeScreen.top
                anchors.topMargin: visible ? Math.floor(
                                                 index / 5) * (height + 20 * appScaleSize) : 0

                GridView.onRemove: {
                    if (selectionBar && !Maui.FM.fileExists(delegate.path)) {
                        selectionBar.removeAtUri(delegate.path)
                    }
                }

                GridDelegate {
                    id: delegate
                    anchors.fill: parent
                    iconSource: getIcon(model)
                    fileDate: getDate(model.modified)
                    fileSize: {
                        if (isFolder) {
                            if (model.count) {
                                if (model.count.length > 4) {
                                    "9999+ " + i18n("items")
                                } else {
                                    model.count + " " + i18n("items")
                                }
                            } else {
                                ""
                            }
                        } else {
                            var fileSizeFormat = Maui.FM.formatSizeForQulonglong(
                                        model.size)
                            if (fileSizeFormat.indexOf("KiB") !== -1) {
                                fileSizeFormat = fileSizeFormat.replace("KiB",
                                                                        "K")
                            } else if (fileSizeFormat.indexOf("MiB") !== -1) {
                                fileSizeFormat = fileSizeFormat.replace("MiB",
                                                                        "M")
                            } else if (fileSizeFormat.indexOf("GiB") !== -1) {
                                fileSizeFormat = fileSizeFormat.replace("GiB",
                                                                        "G")
                            } else {
                                fileSizeFormat
                            }
                        }
                    }
                    tagSource: getTagSource(model)
                    isFolder: model.mime === "inode/directory"
                    fileName: model.label
                    draggable: true

                    onClicked: {
                        control.currentIndex = index
                        if (String(root.currentPath).startsWith("trash:/")
                                && !root.selectionMode) {
                            return
                        }

                        if ((mouse.button == Qt.LeftButton)
                                && (mouse.modifiers & Qt.ControlModifier)) //ctrl + leftbutton
                        {
                            root.selectionMode = true
                            _gridViewBrowser.itemsSelected([index])
                        } else {
                            _gridViewBrowser.itemClicked(index)
                        }
                    }

                    onDoubleClicked: {
                        control.currentIndex = index
                        _gridViewBrowser.itemDoubleClicked(index)
                    }

                    onPressAndHold: {
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

                    onToggled: {
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

    function getDate(fileDate)
    {
        var formatStr = "yyyy.MM.dd hh:mm AP"
        if (leftMenuData.is24HourFormat()) {
            formatStr = "yyyy.MM.dd hh:mm"
        }
        var tmp = fileDate ? Maui.FM.formatDate(fileDate, formatStr) : ""
        if (formatStr == "yyyy.MM.dd hh:mm AP") {
            tmp = tmp.replace("上午", "AM")
            tmp = tmp.replace("下午", "PM")
        }
        return tmp
    }

    Connections {
        target: _compressedFile

        onStartZip: {
            const index = root_zipList._uris.indexOf(filePath)
            if (index < 0) {
                root_zipList._uris.push(filePath)
            }
        }

        onFinishZip: {
            const index = root_zipList._uris.indexOf(filePath)
            if (index != -1) {
                root_zipList._uris.splice(index, 1)
            }
            for (var j = 0; j < root.currentBrowser.currentFMList.count; j++) {
                var listItem = root.currentBrowser.currentFMModel.get(j)
                if (listItem.path == filePath) {
                    root.currentBrowser.currentFMList.refreshItem(j,
                                                                  listItem.path)
                    break
                }
            }
        }
        onTipMessage: {
            if (messageType === "decompressing") {
                showToast(i18n("Existing decompressed file"))
            } else if (messageType === "compressing") {
                showToast(i18n("Existing compressed file"))
            }
        }
    }
}
