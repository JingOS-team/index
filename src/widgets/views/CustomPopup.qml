/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

Item {
    id: control
    anchors.fill: parent
    Popup {
        id: popup
        width: 190 * appScaleSize
        height: 40 * 7 * appScaleSize
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Kirigami.JBlurBackground {
            id: blurBk
            anchors.fill: parent
            sourceItem: control.parent
            backgroundColor: Kirigami.JTheme.floatBackground
        }
        MenuItem {
            id: grid_view

            width: parent.width
            height: 40 * appScaleSize

            background: Item {
                clip: true
                Rectangle {
                    width: parent.width
                    height: parent.height + 10 * appScaleSize
                    anchors.top: parent.top
                    radius: 9
                    color: grid_view.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
                }
            }

            Image {
                id: grid_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize
                source: "qrc:/assets/grid_icon.png"
            }

            Text {
                anchors.left: grid_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("Icons")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize

                visible: settings.viewType == 0 ? true : false
                source: "qrc:/assets/view_select.png"
            }

            Kirigami.JMenuSeparator {
                id: separator1
                anchors.bottom: parent.bottom
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentBrowser.settings.viewType = 0
                    settings.viewType = currentBrowser.settings.viewType
                    hide()
                }
            }
        }

        MenuItem {
            id: list_view

            width: parent.width
            height: 40 * appScaleSize

            anchors.top: grid_view.bottom

            background: Rectangle {
                color: parent.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
            }

            Image {
                id: list_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: width + 2 * appScaleSize

                source: "qrc:/assets/list_icon.png"
            }

            Text {
                anchors.left: list_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("List")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground //"#FF000000"
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize

                source: "qrc:/assets/view_select.png"

                visible: settings.viewType == 0 ? false : true
            }
            Kirigami.JMenuSeparator {
                anchors.bottom: parent.bottom
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentBrowser.settings.viewType = 1
                    settings.viewType = currentBrowser.settings.viewType
                    hide()
                }
            }
        }
        MenuItem {
            id: order_by_name

            width: parent.width
            height: 40 * appScaleSize

            anchors.top: list_view.bottom

            background: Rectangle {
                color: parent.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
            }

            Image {
                id: name_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: width + 2 * appScaleSize

                source: "qrc:/assets/order_by_name.png"
            }

            Text {
                anchors.left: name_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("Name")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize

                visible: sortSettings.sortBy == Maui.FMList.LABEL ? true : false
                source: sortSettings.sortOrder == Qt.AscendingOrder ? "qrc:/assets/arrow_up.png" : "qrc:/assets/arrow_down.png"
            }

            Kirigami.JMenuSeparator {
                id: separator3
                anchors.bottom: parent.bottom
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (sortSettings.sortBy != Maui.FMList.LABEL) {
                        sortSettings.sortBy = Maui.FMList.LABEL
                    } else {
                        sortSettings.sortOrder
                                = (sortSettings.sortOrder
                                   === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }

        MenuItem {
            id: order_by_date

            width: parent.width
            height: 40 * appScaleSize
            anchors.top: order_by_name.bottom

            background: Rectangle {
                color: parent.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
            }

            Image {
                id: date_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: width + 2 * appScaleSize

                source: "qrc:/assets/order_by_date.png"
            }

            Text {
                anchors.left: date_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("Date")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize

                visible: sortSettings.sortBy == Maui.FMList.MODIFIED ? true : false
                source: sortSettings.sortOrder == Qt.AscendingOrder ? "qrc:/assets/arrow_up.png" : "qrc:/assets/arrow_down.png"
            }
            Kirigami.JMenuSeparator {
                anchors.bottom: parent.bottom
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (sortSettings.sortBy != Maui.FMList.MODIFIED) {
                        sortSettings.sortBy = Maui.FMList.MODIFIED
                    } else {
                        sortSettings.sortOrder
                                = (sortSettings.sortOrder
                                   === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }
        MenuItem {
            id: order_by_kind

            width: parent.width
            height: 40 * appScaleSize
            anchors.top: order_by_date.bottom

            background: Rectangle {
                color: parent.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
            }

            Image {
                id: kind_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: width + 2 * appScaleSize

                source: "qrc:/assets/order_by_kind.png"
            }

            Text {
                anchors.left: kind_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("Kind")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize

                visible: sortSettings.sortBy == Maui.FMList.MIME ? true : false
                source: sortSettings.sortOrder == Qt.AscendingOrder ? "qrc:/assets/arrow_up.png" : "qrc:/assets/arrow_down.png"
            }
            Kirigami.JMenuSeparator {
                anchors.bottom: parent.bottom
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (sortSettings.sortBy != Maui.FMList.MIME) {
                        sortSettings.sortBy = Maui.FMList.MIME
                    } else {
                        sortSettings.sortOrder
                                = (sortSettings.sortOrder
                                   === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }

        MenuItem {
            id: order_by_size

            width: parent.width
            height: 40 * appScaleSize

            anchors.top: order_by_kind.bottom

            background: Rectangle {
                color: parent.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
            }

            Image {
                id: size_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: width + 2 * appScaleSize
                source: "qrc:/assets/order_by_size.png"
            }

            Text {
                anchors.left: size_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("Size")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground //"#FF000000"
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: 16 * appScaleSize

                visible: sortSettings.sortBy == Maui.FMList.SIZE ? true : false
                source: sortSettings.sortOrder == Qt.AscendingOrder ? "qrc:/assets/arrow_up.png" : "qrc:/assets/arrow_down.png"
            }
            Kirigami.JMenuSeparator {
                anchors.bottom: parent.bottom
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (sortSettings.sortBy != Maui.FMList.SIZE) {
                        sortSettings.sortBy = Maui.FMList.SIZE
                    } else {
                        sortSettings.sortOrder
                                = (sortSettings.sortOrder
                                   === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }
        MenuItem {
            id: order_by_tag

            width: parent.width
            height: 40 * appScaleSize

            anchors.top: order_by_size.bottom

            background: Item {
                clip: true
                Rectangle {
                    width: parent.width
                    height: parent.height + 10 * appScaleSize
                    anchors.bottom: parent.bottom
                    color: order_by_tag.hovered ? Kirigami.JTheme.hoverBackground : Kirigami.JTheme.floatBackground
                    radius: 9
                }
            }

            Image {
                id: tag_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * appScaleSize

                width: 16 * appScaleSize
                height: width + 2 * appScaleSize

                source: "qrc:/assets/order_by_tag.png"
            }

            Text {
                anchors.left: tag_image.right
                anchors.leftMargin: 20 * appScaleSize
                anchors.verticalCenter: parent.verticalCenter

                text: i18n("Tags")
                font.pixelSize: 14 * appFontSize
                color: Kirigami.JTheme.majorForeground //"#FF000000"
            }

            JFileViewIcon {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20 * appScaleSize
                width: 16 * appScaleSize
                height: 16 * appScaleSize
                visible: sortSettings.sortBy == Maui.FMList.PLACE ? true : false
                source: sortSettings.sortOrder == Qt.AscendingOrder ? "qrc:/assets/arrow_up.png" : "qrc:/assets/arrow_down.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    onClicked: {
                        if (sortSettings.sortBy != Maui.FMList.PLACE) {
                            sortSettings.sortBy = Maui.FMList.PLACE
                        } else {
                            sortSettings.sortOrder = (sortSettings.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                            currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                        }
                        hide()
                    }
                }
            }
        }
    }

    function show(x, y) {
        popup.x = x
        popup.y = y
        popup.visible = !popup.visible
    }

    function hide() {
        popup.visible = false
    }
}
