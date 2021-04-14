// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
// SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import Qt.labs.settings 1.0
import QtQml.Models 2.3

import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.index 1.0 as Index

import "widgets"
import "widgets/views"
import "widgets/previewer"

Kirigami.ApplicationWindow {
    fastBlurMode: true
    fastBlurColor: "#CCF7F7F7"

    id: root

    width: screen.width
    height: screen.height

    property string currentTitle: "Document"
    property bool isMenuPath: true
    property int textDefaultSize: theme.defaultFont.pointSize
    property bool selectionMode: false
    property alias dialog : dialogLoader.item
    property bool isCreateFolfer: false
    property string newFolderPath: "null"
    property bool searchState: false 
    property bool isSpecialPath: false 
    property bool isNothingHere: false
    property int menuX: 0
    property int menuY: 0 

    /*readonly*/ property url currentPath : currentBrowser ?  currentBrowser.currentPath : ""
    /*readonly*/ property FileBroswerView currentBrowser : currentTab && currentTab.browser ? currentTab.browser : null
    property var currentItem : ({})
    property alias currentTab : _browserList.currentItem
    property alias appSettings : settings
    property alias root_selectionBar : _selectionBar
    property alias root_renameSelectionBar : _renameSelectionBar
    property alias root_menuSelectionBar : _menuSelectionBar
    property alias root_compressDialogComponent: _compressDialogComponent 
    property alias root_extractDialogComponent: _extractDialogComponent
    property alias root_fileInfo: _fileInfo
    property alias root_indexColumn: indexColumn
    property alias pageContent: _browserList
    property var imageUrl: "" 
    property var imageTitle: "" 
    property int imageIndex: 0 
    property int deleteIndex: 0

    CustomPopup {
        id: customPopup
    }

    Index.LeftMenuData {
        id: leftMenuData
    }

    Index.CompressedFile {
        id: _compressedFile
    }

    FileInfo {
        id: _fileInfo
    }

    ToolTip {
        id: toast

        delay: 0
        timeout: 1500

        width: 556
        height: 130
        background: Rectangle {
            radius: 18
            ShaderEffectSource {
                id: footerBlur

                width: parent.width
                height: parent.height

                visible: false
                sourceItem: wholeScreen
                sourceRect: Qt.rect(toast.x, toast.y, width, height)
            }

            FastBlur {
                id:fastBlur

                anchors.fill: parent

                source: footerBlur
                radius: 72
                cached: true
                visible: false
            }

            Rectangle {
                id:maskRect

                anchors.fill:fastBlur

                visible: false
                clip: true
                radius: 30
            }

            OpacityMask {
                id: mask
                anchors.fill: maskRect
                visible: true
                source: fastBlur
                maskSource: maskRect
            }

            Rectangle {
                anchors.fill: footerBlur
                color: "#80000000"
                radius: 30
            }
        }

        Text {
            id: toastText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 60
                right: parent.right
                rightMargin: 60
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter  
            wrapMode: Text.WrapAnywhere
            text: ""
            font {
                pointSize: theme.defaultFont.pointSize + 2
            }
            color: "white"
        }
    }
    

    onCurrentPathChanged: {
        leftMenu.syncSidebar(currentBrowser.currentPath)
        currentTitle = getCurrentTitle(currentBrowser.currentPath)
    }

    Settings {
        id: settings
        category: "Browser"
        property bool showHiddenFiles: false
        property bool showThumbnails: true
        property bool singleClick : Kirigami.Settings.isMobile ? true : Maui.Handy.singleClick
        property bool previewFiles : Kirigami.Settings.isMobile
        property bool restoreSession:  false
        property bool supportSplit : !Kirigami.Settings.isMobile

        property int viewType : Maui.FMList.LIST_VIEW 
        property int listSize : 0 // s-m-x-xl
        property int gridSize : 1 // s-m-x-xl

        property var lastSession : [[({'path': Maui.FM.homePath(), 'viewType': 1})]]
        property int lastTabIndex : 0
    }

    Settings {
        id: sortSettings
        category: "Sorting"
        property bool foldersFirst: true
        property int sortBy:  Maui.FMList.LABEL
        property int sortOrder : Qt.AscendingOrder
        property bool group : false
        property bool globalSorting: Kirigami.Settings.isMobile
    }

    Maui.SelectionBar {
        id: _renameSelectionBar
        y: -200
        width: 0
        height: 0
    }

    Maui.SelectionBar {
        id: _menuSelectionBar
        y: -200
        width: 0
        height: 0
    }

    Maui.SelectionBar {
        id: _selectionBar

        padding: Maui.Style.space.big
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
        maxListHeight: _browserList.height - (Maui.Style.contentMargins*2)

        onUrisDropped: {
            for(var i in uris)
            {
                if(!Maui.FM.fileExists(uris[i]))
                    continue;

                const item = Maui.FM.getFileInfo(uris[i])
                _selectionBar.append(item.path, item)
            }
        }

        onExitClicked: clear()

        listDelegate: Maui.ListBrowserDelegate {
            isCurrentItem: false
            Kirigami.Theme.inherit: true
            width: ListView.view.width
            height: Maui.Style.iconSizes.big + Maui.Style.space.big
            imageSource: root.showThumbnails ? model.thumbnail : ""
            iconSource: model.icon
            label1.text: model.label
            label2.text: model.path
            label3.text: ""
            label4.text: ""
            checkable: true
            checked: true
            iconSizeHint: Maui.Style.iconSizes.big
            onToggled: _selectionBar.removeAtIndex(index)
            background: Item {}
            onClicked: {
                _selectionBar.selectionList.currentIndex = index
            }
            onPressAndHold: removeAtIndex(index)
        }
    }

    Maui.TagsDialog {
        id: _tagsDialog
        taglist.strict: false

        onTagsReady: {
            composerList.updateToUrls(tags)
        }
    }

    Kirigami.JOpenModeDialog{id: _openWithDialog}

    property int jDialogType: 1
    Kirigami.JDialog {
        id: jDialog

        closePolicy: Popup.CloseOnEscape
        leftButtonText: "Cancel"
        rightButtonText: "Delete"
        title: "Delete"

        text: {
            if(_selectionBar.items.length > 1) {
                "Are you sure you want to delete these files?"
            } else {
                "Are you sure you want to delete the file?"
            }    
        }

        onLeftButtonClicked: {
            close()
        }

        onRightButtonClicked: {
            if(jDialogType == 1) {
                if(_selectionBar.items.length >= 1) {
                    Maui.FM.removeFiles(_selectionBar.uris)
                    clearSelectionBar()
                } else {
                    Maui.FM.removeFiles([currentItem.nickname])
                } 
            } else if(jDialogType == 2) {
                Maui.FM.emptyTrash()
            }
            close()
        }
    }

    Rectangle {
        id: wholeScreen

        anchors.fill: parent

        color: "#00000000"
        
        Rectangle {
            id: indexColumn

            width: wholeScreen.width / 4.27
            height: parent.height
            color: "#FFE8EFFF"

            Rectangle {
                id: leftSpace
                width: parent.width
                height: 30
                color: "#00000000"
            }

            Rectangle {
                id: indexRom

                anchors.top: leftSpace.bottom
                
                width: parent.width
                height: 140
                color: "#00000000"
                
                Text {
                    id: indexText

                    text: "Files"
                    elide: Text.ElideRight
                    color: '#FF000000'
                    font
                    {
                        pointSize: theme.defaultFont.pointSize + 18
                        bold: true
                    }

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 50

                    width: parent.width

                    MouseArea {
                        anchors.fill: parent

                        onDoubleClicked: {
                            Qt.quit()
                        }

                    }
                }
            }

            LeftMenu {
                id:leftMenu

                width: indexRom.width
                height: wholeScreen.height - indexRom.height - 15

                anchors.top: indexRom.bottom
                anchors.bottom: parent.bottom
            }
        }

        Rectangle {
            id: rightSpace
            width: wholeScreen.width - indexColumn.width
            height: 30
            color: "#FFFFFFFF"
            anchors{
                right: parent.right
            }
        }

        Rectangle {
            anchors{
                right: parent.right
                top: rightSpace.bottom
            }
            width: wholeScreen.width - indexColumn.width
            height: parent.height
            color: "#FFFFFFFF"


            Rectangle {
                id: topRect

                visible: !selectionMode
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: 140
                color: "#00000000"

                Kirigami.JIconButton {
                    id: backImage

                    width: 44 + 10
                    height: 44 + 10
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/back_arrow.png"
                    visible:!(isMenuPath && !searchState && !currentTab.currentItem.previewerVisible)
                    onClicked:  {
                        if(currentTab.currentItem.previewerVisible) {
                            currentTab.currentItem.popPreviewer()
                            if(searchState) {
                                currentTitle = "Search"
                            } else {
                                currentTitle = getCurrentTitle(currentBrowser.currentPath)
                            }
                        } else if(searchState) {
                            currentBrowser.refreshCurrentPath()
                            searchState = false
                            currentTitle = getCurrentTitle(currentBrowser.currentPath)
                        } else  {
                            currentBrowser.goBack()
                        }
                    }
                }

                Text {
                    id: contentTitle
                    text: {
                        currentTitle
                    }
                    elide: Text.ElideRight
                    color: '#FF000000'
                    font {
                        pointSize: theme.defaultFont.pointSize + 11
                        bold: true
                    }
                    visible: true
                    width: parent.width / 3
                    anchors.left: parent.left
                    anchors.leftMargin: 84
                    anchors.verticalCenter: parent.verticalCenter
                }

                Kirigami.JIconButton {
                    id: searchImage
                    visible: {
                        if(currentTab.currentItem.previewerVisible || searchState) {
                            false
                        } else {
                            true
                        }
                    }
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/search_icon.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 60
                    onClicked: {  
                        searchState = true
                        currentTitle = "Search"
                        searchRect.clear()
                        searchRect.forceActiveFocus()
                    }
                }

                Kirigami.JIconButton {
                    id: menuListImage
                    visible: {
                        if(currentTab.currentItem.previewerVisible || searchState) {
                            false
                        } else {
                            true
                        }
                    }
                    width: 44 + 10
                    height: 44 + 10
                    source:  {   
                        if(settings.viewType == 0) {
                            "qrc:/assets/menu_grid.png"
                        } else {
                            "qrc:/assets/menu_list.png"
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: searchImage.left
                    anchors.rightMargin: 70
                    onClicked: {  
                        customPopup.show(wholeScreen.width - (380 + 63), 135)
                    }
                }

                Kirigami.JIconButton {
                    id: addFolderImage
                    visible: {
                        if(String(root.currentPath).startsWith("trash:/") || currentTab.currentItem.previewerVisible || searchState
                        || isSpecialPath) {
                            false
                        } else {
                            true
                        }
                    }
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/add_folder.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: menuListImage.left
                    anchors.rightMargin: 70
                    onClicked: {  
                        addFolderImage.forceActiveFocus()
                        newFolderPath = leftMenuData.createDir(currentBrowser.currentPath, "Untitled Folder")
                        isCreateFolfer = true
                    }
                }

                Kirigami.JIconButton {
                    id: deleteAllImage
                    visible: {
                        if(String(root.currentPath).startsWith("trash:/") && !searchState) {
                            true
                        } else {
                            false
                        }
                    }
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/select_delete_all.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: menuListImage.left
                    anchors.rightMargin: 70
                    onClicked: {  
                        if(root.currentBrowser.currentFMList.count > 1) {
                            jDialog.text =  "Are you sure you want to delete these files?"
                        }else{
                            jDialog.text = "Are you sure you want to delete the file?"
                        }
                        jDialogType = 2
                        jDialog.open()
                    }
                }

                Kirigami.JSearchField {
                    id: searchRect

                    visible: searchState
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 60

                    width: 600
                    height: 44 + 10

                    focus: false
                    placeholderText: ""
                    Accessible.name: qsTr("Search")
                    Accessible.searchEdit: true

                    onRightActionTrigger: {
                        searchState = false
                        currentTitle = getCurrentTitle(currentBrowser.currentPath)
                    }

                    onTextChanged: {
                        currentBrowser.currentFMList.search(text, currentBrowser.currentFMList)
                    }
                }
            }

            Rectangle {
                visible:  {
                    if(selectionMode && !String(root.currentPath).startsWith("trash:/")) {
                        true
                    } else {
                        false
                    }
                }

                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: 140
                color: "#00000000"

                Kirigami.JIconButton{
                    id: selectAllImage
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_rect.png"
                    anchors.left: parent.left
                    anchors.leftMargin: 90
                    anchors.verticalCenter: parent.verticalCenter
                        onClicked: {  
                            if(_selectionBar.items.length == root.currentBrowser.currentFMList.count)
                            {
                                clearSelectionBar()
                            }else
                            {
                                clearSelectionBar()
                                selectAll()
                            }
                        }
                }

                Text {
                    id: selectCountText
                    anchors.left: selectAllImage.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: theme.defaultFont.pointSize + 2
                    text: "0"
                    color: "#FF000000"
                }

                Connections {
                    target: _selectionBar

                    onUriRemoved: {
                        selectCountText.text = _selectionBar.items.length
                        if(_selectionBar.items.length == 0) {
                            selectAllImage.source = "qrc:/assets/unselect_rect.png"
                            copyImage.source = "qrc:/assets/unselect_copy.png" 
                            cutImage.source = "qrc:/assets/unselect_cut.png"
                            deleteImage.source = "qrc:/assets/unselect_delete.png"
                            zipImage.source = "qrc:/assets/unselect_zip.png"
                            unzipImage.source = "qrc:/assets/unselect_unzip.png"
                            favImage.source = "qrc:/assets/unselect_fav.png"
                            tagImage.source = "qrc:/assets/unselect_tag.png"
                        }
                    }

                    onUriAdded: {
                        selectCountText.text = _selectionBar.items.length
                        if(_selectionBar.items.length == root.currentBrowser.currentFMList.count) {
                            selectAllImage.source = "qrc:/assets/select_all.png"
                        } else  {
                            selectAllImage.source = "qrc:/assets/select_rect.png"
                        }
                        copyImage.source = "qrc:/assets/select_copy.png" 
                        cutImage.source = "qrc:/assets/select_cut.png"
                        deleteImage.source = "qrc:/assets/select_delete.png"
                        zipImage.source = "qrc:/assets/select_zip.png"
                        unzipImage.source = "qrc:/assets/select_unzip.png"
                        favImage.source = "qrc:/assets/select_fav.png"
                        tagImage.source = "qrc:/assets/select_tag.png"
                    }

                    onCleared: {
                        selectCountText.text = _selectionBar.items.length
                        selectAllImage.source = "qrc:/assets/unselect_rect.png"
                        copyImage.source = "qrc:/assets/unselect_copy.png" 
                        cutImage.source = "qrc:/assets/unselect_cut.png"
                        deleteImage.source = "qrc:/assets/unselect_delete.png"
                        zipImage.source = "qrc:/assets/unselect_zip.png"
                        unzipImage.source = "qrc:/assets/unselect_unzip.png"
                        favImage.source = "qrc:/assets/unselect_fav.png"
                        tagImage.source = "qrc:/assets/unselect_tag.png"
                    }
                }

                Kirigami.JIconButton{
                    id: copyImage
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_copy.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: selectAllImage.right
                    anchors.leftMargin: (parent.width - 180 - (54 * 5)) / 4
                        onClicked: {  
                            _selectionBar.animate()
                            currentBrowser.copy(_selectionBar.uris)
                            showToast(_selectionBar.items.length + " files have been copied")
                        }
                }

                Kirigami.JIconButton{
                    id: cutImage
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_cut.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: copyImage.right
                    anchors.leftMargin: (parent.width - 180 - (54 * 5)) / 4
                        onClicked: {  
                            _selectionBar.animate()
                            currentBrowser.cut(_selectionBar.uris)
                            showToast(_selectionBar.items.length + " files have been cut")
                        }
                }

                Kirigami.JIconButton{
                    id: deleteImage
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_delete.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: cutImage.right
                    anchors.leftMargin: (parent.width - 180 - (54 * 5)) / 4
                        onClicked: {  
                            Maui.FM.moveToTrash(_selectionBar.uris)
                            if(root.isSpecialPath) {
                                for(var i = 0; i < _selectionBar.items.length; i++) {
                                    for(var j = 0; j < currentBrowser.currentFMList.count; j++) {
                                        if(_selectionBar.items[i].path === currentBrowser.currentFMModel.get(j).path) {
                                            root.currentBrowser.currentFMList.remove(j)
                                            break
                                        }
                                    }
                                }
                            }
                            clearSelectionBar()
                            selectionMode = false
                        }
                }

                Kirigami.JIconButton{
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/cancel_enable.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 90
                        onClicked: {  
                            selectionMode = false
                            clearSelectionBar()
                        }
                }
            }

            Rectangle {
                visible: (selectionMode && String(root.currentPath).startsWith("trash:/"))

                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: 140
                color: "#00000000"

                Kirigami.JIconButton{
                    id: selectAllImage_t
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_rect.png"
                    anchors.left: parent.left
                    anchors.leftMargin: wholeScreen.width / 21.82
                    anchors.verticalCenter: parent.verticalCenter
                        onClicked: {  
                            if(_selectionBar.items.length == root.currentBrowser.currentFMList.count)
                            {
                                clearSelectionBar()
                            }else
                            {
                                clearSelectionBar()
                                selectAll()
                            }
                        }
                }

                Text {
                    id: selectCountText_t
                    anchors.left: selectAllImage_t.right
                    anchors.leftMargin: wholeScreen.width / 192
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: theme.defaultFont.pointSize + 2
                    text: "0"
                    color: "#FF000000"
                }

                Connections {
                    target: _selectionBar

                    onUriRemoved: {
                        selectCountText_t.text = _selectionBar.items.length
                        if(_selectionBar.items.length == 0) {
                            selectAllImage_t.source = "qrc:/assets/unselect_rect.png"
                            recoverImage_t.source = "qrc:/assets/unselect_recover.png" 
                            deleteImage_t.source = "qrc:/assets/unselect_delete.png"
                        }
                    }

                    onUriAdded:  {
                        selectCountText_t.text = _selectionBar.items.length
                        if(_selectionBar.items.length == root.currentBrowser.currentFMList.count) {
                            selectAllImage_t.source = "qrc:/assets/select_all.png"
                        }  else  {
                            selectAllImage_t.source = "qrc:/assets/select_rect.png"
                        }
                        recoverImage_t.source = "qrc:/assets/select_recover.png"
                        deleteImage_t.source = "qrc:/assets/select_delete.png"
                    }

                    onCleared: {
                        selectCountText_t.text = _selectionBar.items.length
                        selectAllImage_t.source = "qrc:/assets/unselect_rect.png"
                        deleteImage_t.source = "qrc:/assets/unselect_delete.png"
                        recoverImage_t.source = "qrc:/assets/unselect_recover.png"
                    }
                }

                Kirigami.JIconButton{
                    id: recoverImage_t
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_recover.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: selectAllImage_t.right
                    anchors.leftMargin: wholeScreen.width / 4.99
                        onClicked: {  
                            leftMenuData.restoreFromTrash(_selectionBar.uris)
                            _selectionBar.animate()
                            clearSelectionBar()
                        }
                }

                Kirigami.JIconButton{
                    id: deleteImage_t
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/unselect_delete.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: recoverImage_t.right
                    anchors.leftMargin: wholeScreen.width / 4.99
                        onClicked: {  
                            if(_selectionBar.items.length > 0)  {
                                if(_selectionBar.items.length ==  1)  {
                                    jDialog.text = "Are you sure you want to delete the file?"
                                }else if(_selectionBar.items.length > 1)     {
                                    jDialog.text =  "Are you sure you want to delete these files?"
                                }
                                jDialogType = 1
                                jDialog.open()
                            }
                        }
                }

                Kirigami.JIconButton{
                    width: 44 + 10
                    height: 44 + 10
                    source: "qrc:/assets/cancel_enable.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: width + wholeScreen.width / 24
                        onClicked: {  
                            selectionMode = false
                            clearSelectionBar()
                        }
                }
            }

            ListView
            {
                id: _browserList
                anchors.top: parent.top
                anchors.topMargin: 140
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 40
                anchors.left: parent.left
                anchors.right: parent.right   
                width: parent.width
                height: parent.height 

                clip: true
                focus: true

                
                model: tabsObjectModel
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds

                MouseArea
                {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    propagateComposedEvents: true
                    onClicked: 
                    {  
                        if (mouse.button == Qt.RightButton)  { 
                            if(mouse.x <= 90 || mouse.x >= _browserList.width - 90) {
                                if(String(root.currentPath).startsWith("trash:/"))   {
                                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                    menuX = realMap.x
                                    menuY = realMap.y
                                    currentBrowser.trashNormalMenu.show(_browserList)
                                }else if(!isSpecialPath)  {
                                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                    menuX = realMap.x
                                    menuY = realMap.y
                                    currentBrowser.browserMenu.show()
                                } 

                            }else  {
                                mouse.accepted = false
                            }
                        }else if(mouse.button == Qt.LeftButton)
                        {
                            if(selectionMode || (mouse.x > 90 && mouse.x < _browserList.width - 90)) {
                                mouse.accepted = false
                            }
                        }
                    }

                    onPressAndHold: {
                        if(mouse.x <= 90 || mouse.x >= _browserList.width - 90)  {
                            if(String(root.currentPath).startsWith("trash:/")) {
                                var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                menuX = realMap.x
                                menuY = realMap.y
                                currentBrowser.trashNormalMenu.show(_browserList)
                            }else if(!isSpecialPath)  {
                                var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                menuX = realMap.x
                                menuY = realMap.y
                                currentBrowser.browserMenu.show()
                            } 
                        }else  {
                            mouse.accepted = false
                        }  
                    }

                    onPressed: {
                        if (mouse.button == Qt.RightButton)  { 
                            if(mouse.x <= 60 || mouse.x >= 1425) {
                            }else {
                                mouse.accepted = false
                            }
                        }else if(mouse.button == Qt.LeftButton) {
                            if(mouse.x > 60 && mouse.x < 1425)  {
                                mouse.accepted = false
                            }
                        }
                    }

                    onReleased: {
                        if (mouse.button == Qt.RightButton)  { 
                            if(mouse.x <= 60 || mouse.x >= 1425) {
                            }else {
                                mouse.accepted = false
                            }
                        }else if(mouse.button == Qt.LeftButton) {
                            if(mouse.x > 60 && mouse.x < 1425) {
                                mouse.accepted = false
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    userNameBrowser = currentBrowser
                    testTab = currentTab
                }
            }

            Item {
                id: nullPage
                visible: isNothingHere
                anchors.top: parent.top
                anchors.topMargin: 140
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right   
                width: parent.width
                height: parent.height 

                Image {
                    id: emptyImage
                    anchors.top: parent.top
                    anchors.topMargin: wholeScreen.height / 3.55
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 120
                    height: 120
                    source: "qrc:/assets/empty.png"
                }

                Text {
                    anchors{
                        top: emptyImage.bottom
                        topMargin: 30
                        horizontalCenter: parent.horizontalCenter
                    }
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        if(searchState) {   
                            "No Results"
                        }else {
                            "There are no files at present."
                        }
                    } 
                    font.pointSize: textDefaultSize + 2
                    color: "#4D3C3C43"
                }
            }
        }

        ImageViewer {
            id: imageViewer
            anchors.fill: parent
            visible: false
        }

        Loader {
            id: dialogLoader
        }

        Component  {
            id: _extractDialogComponent

            Maui.Dialog {
                id: _extractDialog
                title: i18n("Extract")
                message: i18n("Extract the content of the compressed file into a new or existing subdirectory or inside the current directory.")
                entryField: true
                page.margins: Maui.Style.space.big

                onAccepted: {
                    _compressedFile.extract(currentPath, textEntry.text)
                    _extractDialog.close()
                }
            }
        }

        Component {
            id: _compressDialogComponent

            Maui.FileListingDialog {
                id: _compressDialog

                title: i18np("Compress %1 file", "Compress %1 files", urls.length)
                message: i18n("Compress selected files into a new file.")

                textEntry.placeholderText: i18n("Archive name...")
                entryField: true

                function clear() {
                    textEntry.clear()
                    compressType.currentIndex = 0
                    urls = []
                    _showCompressedFiles.checked = false
                }

                Maui.ToolActions {
                    id: compressType
                    autoExclusive: true
                    expanded: true
                    currentIndex: 0

                    Action {
                        text: ".ZIP"
                    }

                    Action {
                        text: ".TAR"
                    }
                }

                onRejected: {
                    _compressDialog.close()
                }

                onAccepted: {
                    var error = _compressedFile.compress(urls, currentPath, textEntry.text, compressType.currentIndex)
                    _compressDialog.close()
                }
            }
        }

        ObjectModel { id: tabsObjectModel }

        Component.onCompleted: {
            root.openTab(Maui.FM.homePath())
        }
    }

    function openTab(path){
        if(path) {
            const component = Qt.createComponent("qrc:/widgets/views/BrowserLayout.qml");
            if (component.status === Component.Ready) {
                const object = component.createObject(tabsObjectModel, {'path': path});
                tabsObjectModel.append(object)
                _browserList.currentIndex = tabsObjectModel.count - 1
            }
        }
    }

    function getCurrentTitle(path) {
        path = path.toString()
        if(path == leftMenuData.getRootPath()) {
            return "On My Pad"//"root"
        }else  if(path == leftMenuData.getTrashPath()) {
            return "Trash"
        }else {
            var index = path.lastIndexOf("/")
            if(index == -1) {
                return path
            }else {
                return path.substring(index + 1)
            }
        }
    }

    function openWith(item)
    {
        var services = Maui.KDE.services(item.path)
        if(services.length <= 0){
            showToast("Sorry, opening this file is not supported at present.")
            return;
        }else  {
            if(item.mime.indexOf("video") != -1 || Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime) || (item.mime.indexOf("audio") != -1)) {
                    _openWithDialog.model.clear()
                    _openWithDialog.urls = [item.path]
                    for(var i in services) {
                        _openWithDialog.model.append(services[i])
                    }
                    _openWithDialog.open()
            }else {
                if(services.length == 1) {
                    Maui.KDE.openWithApp(services[0].actionArgument, [item.path])
                    return;
                }else {
                    _openWithDialog.model.clear()
                    _openWithDialog.urls = [item.path]
                    for(var i in services)
                    {
                        _openWithDialog.model.append(services[i])
                    }
                    _openWithDialog.open()
                }
            }
        }
    }

    function addToSelection(item, index) {
        if(_selectionBar == null || item.path.startsWith("tags://") || item.path.startsWith("applications://")) {
            return
        }

        if(_selectionBar.contains(item.nickname))  {
            _selectionBar.removeAtUri(item.nickname)
            return
        }

        _selectionBar.append(item.nickname, item)
    }

    function selectAll(){
        if(_selectionBar == null) {
            return
        }
        selectIndexes([...Array(root.currentBrowser.currentFMList.count).keys()])
    }

    function selectIndexes(indexes){
        if(_selectionBar == null){
            return
        }
        for(var i in indexes)
            addToSelection(root.currentBrowser.currentFMModel.get(indexes[i]), i)
    }

    function getIcon(model){
        var imageSource = ""
        if(model.mime == "inode/directory"){
            imageSource = "qrc:/assets/folder_icon.png"
        }else if(model.mime.indexOf("image/jpeg") != -1) {
            imageSource = leftMenuData.getVideoPreview(model.path)
        }else if(model.mime.indexOf("image") != -1) {
            imageSource = model.thumbnail
        }else if(model.mime.indexOf("audio") != -1) {
            imageSource = "qrc:/assets/music.png"
        }else if((model.mime.indexOf("text") != -1)
        || (model.mime.indexOf("doc") != -1)) {
            imageSource = "qrc:/assets/word.png"
        }else if(model.mime.indexOf("ppt") != -1) {
            imageSource = "qrc:/assets/ppt.png"
        }else if(model.mime.indexOf("video") != -1) {
            imageSource = leftMenuData.getVideoPreview(model.path)
        }else if(model.mime.indexOf("xls") != -1) {
            imageSource = "qrc:/assets/excel.png"
        }else if(model.mime.indexOf("7zip") != -1) {
            imageSource = "qrc:/assets/7zip.png"
        }else if(model.mime.indexOf("zip") != -1) {
            imageSource = "qrc:/assets/zip.png"
        }else if(model.mime.indexOf("rar") != -1) {
            imageSource = "qrc:/assets/rar.png"
        }else if(model.mime.indexOf("tar") != -1) {
            imageSource = "qrc:/assets/tar.png"
        }  else {
            imageSource = "qrc:/assets/default.png"
        }   
        return imageSource
    }

    function showImageViewer(item){
        imageViewer.myheader.currentname = item.label
        imageUrl = item.path
        imageViewer.visible = true
    }

    function hideImageViewer() {
        imageUrl = ""
        imageViewer.visible = false
    }

    function showToast(tips) {
        toastText.text = tips
        toast.x = (wholeScreen.width - toast.width) / 2
        toast.y = wholeScreen.height / 4 * 3
        toast.visible = true  
    }

    function clearSelectionBar() {
        _selectionBar.clear()
    }
}
