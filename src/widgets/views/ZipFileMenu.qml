/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.0

Kirigami.JPopupMenu  //一般文件的右键菜单 可以压缩文件
{
    id: control

    /**
      *
      */
    property var item : ({})

    /**
      *
      */
    property int index : -1

    /**
      *
      */
    property bool isDir : false

    /**
      *
      */
    property bool isExec : false

    /**
      *
      */
    property bool isFav: false

    /**
      * 暂时没有用到
      */
    signal bookmarkClicked(var item)

    /**
      *
      */
    signal openModeClicked(var item)

    /**
      *
      */
    signal copyClicked(var item)

    /**
      *
      */
    signal cutClicked(var item)

    /**
      * delete
      */
    signal removeClicked(var item)

    /**
      *
      */
    signal renameClicked(var item)

    /**
      *
      */
    signal infoClicked(var item)

    /**
      *
      */
    signal tagsClicked(var item)

    /**
      *
      */
    signal compressClicked(var item)

    /**
      *
      */
    signal uncompressClicked(var item)

    /**
      *
      */
    signal pasteClicked(var item)


    Action { //批量编辑
        text: i18n("Bulk edit")
        icon.source: "qrc:/assets/popupmenu/bat_edit.png"
        onTriggered:
        {
            root.selectionMode = true
        }
    }
    
    Kirigami.JMenuSeparator 
    { 
//        width: parent.width * 2
//        height: 10 * appScaleSize
//        background:Rectangle{
//            color: "#2E3C3C43"
//        }
    }

    Action { //打开方式
        text: i18n("Open mode")
        icon.source: "qrc:/assets/popupmenu/open_mode.png"
        onTriggered:
        {
            openModeClicked(control.item)
        }
    }

    Kirigami.JMenuSeparator { }

    Action { //复制
        text: i18n("Copy")
        icon.source: "qrc:/assets/popupmenu/copy.png"
        onTriggered:
        {
            copyClicked(control.item)
        }
    }

    Kirigami.JMenuSeparator { }

    Action { //剪切
        text: i18n("Cut")
        icon.source: "qrc:/assets/popupmenu/cut.png"
        onTriggered:
        {
            cutClicked(control.item)
        }
    }
    Kirigami.JMenuSeparator { }
    Action { //删除
        text: i18n("Delete")
        icon.source: "qrc:/assets/popupmenu/delete.png"
        onTriggered:
        {
            removeClicked(control.item)
        }
    }
    Kirigami.JMenuSeparator { }
    Action { 
        text: i18n("Rename")
        icon.source: "qrc:/assets/popupmenu/rename.png"
        onTriggered:
        {
            renameClicked(control.item)
        }
    }
    Kirigami.JMenuSeparator 
    { 
//        width: parent.width * 2
//        height: 10 * appScaleSize
//        background:Rectangle{
//            color: "#2E3C3C43"
//        }
    }
    Action { 
        text: i18n("Info")
        icon.source: "qrc:/assets/popupmenu/info.png"
        onTriggered:
        {
            infoClicked(control.item)
        }
    }
    Kirigami.JMenuSeparator { }
    Action { 
        text: i18n("Tags")
        enabled:!control.item.path.toString().startsWith("file:///media")
        icon.source: "qrc:/assets/popupmenu/tags.png"
        onTriggered:
        {
            tagsClicked(control.item)
        }
    }
    Kirigami.JMenuSeparator {
      visible:{
        var action = itemAt(16)
        if(!action) {
          false
        }else
        {
          true
        }
      }
    }
    Action { 
        id: aboutZip
        text: i18n("Compress")
        icon.source: "qrc:/assets/popupmenu/zip.png"
        onTriggered:
        {
            compressClicked(control.item)
        }
    }

    function show(index)
    {
        control.item = currentFMModel.get(index)

        if(item.path.startsWith("tags://") || item.path.startsWith("applications://"))
        {
            return
        }
            
        if(item)
        {
            control.index = index
            control.isDir = item.isdir == true || item.isdir == "true"
            control.isExec = item.executable == true || item.executable == "true"
            control.isFav = Maui.FM.isFav(item.path)

            if(root.isSpecialPath)//如果是特殊目录 不允许压缩和解压缩
            {
                takeAction(16)
            }else
            {
                var action = itemAt(16)
                if(!action) {
                    insertAction(16, aboutZip)
                }
            }

            popup(wholeScreen, menuX, menuY)
            root.deleteIndex = index
        }
    }

    onVisibleChanged:
    {
      if(!visible)
      {
        root_menuSelectionBar.clear()  
      }
    }
}


