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
    Action { 
        text: "Delete all"
        icon.source: "qrc:/assets/popupmenu/delete_all.png"
        onTriggered:  {
            if(root.currentBrowser.currentFMList.count > 1) {
                jDialog.text =  "Are you sure you want to delete these files?"
            }else {
                jDialog.text = "Are you sure you want to delete the file?"
            }
            jDialogType = 2
            jDialog.open()
            close()
        }
    }

    function show(parent = control, x, y) {
        popup(wholeScreen, menuX, menuY)
    }
}