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

    Action { 
        text: "Recover"
        icon.source: "qrc:/assets/popupmenu/recover.png"
        onTriggered: {
            restoreClicked(control.item)
            close()
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: "Delete"
        icon.source: "qrc:/assets/popupmenu/delete.png"
        onTriggered: {
            removeClicked(control.item)
            close()
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: "Info"
        icon.source: "qrc:/assets/popupmenu/info.png"
        onTriggered: {
            infoClicked(control.item)
            close()
        }
    }

    function show(index) {
        control.item = currentFMModel.get(index)

        if(item.path.startsWith("tags://") || item.path.startsWith("applications://")) {
            return
        }

        if(item) {
            control.index = index
            popup(wholeScreen, menuX, menuY)
        }
    }

    onVisibleChanged: {
      if(!visible) {
        root_menuSelectionBar.clear()  
      }
    }
}