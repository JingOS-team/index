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

Kirigami.JPopupMenu 
{

    id: control
    /**
      *
      */
    property var item : ({})

    property int index : -1

    /**
      *
      */
    signal restoreClicked(var item)

    /**
      *
      */
    signal removeClicked(var item)


    /**
      *
      */
    signal infoClicked(var item)

    Action { //批量编辑
        text: i18n("Bulk edit")
        icon.source: "qrc:/assets/popupmenu/bat_edit.png"
        onTriggered:
        {
            root.selectionMode = true
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: i18n("Recover")
        icon.source: "qrc:/assets/popupmenu/recover.png"
        onTriggered:
        {
            restoreClicked(control.item)
            close()
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: i18n("Delete")
        icon.source: "qrc:/assets/popupmenu/delete.png"
        onTriggered:
        {
            removeClicked(control.item)
            close()
        }
    }


    Kirigami.JMenuSeparator { }

    Action { 
        text: i18n("Info")
        icon.source: "qrc:/assets/popupmenu/info.png"
        onTriggered:
        {
            infoClicked(control.item)
            close()
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
            popup(wholeScreen, menuX, menuY)
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
