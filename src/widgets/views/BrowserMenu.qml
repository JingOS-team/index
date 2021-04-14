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

Kirigami.JPopupMenu  {
    Action { 
        text: "Info"
        icon.source: "qrc:/assets/popupmenu/info.png"
        onTriggered: {
            root_fileInfo.show(-1)
            close()
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: "Paste"
        icon.source: "qrc:/assets/popupmenu/paste.png"
        onTriggered: {
            paste()
            close()
            root.selectionMode = false
            clearSelectionBar()
        }
    }

    function show() {
        popup(wholeScreen, menuX, menuY)
    }

}