/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import Qt.labs.settings 1.0
import QtQml.Models 2.3

import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.index 1.0 as Index
import jingos.display 1.0

Rectangle
{
    Kirigami.JIconButton {
        id: selectAllImage_t
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: {
            "qrc:/assets/unselect_rect.png"
        }
        anchors.left: parent.left
        anchors.leftMargin: 36 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            if (_selectionBar.items.length == root.currentBrowser.currentFMList.count) {
                clearSelectionBar()
            } else {
                clearSelectionBar()
                selectAll()
            }
        }
    }

    Text {
        id: selectCountText_t
        anchors.left: selectAllImage_t.right
        anchors.leftMargin: 5 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14 * appFontSize
        text: "0"
        color: (Kirigami.JTheme.colorScheme
                === "jingosDark") ? '#FFFFFFFF' : '#FF000000'
    }

    Connections {
        target: _selectionBar

        onUriRemoved: {
            selectCountText_t.text = _selectionBar.items.length
            if (_selectionBar.items.length == 0) {
                selectAllImage_t.source = "qrc:/assets/unselect_rect.png"
                recoverImage_t.source = "qrc:/assets/unselect_recover.png"
                recoverImage_t.color = Kirigami.JTheme.iconDisableForeground
                deleteImage_t.source = "qrc:/assets/unselect_delete.png"
                deleteImage_t.color = Kirigami.JTheme.iconDisableForeground
            } else {
                selectAllImage_t.source = "qrc:/assets/select_rect.png"
            }
        }

        onUriAdded: {
            selectCountText_t.text = _selectionBar.items.length
            if (_selectionBar.items.length == root.currentBrowser.currentFMList.count) {
                selectAllImage_t.source = "qrc:/assets/select_all.png"
            } else {
                selectAllImage_t.source = "qrc:/assets/select_rect.png"
            }
            recoverImage_t.source = "qrc:/assets/select_recover.png"
            recoverImage_t.color = Kirigami.JTheme.iconForeground
            deleteImage_t.source = "qrc:/assets/select_delete.png"
            deleteImage_t.color = Kirigami.JTheme.iconForeground
        }

        onCleared: {
            selectCountText_t.text = _selectionBar.items.length
            selectAllImage_t.source = "qrc:/assets/unselect_rect.png"
            deleteImage_t.source = "qrc:/assets/unselect_delete.png"
            deleteImage_t.color = Kirigami.JTheme.iconDisableForeground
            recoverImage_t.source = "qrc:/assets/unselect_recover.png"
            recoverImage_t.color = Kirigami.JTheme.iconDisableForeground
        }
    }

    Kirigami.JIconButton {
        id: recoverImage_t
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_recover.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: selectAllImage_t.right
        anchors.leftMargin: 179 * appScaleSize
        onClicked: {
            leftMenuData.restoreFromTrash(_selectionBar.uris)
            clearSelectionBar()
            selectionMode = false
            root.currentBrowser.currentFMList.refresh()
        }
    }

    Kirigami.JIconButton {
        id: deleteImage_t
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_delete.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: recoverImage_t.right
        anchors.leftMargin: 161 * appScaleSize
        onClicked: {
            if (_selectionBar.items.length > 0) {
                if (_selectionBar.items.length == 1) {
                    jDialog.text = i18n(
                                "Are you sure you want to delete the file?")
                } else if (_selectionBar.items.length > 1) {
                    jDialog.text = i18n(
                                "Are you sure you want to delete these files?")
                }
                jDialogType = 1
                jDialog.open()
            }
        }
    }

    Kirigami.JIconButton {
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconMinorForeground
        source: "qrc:/assets/cancel_enable.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: width + 40 * appScaleSize
        onClicked: {
            selectionMode = false
            clearSelectionBar()
        }
    }
}
