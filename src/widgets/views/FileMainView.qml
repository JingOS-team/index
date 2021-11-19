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

import "../../"
Rectangle
{
    id: wholeScreen
    property alias mainRightRect: rightRect
    property alias mainIndexColumn: indexColumn
    property alias mainLeftmenu: leftMenu
    property alias mainCurrentTab: rightRect.rightCurrentTab
    property alias mainMusicPage: rightRect.musicPageview
    property alias mainPageContent: rightRect.currentPageContent
    property alias mainNullPage: rightRect.nullPageView
    property alias mainTabObject: tabsObjectModel
    property alias mainPreviewImage: previewimagemodel
    property alias mainPreviewLoader: preiviewLoader
    anchors.fill: parent
    color: "#00000000"

    Rectangle
    {
        id: indexColumn

        width: wholeScreen.width / 4.27
        height: parent.height
        color: Kirigami.JTheme.settingMajorBackground

        Rectangle {
            id: leftSpace
            width: parent.width
            height: 30 * appScaleSize
            color: "#00000000"
        }

        Rectangle {
            id: indexRom

            anchors.top: leftSpace.bottom
            width: parent.width
            height: 68 * appScaleSize
            color: "#00000000"


            Text {
                id: indexText

                text: i18n("Files")
                elide: Text.ElideRight
                color: Kirigami.JTheme.majorForeground
                font {
                    pixelSize: 25 * appFontSize
                    bold: true
                }

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 25 * appScaleSize

                width: parent.width
            }
        }

        LeftMenu {
            id: leftMenu
            width: indexRom.width
            height: wholeScreen.height - indexRom.height - 15 * appScaleSize

            anchors.top: indexRom.bottom
            anchors.bottom: parent.bottom
        }
    }

    Rectangle {
        id: rightSpace
        width: wholeScreen.width - indexColumn.width
        height: 20 * appScaleSize
        color: Kirigami.JTheme.colorScheme
               === "jingosLight" ? "#ffffffff" : "#ff000000"
        anchors {
            right: parent.right
        }
    }

    FileRightView {
        id: rightRect
        anchors {
            right: parent.right
            top: rightSpace.bottom
            bottom: parent.bottom
        }
        width: wholeScreen.width - indexColumn.width
        height: parent.height
        color: Kirigami.JTheme.colorScheme
               === "jingosLight" ? "#ffffffff" : "#ff000000"
    }

    Loader {
        id: preiviewLoader
        property int currentIndex: -1
        property var imgModel: null
        property string title: ""
        anchors.fill: parent
        active: false
        sourceComponent: previewCom
    }

    Component {
        id: previewCom

        Kirigami.JImagePreviewItem {
            id: previewItem
            usePageStack: false
            startIndex: preiviewLoader.currentIndex
            imagesModel: preiviewLoader.imgModel
            imageDetailTitle: preiviewLoader.title
            onClose: {
                preiviewLoader.active = false
                previewimagemodel.clear()
            }

            onDeleteCurrentPicture: {
                for (var i = 0; i < root.currentBrowser.currentFMList.count; i++) {
                    var normalModel = root.currentBrowser.currentFMModel.get(
                                i)
                    if (Maui.FM.checkFileType(Maui.FMList.IMAGE,
                                              normalModel.mime)) {
                        if (normalModel.path == path)
                        {
                            root.currentBrowser.moveToTrash(normalModel)
                            break
                        }
                    }
                }
                previewimagemodel.remove(index)
            }

            onCropImageFinished: {
                var imageModel = {
                    "mimeType": mimeType,
                    "mediaType": "0",
                    "previewurl": path,
                    "imageTime": "",
                    "mediaUrl": ""
                }
                previewimagemodel.append(imageModel)
            }
        }
    }

    ListModel {
        id: previewimagemodel
    }

    Loader {
        id: dialogLoader
    }

    ObjectModel {
        id: tabsObjectModel
    }

    Component.onCompleted: {
        console.log("  loadtime:: qml load end time:" + (new Date().getTime(
                                                             ) - MainStartTime))

        root.openTab(Maui.FM.homePath())
    }
}
