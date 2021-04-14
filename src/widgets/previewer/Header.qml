/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.12


ToolBar {
    property var currentname

    position: ToolBar.Header
    hoverEnabled: true
    visible: true
    Kirigami.JIconButton {
        id: backImage
        width: 44 + 10
        height: width
        source: "qrc:/assets/image_back.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 21
        onClicked: {
            root.hideImageViewer()
        }
    }

    Text {
        id:name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: backImage.right
        anchors.leftMargin: 21
        text: currentname
        font.pointSize: theme.defaultFont.pointSize + 6
        style: Text.Gilroy
        color: 
        {
            "#FFFFFFFF"
        }

        width: parent.width - backImage.width * 2
        elide: Text.ElideRight
    }
}
