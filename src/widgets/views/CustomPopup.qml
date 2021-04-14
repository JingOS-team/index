/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui
 
Item {
    anchors.fill: parent
 
    Popup {
        id: popup
        width: 380
        height: 90 * 7 + 20 + separator1.height * 5
        modal: false
        parent: Overlay.overlay
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            id: background
            radius: 18
            ShaderEffectSource {
                id: footerBlur

                width: parent.width
                height: parent.height

                visible: false
                sourceItem: wholeScreen
                sourceRect: Qt.rect(popup.x, popup.y, width, height)
            }

            FastBlur {  
                id:fastBlur

                anchors.fill: parent

                source: footerBlur
                radius: 72
                cached: true
                visible: false
            }

            Rectangle {
                id:maskRect

                anchors.fill:fastBlur

                visible: false
                clip: true
                radius: 18
            }
            OpacityMask {
                id: mask
                anchors.fill: maskRect
                visible: true
                source: fastBlur
                maskSource: maskRect
            }

            Rectangle {
                anchors.fill: footerBlur

                color: "#CCF7F7F7"
                radius: 18
            }

            DropShadow {
                anchors.fill: mask
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12.0
                samples: 24
                cached: true
                color: Qt.rgba(0, 0, 0, 0.1)
                source: mask
                visible: true
            }
        }


        MenuItem {
            id: grid_view

            width: parent.width
            height: 90
            
            background: Rectangle {
                color: "#00000000"
                clip: true
                Rectangle {
                    width: parent.width
                    height: parent.height + 20
                    anchors.top: parent.top
                    color: {
                        if(grid_view.hovered) {
                            "#29787880"
                        }else{
                            "#00000000"
                        }
                    }
                    radius: 18
                }
            }

            Image {
                id: grid_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: 34

                source: "qrc:/assets/grid_icon.png"
            }


            Text {
                anchors.left: grid_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "Icons"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                visible: {
                    if(settings.viewType == 0) {
                        true
                    }else {
                        false
                    }
                }
                source: "qrc:/assets/view_select.png"
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

        Kirigami.JMenuSeparator  { 
            id: separator1
            anchors.top: grid_view.bottom
        }

        MenuItem {
            id: list_view

            width: parent.width
            height: 90

            anchors.top: separator1.bottom
            
            background: Rectangle {
                color: {
                    if(parent.hovered) {
                        "#29787880"
                    }else{
                        "#00000000"
                    }
                }
            }

            Image {
                id: list_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: width + 2

                source: "qrc:/assets/list_icon.png"
            }


            Text {
                anchors.left: list_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "List"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                source: "qrc:/assets/view_select.png"

                visible: {
                    if(settings.viewType == 0) {
                        false
                    }else {
                        true
                    }
                }
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

        Kirigami.JMenuSeparator  { 
            id: separator2
            anchors.top: list_view.bottom
            width: parent.width
            height: 20
            background:Rectangle{
                color: "#2E3C3C43"
            }
        }

        MenuItem {
            id: order_by_name

            width: parent.width
            height: 90

            anchors.top: separator2.bottom
            
            background: Rectangle {
                color: {
                    if(parent.hovered) {
                        "#29787880"
                    }else{
                        "#00000000"
                    }
                }
            }

            Image {
                id: name_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: width + 2

                source: "qrc:/assets/order_by_name.png"
            }


            Text {
                anchors.left: name_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "Name"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image  {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                visible: {
                    if(sortSettings.sortBy == Maui.FMList.LABEL) {
                        true
                    }else {
                        false
                    }
                }
                source:  {
                    if(sortSettings.sortOrder == Qt.AscendingOrder) {
                        "qrc:/assets/arrow_up.png"
                    }else {
                        "qrc:/assets/arrow_down.png"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(sortSettings.sortBy != Maui.FMList.LABEL) {
                        sortSettings.sortBy = Maui.FMList.LABEL
                    }else  {
                        sortSettings.sortOrder = (sortSettings.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }

        Kirigami.JMenuSeparator  { 
            id: separator3
            anchors.top: order_by_name.bottom
        }

        MenuItem  {
            id: order_by_date

            width: parent.width
            height: 90

            anchors.top: separator3.bottom
            
            background: Rectangle {
                color: {
                    if(parent.hovered) {
                        "#29787880"
                    }else{
                        "#00000000"
                    }
                }
            }

            Image  {
                id: date_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: width + 2

                source: "qrc:/assets/order_by_date.png"
            }


            Text {
                anchors.left: date_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "Date"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image  {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                visible: {
                    if(sortSettings.sortBy == Maui.FMList.MODIFIED) {
                        true
                    }else  {
                        false
                    }
                }
                source:   {
                    if(sortSettings.sortOrder == Qt.AscendingOrder) {
                        "qrc:/assets/arrow_up.png"
                    }else {
                        "qrc:/assets/arrow_down.png"
                    }
                }
            }

            MouseArea  {
                anchors.fill: parent
                onClicked: {
                    if(sortSettings.sortBy != Maui.FMList.MODIFIED) {
                        sortSettings.sortBy = Maui.FMList.MODIFIED
                    }else {
                        sortSettings.sortOrder = (sortSettings.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }

        Kirigami.JMenuSeparator  { 
            id: separator4
            anchors.top: order_by_date.bottom
        }

        MenuItem {
            id: order_by_kind

            width: parent.width
            height: 90

            anchors.top: separator4.bottom
            
            background: Rectangle {
                color:{
                    if(parent.hovered) {
                        "#29787880"
                    }else{
                        "#00000000"
                    }
                }
            }

            Image {
                id: kind_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: width + 2

                source: "qrc:/assets/order_by_kind.png"
            }


            Text {
                anchors.left: kind_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "Kind"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                visible: {
                    if(sortSettings.sortBy == Maui.FMList.MIME)  {
                        true
                    }else {
                        false
                    }
                }
                source:  {
                    if(sortSettings.sortOrder == Qt.AscendingOrder)  {
                        "qrc:/assets/arrow_up.png"
                    }else  {
                        "qrc:/assets/arrow_down.png"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(sortSettings.sortBy != Maui.FMList.MIME) {
                        sortSettings.sortBy = Maui.FMList.MIME
                    }else {
                        sortSettings.sortOrder = (sortSettings.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }

        Kirigami.JMenuSeparator  { 
            id: separator5
            anchors.top: order_by_kind.bottom
        }

        MenuItem {
            id: order_by_size

            width: parent.width
            height: 90

            anchors.top: separator5.bottom
            
            background: Rectangle {
                color:  {
                    if(parent.hovered) {
                        "#29787880"
                    }else{
                        "#00000000"
                    }
                }
            }

            Image {
                id: size_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: width + 2

                source: "qrc:/assets/order_by_size.png"
            }


            Text {
                anchors.left: size_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "Size"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                visible: {
                    if(sortSettings.sortBy == Maui.FMList.SIZE) {
                        true
                    }else  {
                        false
                    }
                }
                source:  {
                    if(sortSettings.sortOrder == Qt.AscendingOrder) {
                        "qrc:/assets/arrow_up.png"
                    }else {
                        "qrc:/assets/arrow_down.png"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(sortSettings.sortBy != Maui.FMList.SIZE) {
                        sortSettings.sortBy = Maui.FMList.SIZE
                    }else {
                        sortSettings.sortOrder = (sortSettings.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder)
                        currentBrowser.currentFMList.sortOrder = sortSettings.sortOrder
                    }
                    hide()
                }
            }
        }

        Kirigami.JMenuSeparator  { 
            id: separator6
            anchors.top: order_by_size.bottom
        }

        MenuItem {
            id: order_by_tag

            width: parent.width
            height: 90

            anchors.top: separator6.bottom
            
            background: Rectangle {
                color: "#00000000"
                clip: true
                Rectangle  {
                    width: parent.width
                    height: parent.height + 20
                    anchors.bottom: parent.bottom
                    color:  {
                        if(order_by_tag.hovered) {
                            "#29787880"
                        }else{
                            "#00000000"
                        }
                    }
                    radius: 18
                }
            }

            Image {
                id: tag_image
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 40

                width: 32
                height: width + 2

                source: "qrc:/assets/order_by_tag.png"
            }


            Text {
                anchors.left: tag_image.right
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                text: "Tags"
                font.pointSize: theme.defaultFont.pointSize + 2
                color: "#FF000000"
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 40

                width: 32
                height: 32

                visible: {
                    false
                }
                source: "qrc:/assets/view_select.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    hide()
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