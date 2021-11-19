
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

Kirigami.JPopupMenu {
    Action {
        text: i18n("New folder")
        icon.source: "qrc:/assets/popupmenu/add_folder.png"
        onTriggered: {
            root.newFolderPath = leftMenuData.createDir(
                        currentBrowser.currentPath, i18n("Untitled Folder"))
            root.isCreateFolfer = true
            close()
        }
    }

    Kirigami.JMenuSeparator {}

    Action {
        text: i18n("Info")
        icon.source: "qrc:/assets/popupmenu/info.png"
        onTriggered: {
            root_fileInfo.show(-1)
            close()
        }
    }

    Kirigami.JMenuSeparator {}

    Action {
        text: i18n("Open in terminal")
        icon.source: "qrc:/assets/popupmenu/open_in_terminal.png"
        onTriggered: {
            inx.openTerminal(root.currentPath)
            close()
        }
    }

    Kirigami.JMenuSeparator {
        visible: {
            var action = itemAt(6)
            if (!action) {
                false
            } else {
                true
            }
        }
    }

    Action {
        id: pasteAction
        text: i18n("Paste")
        icon.source: "qrc:/assets/popupmenu/paste.png"
        onTriggered: {
            paste()
            close()
            root.selectionMode = false
            clearSelectionBar()
        }
    }

    function show() {
        const data = Maui.Handy.getClipboard()
        const urls = data.urls
        if (!urls) {
            takeAction(6)
        } else {
            var action = itemAt(6)
            if (!action) {
                insertAction(6, pasteAction)
            }
        }
        popup(wholeScreen, menuX, menuY)
    }
}
