/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.0

Kirigami.JPopupMenu {
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
      * 
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


    Action {
        text: "Bulk edit"
        icon.source: "qrc:/assets/popupmenu/bat_edit.png"
        onTriggered: {
            root.selectionMode = true
        }
    }
    
    Kirigami.JMenuSeparator  { 
        width: parent.width * 2
        height: 20
        background:Rectangle{
            color: "#2E3C3C43"
        }
    }

    Action {
        text: "Open mode"
        icon.source: "qrc:/assets/popupmenu/open_mode.png"
        onTriggered: {
            openModeClicked(control.item)
        }
    }

    Action { 
        text: "Copy"
        icon.source: "qrc:/assets/popupmenu/copy.png"
        onTriggered: {
            copyClicked(control.item)
        }
    }

    Kirigami.JMenuSeparator { }

    Action {
        text: "Cut"
        icon.source: "qrc:/assets/popupmenu/cut.png"
        onTriggered: {
            cutClicked(control.item)
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: "Delete"
        icon.source: "qrc:/assets/popupmenu/delete.png"
        onTriggered: {
            removeClicked(control.item)
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: "Rename"
        icon.source: "qrc:/assets/popupmenu/rename.png"
        onTriggered: {
            renameClicked(control.item)
        }
    }

    Kirigami.JMenuSeparator  { 
        width: parent.width * 2
        height: 20
        background:Rectangle{
            color: "#2E3C3C43"
        }
    }
    
    Action { 
        text: "Info"
        icon.source: "qrc:/assets/popupmenu/info.png"
        onTriggered: {
            infoClicked(control.item)
        }
    }

    function show(index) {
        control.item = currentFMModel.get(index)

        if(item.path.startsWith("tags://") || item.path.startsWith("applications://")) {
            return
        }
            
        if(item) {
            control.index = index
            control.isDir = item.isdir == true || item.isdir == "true"
            control.isExec = item.executable == true || item.executable == "true"
            control.isFav = Maui.FM.isFav(item.path)
            popup(wholeScreen, menuX, menuY)
            root.deleteIndex = index
        }
    }

    onVisibleChanged: {
      if(!visible) {
        root_menuSelectionBar.clear()  
      }
    }
}