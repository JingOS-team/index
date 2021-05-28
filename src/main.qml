// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
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

Kirigami.ApplicationWindow
{
    fastBlurMode: true
    fastBlurColor: "#CCF7F7F7"

    id: root

    width: screen.width
    height: screen.height

    //当前页面的item数量--root.currentBrowser.currentFMList.count
    //当前页面的model--root.currentBrowser.currentFMModel
    //刷新当前页面 root.currentBrowser.currentFMList.refresh()

    property bool isOpenWithUrl: false //是否是从外部带参启动的  目前的逻辑没有用到了
    property string currentTitle: i18n("Document")
    property bool isMenuPath: true //是否是左边menu预置的路径 如果是的话 就没有回退的箭头
    property int textDefaultSize: theme.defaultFont.pointSize
    property bool selectionMode: false //是否是编辑状态
    property alias dialog : dialogLoader.item
    property bool isCreateFolfer: false //是否创建了新文件夹
    property string newFolderPath: "null"
    property bool searchState: false //当前是否为搜索状态
    // property bool musicState: false //当前是否为播放音乐状态
    property bool isSpecialPath: false //是否是特殊的路径 如document music等 特殊目录不允许创建新的文件夹和粘贴
    property bool isNothingHere: false
    property int menuX: 0 //计算右键menu的弹出位置
    property int menuY: 0 //计算右键menu的弹出位置

    //origin start
    /*readonly*/ property url currentPath : currentBrowser ?  currentBrowser.currentPath : ""
    /*readonly*/ property FileBroswerView currentBrowser : currentTab && currentTab.browser ? currentTab.browser : null
    property var currentItem : ({})
    property alias currentTab : _browserList.currentItem
    property alias appSettings : settings
    property alias root_zipList : _zipList
    property alias root_selectionBar : _selectionBar
    property alias root_renameSelectionBar : _renameSelectionBar
    property alias root_menuSelectionBar : _menuSelectionBar
    // property alias root_compressDialogComponent: _compressDialogComponent //压缩文件的提示
    // property alias root_extractDialogComponent: _extractDialogComponent //解压缩文件的提示
    property alias root_fileInfo: _fileInfo//文件 文件夹详情页面
    property alias root_editTagMenu: _editTagMenu //标签编辑页
    property alias root_tagMenu: _tagMenu
    property alias root_indexColumn: indexColumn
    property alias pageContent: _browserList
    property alias leftMenu: leftMenu
    property var imageUrl: "" //图片展示的path
    property var imageTitle: "" //图片展示的title
    property int imageIndex: 0 //用来做左右滑切换图片的index记录
    property int deleteIndex: 0 //用来记录需要删除的item索引 特殊目录删除逻辑需要
    property alias root_nullPage: nullPage
    // property Maui.FMList typeFMList: ""

    CustomPopup { //自己做的带三角的menu背景
        id: customPopup
    }

    Index.LeftMenuData
    {
        id: leftMenuData
    }

    Index.CompressedFile//压缩 解压缩
    {
        id: _compressedFile
    }

    FileInfo
    {
        id: _fileInfo
    }

    TagMenu
    {
        id: _tagMenu
    }

    EditTagMenu
    {
        id: _editTagMenu
    }

    ToolTip//toast
    {
        id: toast

        delay: 0
        timeout: 1500

        width: 278
        height: 65
        background: Rectangle
        {
            radius: 9
            ShaderEffectSource
            {
                id: footerBlur

                width: parent.width
                height: parent.height

                visible: false
                sourceItem: wholeScreen
                sourceRect: Qt.rect(toast.x, toast.y, width, height)
            }

            FastBlur{
                id:fastBlur

                anchors.fill: parent

                source: footerBlur
                radius: 72
                cached: true
                visible: false
            }

            Rectangle{
                id:maskRect

                anchors.fill:fastBlur

                visible: false
                clip: true
                radius: 15
            }
            OpacityMask{
                id: mask
                anchors.fill: maskRect
                visible: true
                source: fastBlur
                maskSource: maskRect
            }

            Rectangle{
                anchors.fill: footerBlur
                color: "#80000000"
                radius: 15
            }
        }
        Text
        {
            id: toastText
            // width:436
            anchors{
                // horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 30
                right: parent.right
                rightMargin: 30
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter  
            wrapMode: Text.WrapAnywhere
            text: ""
            font
            {
                pixelSize: 17
            }
            color: "white"
        }
    }

    onCurrentPathChanged:
    {
        leftMenu.syncSidebar(currentBrowser.currentPath)
        currentTitle = getCurrentTitle(currentBrowser.currentPath)
    }

    Settings
    {
        id: settings
        category: "Browser"
        property bool showHiddenFiles: false
        property bool showThumbnails: true
        property bool singleClick : Kirigami.Settings.isMobile ? true : Maui.Handy.singleClick
        property bool previewFiles : Kirigami.Settings.isMobile
        property bool restoreSession:  false
        property bool supportSplit : !Kirigami.Settings.isMobile

        property int viewType : Maui.FMList.LIST_VIEW   //listview的布局 0--grid 1--list
        property int listSize : 0 // s-m-x-xl
        property int gridSize : 1 // s-m-x-xl

        property var lastSession : [[({'path': Maui.FM.homePath(), 'viewType': 1})]]
        property int lastTabIndex : 0
    }

    Settings
    {
        id: sortSettings
        category: "Sorting"
        property bool foldersFirst: true
        property int sortBy:  Maui.FMList.LABEL
        property int sortOrder : Qt.AscendingOrder
        property bool group : false
        property bool globalSorting: Kirigami.Settings.isMobile
    }

    Settings
    {
        id: tagsSettings
        category: "tagsSettings"
        property string tag0: i18n("Important")
        property string tag1: i18n("Life")
        property string tag2: i18n("Temporary")
        property string tag3: i18n("Work")
        property string tag4: i18n("Meeting")
        property string tag5: i18n("File")
        property string tag6: i18n("Picture")
        property string tag7: i18n("Private")
    }

    property QtObject m_zipList : QtObject
    {
        id: _zipList
        property var _uris : []
    }


    // Maui.SelectionBar//重命名的逻辑会用到
    // {
    //     id: _renameSelectionBar
    //     y: -200
    //     width: 0
    //     height: 0
    // }
    SelectionBar//重命名的逻辑会用到
    {
        id: _renameSelectionBar
    }

    // Maui.SelectionBar//用来做右键menu的灰色效果
    // {
    //     id: _menuSelectionBar
    //     y: -200
    //     width: 0
    //     height: 0
    // }

    SelectionBar//用来做右键menu的灰色效果
    {
        id: _menuSelectionBar
    }


    // Maui.SelectionBar//用来保存编辑态多选的数据
    // {
    //     id: _selectionBar
    //     onExitClicked: clear()
    // }

    SelectionBar//用来保存编辑态多选的数据
    {
        id: _selectionBar
    }

    // Maui.OpenWithDialog {id: _openWithDialog}
    //origin end

    //modify by huan lele
    //OpenWithDialog {id: _openWithDialog}
    //end modify 
    // add by huan lele 
    Kirigami.JOpenModeDialog{id: _openWithDialog}
    //end add


    property int jDialogType: 1 //1--选中items删除 2--删除所有
    Kirigami.JDialog
    {
        id: jDialog

        closePolicy: Popup.CloseOnEscape
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("Delete")
        title: i18n("Delete")

        text: 
        {
            if(_selectionBar.items.length > 1)
            {
                i18n("Are you sure you want to delete these files?")
            }else
            {
                i18n("Are you sure you want to delete the file?")
            }    
        }

        onLeftButtonClicked:
        {
            close()
        }

        onRightButtonClicked:
        {
            if(jDialogType == 1)
            {
                if(_selectionBar.items.length >= 1)
                {
                    Maui.FM.removeFiles(_selectionBar.uris)
                    // _selectionBar.clear()
                    clearSelectionBar()
                }else
                {
                    // Maui.FM.removeFiles([currentItem.path])
                    Maui.FM.removeFiles([currentItem.nickname])
                } 
            }else if(jDialogType == 2)
            {
                Maui.FM.emptyTrash()
            }

            selectionMode = false
            close()
        }
    }

    Rectangle//整个屏幕
    {
        id: wholeScreen

        anchors.fill: parent
        // width: 888
        // height: 648

        color: "#00000000"
        
        Rectangle//左侧菜单区域
        {
            id: indexColumn

            width: wholeScreen.width / 4.27
            height: parent.height
            // color: "#00000000"
            color: "#FFE8EFFF"

            Rectangle
            {
                id: leftSpace
                width: parent.width
                height: 30
                color: "#00000000"
            }

            Rectangle
            {
                id: indexRom

                anchors.top: leftSpace.bottom
                // anchors.topMargin: wholeScreen.height / 30
                
                width: parent.width
                height: 68
                color: "#00000000"
                
                // Image
                // {   
                //     id: indexIcon    

                //     source: "assets/files.png"
                //     fillMode: Image.PreserveAspectFit

                //     anchors.left: parent.left
                //     anchors.leftMargin: wholeScreen.width / 38.4 

                //     width: wholeScreen.width / 28.23 
                //     height: wholeScreen.width / 28.23 

                //     MouseArea {
                //         anchors.fill: parent

                //         onDoubleClicked:
                //         {
                //             Qt.quit()
                //         }

                //     }
                // }

                Text//Files Title
                {
                    id: indexText

                    text: i18n("Files")
                    elide: Text.ElideRight
                    color: '#FF000000'
                    font
                    {
                        pixelSize: 25
                        bold: true
                    }

                    // anchors.bottom: parent.bottom
                    // anchors.left: indexIcon.right
                    // anchors.leftMargin: wholeScreen.width / 96
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 25

                    width: parent.width

                    MouseArea {
                        anchors.fill: parent

                        onDoubleClicked:
                        {
                            Qt.quit()
                        }

                    }
                }
            }

            LeftMenu
            {
                id:leftMenu
                width: indexRom.width
                height: wholeScreen.height - indexRom.height - 15

                anchors.top: indexRom.bottom
                // anchors.topMargin: 15
                anchors.bottom: parent.bottom
            }
        }

        Rectangle
        {
            id: rightSpace
            width: wholeScreen.width - indexColumn.width
            height: 30
            color: "#FFFFFFFF"
            anchors{
                right: parent.right
            }
        }

        Rectangle//菜单右边主界面
        {
            anchors{
                right: parent.right
                top: rightSpace.bottom
            }
            width: wholeScreen.width - indexColumn.width
            height: parent.height
            color: "#FFFFFFFF"


            Rectangle//非编辑态顶部UI
            {
                id: topRect
                visible: 
                {
                    if(selectionMode)
                    {
                        false
                    }else
                    {
                        true
                    }
                }
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: 78
                color: "#00000000"

                Kirigami.JIconButton//返回箭头
                {
                    id: backImage
                    width: 22 + 10
                    height: 22 + 10
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/assets/back_arrow.png"
                    visible:
                    {
                        if(isMenuPath && !searchState && !currentTab.currentItem.previewerVisible)
                        {
                            false
                        }else
                        {
                            true
                        }
                    }
                    onClicked: 
                    {
                        if(currentTab.currentItem.previewerVisible)
                        {
                            currentTab.currentItem.popPreviewer()
                            if(searchState)//如果是在search的状态下 打开支持的文件 返回则为Search Results
                            {
                                currentTitle = i18n("Search")
                            }else//打开音乐等支持打开的文件以后 返回需要刷新当前的title
                            {
                                currentTitle = getCurrentTitle(currentBrowser.currentPath)
                                // if(musicState)
                                // {
                                //     musicState = false
                                // }
                            }
                            
                        }else if(searchState)//从搜索状态中返回
                        {
                            currentBrowser.refreshCurrentPath()
                            searchState = false
                            currentTitle = getCurrentTitle(currentBrowser.currentPath)
                        }else 
                        {
                            // if(isOpenWithUrl)
                            // {
                            //     isOpenWithUrl = false
                            //     // root.openTab(Maui.FM.homePath())
                            //     // openFolder
                            //     // currentBrowser.goUp()
                            // }else
                            // {
                                currentBrowser.goBack()
                            // }
                        }
                    }
                }

                Text//顶部Title
                {
                    id: contentTitle
                    text:
                    {
                        currentTitle
                    }
                    elide: Text.ElideRight
                    color: '#FF000000'
                    font
                    {
                        pixelSize: 20
                        bold: true
                    }
                    visible: true
                    width: parent.width / 3
                    anchors.left: parent.left
                    anchors.leftMargin: 44
                    anchors.verticalCenter: parent.verticalCenter
                }

                Kirigami.JIconButton {//搜索icon
                    id: searchImage
                    visible:
                    {
                        if(currentTab.currentItem.previewerVisible || searchState)
                        {
                            false
                        }else
                        {
                            true
                        }
                    }
                    width: 22 + 10
                    height: 22 + 10
                    source: 
                    {   
                        "qrc:/assets/search_icon.png"
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 21
                    onClicked: {  
                        searchState = true
                        currentTitle = i18n("Search")
                        searchRect.clear()
                        searchRect.forceActiveFocus()
                    }
                }

                Kirigami.JIconButton {//menu_list
                    id: menuListImage
                    visible:
                    {
                        if(currentTab.currentItem.previewerVisible || searchState)
                        {
                            false
                        }else
                        {
                            true
                        }
                    }
                    width: 22 + 10
                    height: 22 + 10
                    source: 
                    {   
                        if(settings.viewType == 0)
                        {
                            "qrc:/assets/menu_grid.png"
                        }else
                        {
                            "qrc:/assets/menu_list.png"
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: searchImage.left
                    anchors.rightMargin: 35
                    onClicked: {  
                        customPopup.show(wholeScreen.width - (190 + 20), 93)
                    }
                }

                Kirigami.JIconButton {//add_folder
                    id: addFolderImage
                    visible:
                    {
                        if(String(root.currentPath).startsWith("trash:/") || currentTab.currentItem.previewerVisible || searchState
                        || isSpecialPath)
                        {
                            false
                        }else
                        {
                            true
                        }
                    }
                    width: 22 + 10
                    height: 22 + 10
                    source: 
                    {   
                        "qrc:/assets/add_folder.png"
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: menuListImage.left
                    anchors.rightMargin: 35
                    onClicked: {  
                        addFolderImage.forceActiveFocus()
                        newFolderPath = leftMenuData.createDir(currentBrowser.currentPath, "Untitled Folder")
                        isCreateFolfer = true
                    }
                }

                Kirigami.JIconButton {//delete_all
                    id: deleteAllImage
                    visible:
                    {
                        if(String(root.currentPath).startsWith("trash:/") && !searchState)
                        {
                            true
                        }else
                        {
                            false
                        }
                    }
                    width: 22 + 10
                    height: 22 + 10
                    source: 
                    {   
                        "qrc:/assets/select_delete_all.png"
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: menuListImage.left
                    anchors.rightMargin: 35
                    onClicked: {  
                        if(root.currentBrowser.currentFMList.count > 1)
                        {
                            jDialog.text =  i18n("Are you sure you want to delete these files?")
                        }else
                        {
                            jDialog.text = i18n("Are you sure you want to delete the file?")
                        }
                        jDialogType = 2
                        jDialog.open()
                    }
                }

                Kirigami.JSearchField//搜索框
                {
                    id: searchRect

                    visible: searchState
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 28

                    width: 314

                    focus: false
                    placeholderText: ""
                    Accessible.name: i18n("Search")
                    Accessible.searchEdit: true
                    // focusSequence: "Ctrl+F"

                    onRightActionTrigger://点击叉子
                    {
                        searchState = false
                        currentTitle = getCurrentTitle(currentBrowser.currentPath)
                    }

                    onTextChanged:
                    {
                        currentBrowser.currentFMList.search(text, currentBrowser.currentFMList)//在当前目录 包括子目录 搜索文件  
                    }
                }
            }

            Rectangle//编辑态顶部UI 非回收站
            {
                visible: 
                {
                    if(selectionMode && !String(root.currentPath).startsWith("trash:/"))
                    {
                        true
                    }else
                    {
                        false
                    }
                }

                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: 78
                color: "#00000000"

                // Image {//全选
                Kirigami.JIconButton{
                    id: selectAllImage
                    width: 22 + 10
                    height: 22 + 10
                    source: 
                    {
                        "qrc:/assets/unselect_rect.png"
                    }
                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.verticalCenter: parent.verticalCenter
                    // MouseArea {
                        // anchors.fill: parent
                        onClicked: {  
                            // if(_selectionBar.items.length == Math.min(root.currentBrowser.currentFMList.count, 100))//已经是全选状态 则取消所有选中
                            if(_selectionBar.items.length == root.currentBrowser.currentFMList.count)
                            {
                                // _selectionBar.clear()
                                clearSelectionBar()
                            }else
                            {
                                // _selectionBar.clear()
                                clearSelectionBar()
                                selectAll()
                            }
                        }
                }
                    // }

                Text {
                    id: selectCountText
                    anchors.left: selectAllImage.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                    text: "0"
                    color: "#FF000000"
                }

                Connections
                {
                    target: _selectionBar

                    onUriRemoved:
                    {
                        selectCountText.text = _selectionBar.items.length
                        if(_selectionBar.items.length == 0)
                        {
                            selectAllImage.source = "qrc:/assets/unselect_rect.png"
                            copyImage.source = "qrc:/assets/unselect_copy.png" 
                            cutImage.source = "qrc:/assets/unselect_cut.png"
                            deleteImage.source = "qrc:/assets/unselect_delete.png"
                            zipImage.source = "qrc:/assets/unselect_zip.png"
                            unzipImage.source = "qrc:/assets/unselect_unzip.png"
                            favImage.source = "qrc:/assets/unselect_fav.png"
                            tagImage.source = "qrc:/assets/unselect_tag.png"
                        }else//判断解压 收藏 和 标签是否可以被使用
                        {
                            var canUnzip = true
                            var canUnzip = true
                            if(isSpecialPath)
                            {
                                canUnzip = false
                            }
                            var canFav = true
                            // var canTag = true
                            // var theFisrstTagIndex = -2
                            var isHasDir = false
                            var dirFavState = false
                            for(var i = 0; i < _selectionBar.items.length; i++)
                            {
                                var selectItem = _selectionBar.items[i]
                                if(canUnzip)
                                {
                                    // if(!selectItem.mime.includes("x-7z-compressed") && !selectItem.mime.includes("x-tar") && !selectItem.mime.includes("zip"))//如果有不是压缩文件的类型 那么就不允许批量解压
                                    if(!Maui.FM.checkFileType(Maui.FMList.COMPRESSED, selectItem.mime))
                                    {
                                        canUnzip = false
                                    }
                                }
                                
                                if(canFav)
                                {
                                    if(selectItem.isdir != "true" || selectItem.path == leftMenuData.getDownloadsPath())//如果有不是文件夹的 那么就不允许收藏
                                    {
                                        canFav = false
                                    }else
                                    {
                                        var tempFav = leftMenuData.isCollectionFolder(selectItem.path)
                                        if(isHasDir)
                                        {   
                                            if(dirFavState != tempFav)
                                            {
                                                canFav = false
                                            }
                                        }else//第一次遍历到dir进入这个else逻辑 记录下来第一个dir的fav状态 后面每次去判断是否和第一个dir相同
                                        {
                                            dirFavState = tempFav
                                            isHasDir = true
                                        }
                                    }
                                }
                                    
                                // if(canTag)
                                // {
                                //     var tempIndex = leftMenuData.isTagFile(selectItem.path)
                                //     if(theFisrstTagIndex == -2)//记录第一个的标签状态
                                //     {
                                //         theFisrstTagIndex = tempIndex
                                //     }else
                                //     {
                                //         if((theFisrstTagIndex == -1 && tempIndex != -1)
                                //         || (theFisrstTagIndex != -1 && tempIndex == -1))//有标签和没有标签的都有 那么不允许进行批量操作
                                //         {
                                //             canTag = false
                                //         }
                                //     }
                                // }

                                if(!canUnzip && !canFav /*&& !canTag*/)
                                {
                                    break
                                }
                            }

                            if(canUnzip)
                            {
                                unzipImage.source = "qrc:/assets/select_unzip.png"
                            }else
                            {
                                unzipImage.source = "qrc:/assets/unselect_unzip.png"
                            }

                            if(canFav)
                            {
                                if(!dirFavState)//收藏
                                {
                                    favImage.source = "qrc:/assets/select_fav.png"
                                }else if(dirFavState)//取消收藏
                                {
                                    favImage.source = "qrc:/assets/popupmenu/fav_already.png"
                                }
                            }else
                            {
                                favImage.source = "qrc:/assets/unselect_fav.png"
                            }

                            // if(canTag)
                            // {
                            //     tagImage.source = "qrc:/assets/select_tag.png"
                            // }else
                            // {
                            //     tagImage.source = "qrc:/assets/unselect_tag.png"
                            // }
                        }
                    }

                    onUriAdded:
                    {
                        selectCountText.text = _selectionBar.items.length
                        if(_selectionBar.items.length == root.currentBrowser.currentFMList.count)
                        {
                            selectAllImage.source = "qrc:/assets/select_all.png"
                        }
                        else
                        {
                            selectAllImage.source = "qrc:/assets/select_rect.png"
                        }
                        copyImage.source = "qrc:/assets/select_copy.png" 
                        cutImage.source = "qrc:/assets/select_cut.png"
                        deleteImage.source = "qrc:/assets/select_delete.png"
                        tagImage.source = "qrc:/assets/select_tag.png"

                        var canUnzip = true
                        if(isSpecialPath)
                        {
                            zipImage.source = "qrc:/assets/unselect_zip.png"
                            canUnzip = false
                        }else
                        {
                            zipImage.source = "qrc:/assets/select_zip.png"
                        }

                        var canFav = true
                        // var canTag = true
                        // var theFisrstTagIndex = -2
                        var isHasDir = false
                        var dirFavState = false
                        for(var i = 0; i < _selectionBar.items.length; i++)
                        {
                            var selectItem = _selectionBar.items[i]
                            if(canUnzip)
                            {
                                // if(!selectItem.mime.includes("x-7z-compressed") && !selectItem.mime.includes("x-tar") && !selectItem.mime.includes("zip"))//如果有不是压缩文件的类型 那么就不允许批量解压
                                if(!Maui.FM.checkFileType(Maui.FMList.COMPRESSED, selectItem.mime))
                                {
                                    canUnzip = false
                                }
                            }
                            
                            if(canFav)
                            {
                                if(selectItem.isdir != "true" || selectItem.path == leftMenuData.getDownloadsPath())//如果有不是文件夹的 或者 有download文件夹(该文件夹不允许收藏) 那么就不允许收藏
                                {
                                    canFav = false
                                }else
                                {
                                    var tempFav = leftMenuData.isCollectionFolder(selectItem.path)
                                    if(isHasDir)
                                    {   
                                        if(dirFavState != tempFav)
                                        {
                                            canFav = false
                                        }
                                    }else//第一次遍历到dir进入这个else逻辑 记录下来第一个dir的fav状态 后面每次去判断是否和第一个dir相同
                                    {
                                        dirFavState = tempFav
                                        isHasDir = true
                                    }
                                }
                            }
                            
                            // if(canTag)
                            // {
                            //     var tempIndex = leftMenuData.isTagFile(selectItem.path)
                            //     if(theFisrstTagIndex == -2)//记录第一个的标签状态
                            //     {
                            //         theFisrstTagIndex = tempIndex
                            //     }else
                            //     {
                            //         if((theFisrstTagIndex == -1 && tempIndex != -1)
                            //         || (theFisrstTagIndex != -1 && tempIndex == -1))//有标签和没有标签的都有 那么不允许进行批量操作
                            //         {
                            //             canTag = false
                            //         }
                            //     }
                            // }

                            if(!canUnzip && !canFav /*&& !canTag*/)
                            {
                                break
                            }
                        }

                        if(canUnzip)
                        {
                            unzipImage.source = "qrc:/assets/select_unzip.png"
                        }else
                        {
                            unzipImage.source = "qrc:/assets/unselect_unzip.png"
                        }
                        
                        if(canFav)
                        {
                            if(!dirFavState)//收藏
                            {
                                favImage.source = "qrc:/assets/select_fav.png"
                            }else if(dirFavState)//取消收藏
                            {
                                favImage.source = "qrc:/assets/popupmenu/fav_already.png"
                            }
                        }else
                        {
                            favImage.source = "qrc:/assets/unselect_fav.png"
                        }

                        // if(canTag)
                        // {
                        //     tagImage.source = "qrc:/assets/select_tag.png"
                        // }else
                        // {
                        //     tagImage.source = "qrc:/assets/unselect_tag.png"
                        // }
                    }

                    onCleared:
                    {
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

                // Image {//批量复制文件
                Kirigami.JIconButton{
                    id: copyImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_copy.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: selectAllImage.right
                    anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // anchors.leftMargin: (parent.width - 180 - (54 * 5)) / 4
                    onClicked: {  
                        if(source == "qrc:/assets/select_copy.png")
                        {
                            currentBrowser.copy(_selectionBar.uris)
                            showToast(_selectionBar.items.length + i18n(" files have been copied"))
                            clearSelectionBar()
                            selectionMode = false
                        }
                    }
                }

                // Image {//批量剪切文件
                Kirigami.JIconButton{
                    id: cutImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_cut.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: copyImage.right
                    anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // anchors.leftMargin: (parent.width - 180 - (54 * 5)) / 4
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            if(source == "qrc:/assets/select_cut.png")
                            {
                                currentBrowser.cut(_selectionBar.uris)
                                showToast(_selectionBar.items.length + i18n(" files have been cut"))
                                clearSelectionBar()
                                selectionMode = false
                            }
                        }
                    // }
                }

                // Image {//批量删除文件
                Kirigami.JIconButton{
                    id: deleteImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_delete.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: cutImage.right
                    anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // anchors.leftMargin: (parent.width - 180 - (54 * 5)) / 4
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            if(source == "qrc:/assets/select_delete.png")
                            {
                                Maui.FM.moveToTrash(_selectionBar.uris)
                                if(root.isSpecialPath)//特殊目录删除不会自动刷新，我们可以帮他刷，但是刷新的时候可能文件也没有被完全移走到回收站，所以我们从model里面先干掉
                                {
                                    for(var i = 0; i < _selectionBar.items.length; i++)
                                    {
                                        for(var j = 0; j < currentBrowser.currentFMList.count; j++)
                                        {
                                            if(_selectionBar.items[i].path === currentBrowser.currentFMModel.get(j).path)
                                            {
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
                    // }
                }

                // Image {//批量压缩文件
                Kirigami.JIconButton{
                    id: zipImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_zip.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: deleteImage.right
                    // anchors.leftMargin: wholeScreen.width / 17.46
                    anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            if(source == "qrc:/assets/select_zip.png")
                            {
                                _compressedFile.compressWithThread(_selectionBar.uris, currentPath, "New compression", 0)
                                clearSelectionBar()
                                selectionMode = false
                            }
                        }
                    // }
                }

                // Image {//批量解压文件
                Kirigami.JIconButton{
                    id: unzipImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_unzip.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: zipImage.right
                    // anchors.leftMargin: wholeScreen.width / 17.46
                     anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            if(source == "qrc:/assets/select_unzip.png")
                            {
                                // _compressedFile.url = item.path
                                // dialogLoader.sourceComponent= root_extractDialogComponent
                                // dialog.open()
                                for(var i = 0; i < _selectionBar.items.length; i++)
                                {
                                    _compressedFile.url = _selectionBar.items[i].path
                                    _compressedFile.extractWithThread(currentPath, _selectionBar.items[i].label)
                                }
                                clearSelectionBar()
                                selectionMode = false
                            }

                        }
                    // }
                }

                // Image {//批量收藏文件夹
                Kirigami.JIconButton{
                    id: favImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_fav.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: unzipImage.right
                    // anchors.leftMargin: wholeScreen.width / 17.46
                     anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            if(source != "qrc:/assets/unselect_fav.png")
                            {
                                for(var i = 0; i < _selectionBar.items.length; i++)
                                {
                                    var selectItem = _selectionBar.items[i]
                                    leftMenuData.addFolderToCollection(selectItem.path.toString(), false, true)
                                }
                                clearSelectionBar()
                                selectionMode = false
                            }
                        }
                    // }
                }

                // Image {//批量打tag
                Kirigami.JIconButton{
                    id: tagImage
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_tag.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: favImage.right
                    // anchors.leftMargin: wholeScreen.width / 17.46
                     anchors.leftMargin: (parent.width - 75 - (32 * 9)) / 8
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            if(source == "qrc:/assets/select_tag.png")
                            {
                                var isCancelTag = true
                                var tagIndex = -1
                                for(var i = 0; i < _selectionBar.items.length; i++)
                                {
                                    var selectItem = _selectionBar.items[i]
                                    var tempIndex = leftMenuData.isTagFile(selectItem.path)
                                    if(tempIndex == -1)//如果有一个没有tag的文件，那么就认为是要重新打tag
                                    {
                                        root_tagMenu.show(-1)
                                        isCancelTag = false
                                        break
                                    }else
                                    {
                                        if(tagIndex == -1)
                                        {
                                            tagIndex = tempIndex;
                                        }else if(tagIndex != tempIndex)//如果是有tag的，并且tag不一样，也认为是需要重新打tag
                                        {
                                            root_tagMenu.show(-1)
                                            isCancelTag = false
                                            break
                                        }
                                    }
                                    // if(tempIndex == -1)//如果是没有tag的 那么批量打tag
                                    // {
                                    //     root_tagMenu.show(tempIndex)
                                    //     break
                                    // }else//如果是有tag的 那么批量取消tag
                                    // {
                                    //     leftMenuData.addToTag(selectItem.path, tempIndex)
                                    //     isCancelTag = true
                                    // }
                                }
                                selectionMode = false
                                if(isCancelTag)
                                {
                                    for(var i = 0; i < _selectionBar.items.length; i++)
                                    {
                                        var selectItem = _selectionBar.items[i]
                                        var tempIndex = leftMenuData.isTagFile(selectItem.path)
                                        leftMenuData.addToTag(selectItem.path, tempIndex, false)
                                        for(var j = 0; j < root.currentBrowser.currentFMList.count; j++)
                                        {
                                            var listItem = root.currentBrowser.currentFMModel.get(j)
                                            if(listItem.path == selectItem.path)
                                            {
                                                root.currentBrowser.currentFMList.refreshItem(j, selectItem.path)
                                                break
                                            }
                                        }
                                    }
                                    clearSelectionBar()
                                    if(sortSettings.sortBy == Maui.FMList.PLACE)
                                    {
                                        root.currentBrowser.currentFMList.refresh()
                                    }
                                }
                            }
                        }
                    // }
                }

                // Image {//取消编辑态
                Kirigami.JIconButton{
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/cancel_enable.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    // anchors.rightMargin: width + wholeScreen.width / 24
                    anchors.rightMargin: 40
                    // MouseArea {
                    //     anchors.fill: parent
                        onClicked: {  
                            selectionMode = false
                            // _selectionBar.clear()
                            clearSelectionBar()
                        }
                    // }
                }
            }

            Rectangle//编辑态顶部UI 回收站
            {
                visible: 
                {
                    if(selectionMode && String(root.currentPath).startsWith("trash:/"))
                    {
                        true
                    }else
                    {
                        false
                    }
                }

                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width// - wholeScreen.width / 24
                height: 78
                color: "#00000000"

                // Image {//全选
                Kirigami.JIconButton{
                    id: selectAllImage_t
                    width: 22 + 10
                    height: 22 + 10
                    source: 
                    {
                        "qrc:/assets/unselect_rect.png"
                    }
                    anchors.left: parent.left
                    anchors.leftMargin: 36
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
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                    text: "0"
                    color: "#FF000000"
                }

                Connections
                {
                    target: _selectionBar

                    onUriRemoved:
                    {
                        selectCountText_t.text = _selectionBar.items.length
                        if(_selectionBar.items.length == 0)
                        {
                            selectAllImage_t.source = "qrc:/assets/unselect_rect.png"
                            recoverImage_t.source = "qrc:/assets/unselect_recover.png" 
                            deleteImage_t.source = "qrc:/assets/unselect_delete.png"
                        }
                    }

                    onUriAdded:
                    {
                        selectCountText_t.text = _selectionBar.items.length
                        // if(_selectionBar.items.length == Math.min(root.currentBrowser.currentFMList.count, 100))
                        if(_selectionBar.items.length == root.currentBrowser.currentFMList.count)
                        {
                            selectAllImage_t.source = "qrc:/assets/select_all.png"
                        }
                        else
                        {
                            selectAllImage_t.source = "qrc:/assets/select_rect.png"
                        }
                        recoverImage_t.source = "qrc:/assets/select_recover.png"
                        deleteImage_t.source = "qrc:/assets/select_delete.png"
                    }

                    onCleared:
                    {
                        selectCountText_t.text = _selectionBar.items.length
                        selectAllImage_t.source = "qrc:/assets/unselect_rect.png"
                        deleteImage_t.source = "qrc:/assets/unselect_delete.png"
                        recoverImage_t.source = "qrc:/assets/unselect_recover.png"
                    }
                }

                // Image {//批量恢复文件
                Kirigami.JIconButton{
                    id: recoverImage_t
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_recover.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: selectAllImage_t.right
                    anchors.leftMargin: 179
                    onClicked: {  
                        leftMenuData.restoreFromTrash(_selectionBar.uris)
                        clearSelectionBar()
                        selectionMode = false
                    }
                }

                // Image {//批量删除文件
                Kirigami.JIconButton{
                    id: deleteImage_t
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/unselect_delete.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: recoverImage_t.right
                    anchors.leftMargin: 161
                    onClicked: {  
                        if(_selectionBar.items.length > 0)
                        {
                            if(_selectionBar.items.length ==  1)
                            {
                                jDialog.text = i18n("Are you sure you want to delete the file?")
                            }else if(_selectionBar.items.length > 1)
                            {
                                jDialog.text =  i18n("Are you sure you want to delete these files?")
                            }
                            jDialogType = 1
                            jDialog.open()
                        }
                    }
                }

                // Image {//取消编辑态
                Kirigami.JIconButton{
                    width: 22 + 10
                    height: 22 + 10
                    source: "qrc:/assets/cancel_enable.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: width + 40
                    onClicked: {  
                        selectionMode = false
                        clearSelectionBar()
                    }
                }
            }

            ListView//右边的listview界面
            {
                id: _browserList
                anchors.top: parent.top
                anchors.topMargin: 70//140//wholeScreen.height / 21.43
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20//40
                anchors.left: parent.left
                anchors.right: parent.right   
                width: parent.width
                height: parent.height 

                clip: true
                focus: true

                
                model: tabsObjectModel
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds

                MouseArea //左右两边的空白处 弹出空白处menu
                {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    propagateComposedEvents: true
                    onClicked: 
                    {  
                        if (mouse.button == Qt.RightButton) 
                        { 

                            if(mouse.x <= 90 || mouse.x >= _browserList.width - 90)
                            {
                                if(String(root.currentPath).startsWith("trash:/"))
                                {
                                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                    menuX = realMap.x
                                    menuY = realMap.y
                                    currentBrowser.trashNormalMenu.show(_browserList)
                                }else if(!isSpecialPath)
                                {
                                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                    menuX = realMap.x
                                    menuY = realMap.y
                                    currentBrowser.browserMenu.show()
                                } 

                            }else
                            {
                                mouse.accepted = false
                            }
                        }else if(mouse.button == Qt.LeftButton)
                        {
                            if(selectionMode || (mouse.x > 90 && mouse.x < _browserList.width - 90))
                            {
                                mouse.accepted = false
                            }
                        }
                    }

                    onPressAndHold:
                    {
                        if(mouse.x <= 90 || mouse.x >= _browserList.width - 90)
                        {
                            if(String(root.currentPath).startsWith("trash:/"))
                            {
                                var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                menuX = realMap.x
                                menuY = realMap.y
                                currentBrowser.trashNormalMenu.show(_browserList)
                            }else if(!isSpecialPath)
                            {
                                var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                                menuX = realMap.x
                                menuY = realMap.y
                                currentBrowser.browserMenu.show()
                            } 
                        }else
                        {
                            mouse.accepted = false
                        }  
                    }

                    onPressed:
                    {
                        if (mouse.button == Qt.RightButton) 
                        { 
                            if(mouse.x <= 60 || mouse.x >= 1425)
                            {
                            }else
                            {
                                mouse.accepted = false
                            }
                        }else if(mouse.button == Qt.LeftButton)
                        {
                            if(mouse.x > 60 && mouse.x < 1425)
                            {
                                mouse.accepted = false
                            }
                        }
                    }

                    onReleased:
                    {
                        if (mouse.button == Qt.RightButton) 
                        { 
                            if(mouse.x <= 60 || mouse.x >= 1425)
                            {
                            }else
                            {
                                mouse.accepted = false
                            }
                        }else if(mouse.button == Qt.LeftButton)
                        {
                            if(mouse.x > 60 && mouse.x < 1425)
                            {
                                mouse.accepted = false
                            }
                        }
                    }
                }

                // Component.onCompleted: {
                    // userNameBrowser = currentBrowser
                    // testTab = currentTab
                    // currentBrowser.currentFMModel.setSortOrder(sortSettings.sortOrder)
                // }
            }

            Item//空页面UI
            {
                id: nullPage
                visible: isNothingHere
                anchors.top: parent.top
                anchors.topMargin: 140
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right   
                width: parent.width
                height: parent.height 

                Image
                {
                    id: emptyImage
                    anchors.top: parent.top
                    anchors.topMargin: wholeScreen.height / 3.55
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 60
                    height: 60
                    source: "qrc:/assets/empty.png"
                }

                Text {
                    anchors{
                        top: emptyImage.bottom
                        topMargin: 15
                        horizontalCenter: parent.horizontalCenter
                    }
                    horizontalAlignment: Text.AlignHCenter
                    text:
                    {
                        if(searchState)
                        {   
                            i18n("No Results")
                        }else
                        {
                            i18n("There are no files at present.")
                        }
                    } 
                    font.pixelSize: 14
                    color: "#4D3C3C43"
                }
            }
        }

        // ImageViewer
        // {
        //     id: imageViewer
        //     anchors.fill: parent
        //     visible: false
        // }

        Loader{
            id:preiviewLoader
            property int currentIndex: -1
            property var imgModel: null
            property string title: ""
            anchors.fill: parent
            active: false
            sourceComponent: previewCom
        }

        Component{
            id:previewCom

            Kirigami.JImagePreviewItem{//图片插件
                id: previewItem
                usePageStack:false
                startIndex : preiviewLoader.currentIndex
                imagesModel : preiviewLoader.imgModel
                imageDetailTitle : preiviewLoader.title
                onClose:{
                    preiviewLoader.active = false;
                    previewimagemodel.clear()
                }

                onDeleteCurrentPicture:{//删除图片
                    for(var i = 0; i < root.currentBrowser.currentFMList.count; i++)
                    {
                        var normalModel = root.currentBrowser.currentFMModel.get(i)
                        if(Maui.FM.checkFileType(Maui.FMList.IMAGE, normalModel.mime))
                        {
                            if(normalModel.path == path)//将用户删除的图片移入回收站
                            {
                                root.currentBrowser.moveToTrash(normalModel)
                                break
                            }
                        }
                    }
                    //更新插件的model
                    previewimagemodel.remove(index)
                }

                onCropImageFinished:{//剪切图片
                    var imageModel = {"mimeType": mimeType, "mediaType": "0", "previewurl": path, "imageTime": "", "mediaUrl": ""}
                    previewimagemodel.append(imageModel)
                }
            }
        }



        ListModel{//previewItem的model
            id:previewimagemodel
        }

        Loader
        {
            id: dialogLoader
        }

        ObjectModel { id: tabsObjectModel }

        Component.onCompleted:
        {
            root.openTab(Maui.FM.homePath())
        }
    }


    Connections
    {
        target: inx
        function onOpenPath(paths)
        {
            for(var index in paths)
            {
                currentBrowser.openFolder(paths[index])
                break
            }
            isOpenWithUrl = true
        }
    }

    function openTab(path)
    {
        if(path)
        {
            const component = Qt.createComponent("qrc:/widgets/views/BrowserLayout.qml");

            if (component.status === Component.Ready)
            {
                const object = component.createObject(tabsObjectModel, {'path': path});
                tabsObjectModel.append(object)
                _browserList.currentIndex = tabsObjectModel.count - 1
            }
        }
    }

    function getCurrentTitle(path)
    {
        path = path.toString()
        if(path == leftMenuData.getRootPath())//根目录
        {
            return i18n("On My Pad")//"root"
        }else if(path == leftMenuData.getTrashPath())//回收站
        {
            return i18n("Trash")
        }else if(path == "qrc:/widgets/views/tag0")
        {
            return tagsSettings.tag0
        }else if(path == "qrc:/widgets/views/tag1")
        {
            return tagsSettings.tag1
        }else if(path == "qrc:/widgets/views/tag2")
        {
            return tagsSettings.tag2
        }else if(path == "qrc:/widgets/views/tag3")
        {
            return tagsSettings.tag3
        }else if(path == "qrc:/widgets/views/tag4")
        {
            return tagsSettings.tag4
        }else if(path == "qrc:/widgets/views/tag5")
        {
            return tagsSettings.tag5
        }else if(path == "qrc:/widgets/views/tag6")
        {
            return tagsSettings.tag6
        }else if(path == "qrc:/widgets/views/tag7")
        {
            return tagsSettings.tag7
        }else if(path == "qrc:/widgets/views/Recents")
        {
            return i18n("Recents")
        }else if(path == "qrc:/widgets/views/Document")
        {
            return i18n("Document")
        }else if(path == "qrc:/widgets/views/Picture")
        {
            return i18n("Picture")
        }else if(path == "qrc:/widgets/views/Video")
        {
            return i18n("Video")
        }else if(path == "qrc:/widgets/views/Music")
        {
            return i18n("Music")
        }else if(path.startsWith("file:///media/jingos/") && path.lastIndexOf("/") == 20)
        {
            return i18n("USB")
        }
        else
        {
            var index = path.lastIndexOf("/")
            if(index == -1)
            {
                return path
            }else
            {
                return path.substring(index + 1)
            }
        }
    }

    //add by huan lele   modify by hjy
    function openWith(item)//打开方式
    {
        var services = Maui.KDE.services(item.path)
        if(services.length <= 0){
            showToast(i18n("Sorry, opening this file is not supported at present."))
            return;
        }else 
        {
            if(item.mime.indexOf("video") != -1 || Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime) || (item.mime.indexOf("audio") != -1))//文件管理器自己支持的
            {
                if(item.mime.indexOf("audio") != -1)
                {
                    leftMenuData.killMedia()
                }

                _openWithDialog.model.clear()
                _openWithDialog.urls = [item.path]
                for(var i in services)
                {
                    _openWithDialog.model.append(services[i])
                }
                _openWithDialog.open()
            }else//文件管理区不支持的
            {
                if(services.length == 1)
                {
                    Maui.KDE.openWithApp(services[0].actionArgument, [item.path])
                    return;
                }else
                {
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
    //end add

    //编辑态多选 start
    function addToSelection(item, index)
    {
        if(_selectionBar == null || item.path.startsWith("tags://") || item.path.startsWith("applications://"))
        {
            return
        }

        if(_selectionBar.contains(item.nickname))
        {
            _selectionBar.removeAtUri(item.nickname)
            return
        }

        _selectionBar.append(item.nickname, item)
    }

    function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
    {
        if(_selectionBar == null)
        {
            return
        }

        // selectIndexes([...Array(Math.min(root.currentBrowser.currentFMList.count, 100)).keys()])//原始限制100个
        selectIndexes([...Array(root.currentBrowser.currentFMList.count).keys()])
    }

    function selectIndexes(indexes)
    {
        if(_selectionBar == null)
        {
            return
        }
        for(var i in indexes)
            addToSelection(root.currentBrowser.currentFMModel.get(indexes[i]), i)
    }

    //编辑态多选 end

    function getIcon(model){
        var imageSource = ""
        if(model.mime == "inode/directory")
        {
            imageSource = "qrc:/assets/folder_icon.svg"
        }else if(model.mime.indexOf("image/jpeg") != -1)
        {
            imageSource = leftMenuData.getVideoPreview(model.path)
        }else if(model.mime.indexOf("image") != -1)
        {
            imageSource = model.thumbnail
        }else if(model.mime.indexOf("audio") != -1)
        {
            imageSource = "qrc:/assets/music.svg"
        }else if((model.mime.indexOf("text") != -1)
        || (model.mime.indexOf("doc") != -1))
        {
            imageSource = "qrc:/assets/word.svg"
        }else if(model.mime.indexOf("ppt") != -1)
        {
            imageSource = "qrc:/assets/ppt.svg"
        }else if(model.mime.indexOf("video") != -1)
        {
            imageSource = leftMenuData.getVideoPreview(model.path)
        }else if(model.mime.indexOf("xls") != -1)
        {
            imageSource = "qrc:/assets/excel.svg"
        }else if(model.mime.indexOf("7zip") != -1)
        {
            imageSource = "qrc:/assets/7zip.svg"
        }else if(model.mime.indexOf("zip") != -1)
        {
            imageSource = "qrc:/assets/zip.svg"
        }else if(model.mime.indexOf("rar") != -1)
        {
            imageSource = "qrc:/assets/rar.svg"
        }else if(model.mime.indexOf("tar") != -1)
        {
            imageSource = "qrc:/assets/tar.svg"
        }
        else
        {
            imageSource = "qrc:/assets/default.svg"
        }   
        return imageSource
    }

    function getTagSource(model)
    {
        var tagIndex = leftMenuData.isTagFile(model.path)
        var tagSource = ""
        switch(tagIndex)
        {
            case 0: tagSource = "qrc:/assets/leftmenu/tag0.png";
                break;
            case 1: tagSource = "qrc:/assets/leftmenu/tag1.png";
                break;
            case 2: tagSource = "qrc:/assets/leftmenu/tag2.png";
                break;
            case 3: tagSource = "qrc:/assets/leftmenu/tag3.png";
                break;
            case 4: tagSource = "qrc:/assets/leftmenu/tag4.png";
                break;
            case 5: tagSource = "qrc:/assets/leftmenu/tag5.png";
                break;
            case 6: tagSource = "qrc:/assets/leftmenu/tag6.png";
                break;
            case 7: tagSource = "qrc:/assets/leftmenu/tag7.png";
                break;
            default: tagSource = "";
        }
        return tagSource
    }

    function showImageViewer(item)
    {
        var startIndex = 0
        var count = -1
        for(var i = 0; i < root.currentBrowser.currentFMList.count; i++)
        {
            var normalModel = root.currentBrowser.currentFMModel.get(i)
            if(Maui.FM.checkFileType(Maui.FMList.IMAGE, normalModel.mime))//是图片的话，就加入预览的listmodel中
            {
                var imageModel = {"mimeType": normalModel.mime, "mediaType": "0", "previewurl": normalModel.path, "imageTime": "", "mediaUrl": ""}
                previewimagemodel.append(imageModel)
                count++
                if(normalModel.path == item.path)
                {
                    startIndex = count
                }
            }
        }

        preiviewLoader.currentIndex = startIndex;
        preiviewLoader.imgModel = previewimagemodel;
        preiviewLoader.title = "";
        preiviewLoader.active = true;
    }

    function showToast(tips)
    {
        toastText.text = tips
        toast.x = (wholeScreen.width - toast.width) / 2
        toast.y = wholeScreen.height / 4 * 3
        toast.visible = true  
    }

    function clearSelectionBar()
    {
        _selectionBar.clear()
    }
}
