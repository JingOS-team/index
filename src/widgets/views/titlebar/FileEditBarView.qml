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
    id: editRect
    property int iconMarginValue: (width - 75 * appFontSize
                                   - (32 * 9) * appFontSize) / 8

    Kirigami.JIconButton {
        id: selectAllImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
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
        id: selectCountText
        anchors.left: selectAllImage.right
        anchors.leftMargin: 10 * appScaleSize
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14 * appFontSize
        text: "0"
        color: (Kirigami.JTheme.colorScheme
                === "jingosDark") ? '#FFFFFFFF' : '#FF000000'
    }

    Connections {
        target: _selectionBar

        onUriRemoved: {
            selectCountText.text = _selectionBar.items.length
            if (_selectionBar.items.length == 0) {
                selectAllImage.source = "qrc:/assets/unselect_rect.png"
                copyImage.source = "qrc:/assets/unselect_copy.png"
                copyImage.color = Kirigami.JTheme.iconDisableForeground
                cutImage.source = "qrc:/assets/unselect_cut.png"
                cutImage.color = Kirigami.JTheme.iconDisableForeground
                deleteImage.source = "qrc:/assets/unselect_delete.png"
                deleteImage.color = Kirigami.JTheme.iconDisableForeground
                zipImage.source = "qrc:/assets/unselect_zip.png"
                zipImage.color = Kirigami.JTheme.iconDisableForeground
                unzipImage.source = "qrc:/assets/unselect_unzip.png"
                unzipImage.color = Kirigami.JTheme.iconDisableForeground
                favImage.source = "qrc:/assets/unselect_fav.png"
                favImage.color = Kirigami.JTheme.iconDisableForeground
                tagImage.source = "qrc:/assets/unselect_tag.png"
                tagImage.color = Kirigami.JTheme.iconDisableForeground
            } else {
                var canUnzip = true
                var canUnzip = true
                if (isSpecialPath) {
                    canUnzip = false
                }
                var canFav = true
                var canTag = !String(root.currentPath).startsWith(
                            "file:///media")
                var isHasDir = false
                var dirFavState = false
                for (var i = 0; i < _selectionBar.items.length; i++) {
                    var selectItem = _selectionBar.items[i]
                    if (canUnzip) {
                        if (!Maui.FM.checkFileType(
                                    Maui.FMList.COMPRESSED,
                                    selectItem.mime)) {
                            canUnzip = false
                        }
                    }

                    if (canFav) {
                        if (selectItem.isdir != "true"
                                || selectItem.path == leftMenuData.getDownloadsPath(
                                    ) || selectItem.path.startsWith(
                                    "file:///media"))
                        {
                            canFav = false
                        } else {
                            var tempFav = leftMenuData.isCollectionFolder(
                                        selectItem.path)
                            if (isHasDir) {
                                if (dirFavState != tempFav) {
                                    canFav = false
                                }
                            } else
                            {
                                dirFavState = tempFav
                                isHasDir = true
                            }
                        }
                    }

                    if (!canUnzip && !canFav /*&& !canTag*/
                            ) {
                        break
                    }
                }

                if (canUnzip) {
                    unzipImage.source = "qrc:/assets/select_unzip.png"
                    unzipImage.color = Kirigami.JTheme.iconMinorForeground
                } else {
                    unzipImage.source = "qrc:/assets/unselect_unzip.png"
                    unzipImage.color = Kirigami.JTheme.iconDisableForeground
                }

                if (canFav) {
                    if (!dirFavState)
                    {
                        favImage.source = "qrc:/assets/select_fav.png"
                        favImage.color = Kirigami.JTheme.iconMinorForeground
                    } else if (dirFavState)
                    {
                        favImage.source = "qrc:/assets/popupmenu/fav_already.png"
                        favImage.color = Kirigami.JTheme.iconMinorForeground
                    }
                } else {
                    favImage.source = "qrc:/assets/unselect_fav.png"
                    favImage.color = Kirigami.JTheme.iconDisableForeground
                }

                if (canTag) {
                    tagImage.source = "qrc:/assets/select_tag.png"
                    tagImage.color = Kirigami.JTheme.iconMinorForeground
                } else {
                    tagImage.source = "qrc:/assets/unselect_tag.png"
                    tagImage.color = Kirigami.JTheme.iconDisableForeground
                }
                selectAllImage.source = "qrc:/assets/select_rect.png"
            }
        }

        onUriAdded: {
            selectCountText.text = _selectionBar.items.length
            if (_selectionBar.items.length == root.currentBrowser.currentFMList.count) {
                selectAllImage.source = "qrc:/assets/select_all.png"
            } else {
                selectAllImage.source = "qrc:/assets/select_rect.png"
            }
            copyImage.source = "qrc:/assets/select_copy.png"
            copyImage.color = Kirigami.JTheme.iconMinorForeground
            cutImage.source = "qrc:/assets/select_cut.png"
            cutImage.color = Kirigami.JTheme.iconMinorForeground
            deleteImage.source = "qrc:/assets/select_delete.png"
            deleteImage.color = Kirigami.JTheme.iconForeground

            var canUnzip = true
            if (isSpecialPath) {
                zipImage.source = "qrc:/assets/unselect_zip.png"
                zipImage.color = Kirigami.JTheme.iconDisableForeground

                canUnzip = false
            } else {
                zipImage.source = "qrc:/assets/select_zip.png"
                zipImage.color = Kirigami.JTheme.iconMinorForeground
            }

            var canFav = true
            var canTag = !String(root.currentPath).startsWith(
                        "file:///media")
            var isHasDir = false
            var dirFavState = false
            for (var i = 0; i < _selectionBar.items.length; i++) {
                var selectItem = _selectionBar.items[i]
                if (canUnzip) {
                    if (!Maui.FM.checkFileType(
                                Maui.FMList.COMPRESSED,
                                selectItem.mime)) {
                        canUnzip = false
                    }
                }

                if (canFav) {
                    if (selectItem.isdir != "true"
                            || selectItem.path == leftMenuData.getDownloadsPath(
                                ) || selectItem.path.startsWith(
                                "file:///media"))
                    {
                        canFav = false
                    } else {
                        var tempFav = leftMenuData.isCollectionFolder(
                                    selectItem.path)
                        if (isHasDir) {
                            if (dirFavState != tempFav) {
                                canFav = false
                            }
                        } else {
                            dirFavState = tempFav
                            isHasDir = true
                        }
                    }
                }

                if (!canUnzip && !canFav /*&& !canTag*/
                        ) {
                    break
                }
            }

            if (canUnzip) {
                unzipImage.source = "qrc:/assets/select_unzip.png"
                unzipImage.color = Kirigami.JTheme.iconMinorForeground
            } else {
                unzipImage.source = "qrc:/assets/unselect_unzip.png"
                unzipImage.color = Kirigami.JTheme.iconDisableForeground
            }

            if (canFav) {
                if (!dirFavState)
                {
                    favImage.source = "qrc:/assets/select_fav.png"
                    favImage.color = Kirigami.JTheme.iconMinorForeground
                } else if (dirFavState)
                {
                    favImage.source = "qrc:/assets/popupmenu/fav_already.png"
                    favImage.color = Kirigami.JTheme.iconMinorForeground
                }
            } else {
                favImage.source = "qrc:/assets/unselect_fav.png"
                favImage.color = Kirigami.JTheme.iconDisableForeground
            }

            if (canTag) {
                tagImage.source = "qrc:/assets/select_tag.png"
                tagImage.color = Kirigami.JTheme.iconMinorForeground
            } else {
                tagImage.source = "qrc:/assets/unselect_tag.png"
                tagImage.color = Kirigami.JTheme.iconDisableForeground
            }
        }

        onCleared: {
            selectCountText.text = _selectionBar.items.length
            selectAllImage.source = "qrc:/assets/unselect_rect.png"
            copyImage.source = "qrc:/assets/unselect_copy.png"
            copyImage.color = Kirigami.JTheme.iconDisableForeground
            cutImage.source = "qrc:/assets/unselect_cut.png"
            cutImage.color = Kirigami.JTheme.iconDisableForeground
            deleteImage.source = "qrc:/assets/unselect_delete.png"
            deleteImage.color = Kirigami.JTheme.iconDisableForeground
            zipImage.source = "qrc:/assets/unselect_zip.png"
            zipImage.color = Kirigami.JTheme.iconDisableForeground
            unzipImage.source = "qrc:/assets/unselect_unzip.png"
            unzipImage.color = Kirigami.JTheme.iconDisableForeground
            favImage.source = "qrc:/assets/unselect_fav.png"
            favImage.color = Kirigami.JTheme.iconDisableForeground
            tagImage.source = "qrc:/assets/unselect_tag.png"
            tagImage.color = Kirigami.JTheme.iconDisableForeground
        }
    }

    Kirigami.JIconButton {
        id: copyImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_copy.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: selectAllImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            if (source == "qrc:/assets/select_copy.png") {
                currentBrowser.copy(_selectionBar.uris)
                showToast(_selectionBar.items.length + i18n(
                              " files have been copied"))
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    Kirigami.JIconButton {
        id: cutImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_cut.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: copyImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            if (source == "qrc:/assets/select_cut.png") {
                currentBrowser.cut(_selectionBar.uris)
                showToast(_selectionBar.items.length + i18n(
                              " files have been cut"))
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    Kirigami.JIconButton {
        id: deleteImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_delete.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: cutImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            if (source == "qrc:/assets/select_delete.png") {
                if (currentPath == leftMenuData.getHomePath()) {
                    _selectionBar.removeAtUri(leftMenuData.defaultDesktop)
                    _selectionBar.removeAtUri(leftMenuData.defaultDocument)
                    _selectionBar.removeAtUri(leftMenuData.defaultPicture)
                    _selectionBar.removeAtUri(leftMenuData.defaultMusic)
                    _selectionBar.removeAtUri(leftMenuData.defaultVideo)
                    _selectionBar.removeAtUri(leftMenuData.defaultDownloads)
                }
                mainMoveToTrash(_selectionBar.uris)
                if (root.isSpecialPath) {
                    for (var i = 0; i < _selectionBar.items.length; i++) {
                        for (var j = 0; j < currentBrowser.currentFMList.count; j++) {
                            if (_selectionBar.items[i].path
                                    === currentBrowser.currentFMModel.get(
                                        j).path) {
                                root.currentBrowser.currentFMList.remove(
                                            j)
                                break
                            }
                        }
                    }
                }
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    Kirigami.JIconButton {
        id: zipImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_zip.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: deleteImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            if (source == "qrc:/assets/select_zip.png") {
                _compressedFile.compressWithThread(
                            _selectionBar.uris, currentPath,
                            "New compression", 0)
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    Kirigami.JIconButton {
        id: unzipImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_unzip.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: zipImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            if (source == "qrc:/assets/select_unzip.png") {
                for (var i = 0; i < _selectionBar.items.length; i++) {
                    _compressedFile.extractWithThread(
                                currentPath,
                                _selectionBar.items[i].label,
                                _selectionBar.items[i].path)
                }
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    Kirigami.JIconButton {
        id: favImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_fav.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: unzipImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            console.log(" currentPath:::::" + currentPath)
            if (source != "qrc:/assets/unselect_fav.png") {
                for (var i = 0; i < _selectionBar.items.length; i++) {
                    var selectItem = _selectionBar.items[i]
                    leftMenuData.addFolderToCollection(
                                selectItem.path.toString(),
                                false, true)
                }
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    Kirigami.JIconButton {
        id: tagImage
        width: (22 + 10) * appScaleSize
        height: (22 + 10) * appScaleSize
        color: Kirigami.JTheme.iconDisableForeground
        source: "qrc:/assets/unselect_tag.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: favImage.right
        anchors.leftMargin: editRect.iconMarginValue
        onClicked: {
            if (source == "qrc:/assets/select_tag.png") {
                root_tagMenu.show(-1)
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
        anchors.rightMargin: 40 * appScaleSize
        onClicked: {
            selectionMode = false
            clearSelectionBar()
        }
    }
}
