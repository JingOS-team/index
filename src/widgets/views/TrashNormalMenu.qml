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

// Menu
// {
//     id: control
//     implicitWidth: 200

//     /**
//       *
//       */
//     property var item : ({})

//     /**
//       *
//       */
//     property int index : -1

//     /**
//       *
//       */
//     property bool isDir : false

//     /**
//       *
//       */
//     property bool isExec : false

//     /**
//       *
//       */
//     property bool isFav: false

//     /**
//       *
//       */
//     signal removeAllClicked(var item)

//     parent: Overlay.overlay
//     width: 380
//     modal: false
//     focus: true
//     closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
//     background: Rectangle
//     {
//         radius: 18
//         ShaderEffectSource
//         {
//             id: footerBlur

//             width: parent.width
//             height: parent.height

//             visible: false
//             sourceItem: wholeScreen
//             sourceRect: Qt.rect(control.x, control.y, width, height)
//         }

//         FastBlur{
//             id:fastBlur

//             anchors.fill: parent

//             source: footerBlur
//             radius: 72
//             cached: true
//             visible: false
//         }

//         Rectangle{
//             id:maskRect

//             anchors.fill:fastBlur

//             visible: false
//             clip: true
//             radius: 18
//         }
//         OpacityMask{
//             id: mask
//             anchors.fill: maskRect
//             visible: true
//             source: fastBlur
//             maskSource: maskRect
//         }

//         Rectangle{
//             anchors.fill: footerBlur

//             color: "#CCF7F7F7"
//             radius: 18
//         }
//     }

//     MenuItem//全部清空
//     {
//         width: parent.width
//         height: 90
        
//         background: Rectangle
//         {
//             color:
//             {
//                 if(parent.hovered)
//                 {
//                     "#29787880"
//                 }else{
//                     "#00000000"
//                 }
//             }
//             radius: 18
//         }

//         Text {
//             anchors.left: parent.left
//             anchors.leftMargin: 40
//             anchors.verticalCenter: parent.verticalCenter

//             text: "Delete all"
//             font.pointSize: theme.defaultFont.pointSize + 2
//             color: "#FF000000"
//         }

//         Image
//         {
//             anchors.verticalCenter: parent.verticalCenter
//             anchors.right: parent.right
//             anchors.rightMargin: 40

//             width: 32
//             height: 32

//             source: "qrc:/assets/popupmenu/delete_all.png"
//         }

//         MouseArea
//         {
//             anchors.fill: parent
//             onClicked:
//             {
//                 // Maui.FM.emptyTrash()
//                 if(root.currentBrowser.currentFMList.count > 1)
//                 {
//                     jDialog.text =  "Are you sure you want to delete these files?"
//                 }else
//                 {
//                     jDialog.text = "Are you sure you want to delete the file?"
//                 }
//                 jDialogType = 2
//                 jDialog.open()
//                 close()
//             }
//         }
//     }

//     function show(parent = control, x, y)
//     {
//         popup(parent, x, y)
//     }

// }


Kirigami.JPopupMenu 
{
    Action { 
        text: i18n("Delete all")
        icon.source: "qrc:/assets/popupmenu/delete_all.png"
        onTriggered:
        {
            if(root.currentBrowser.currentFMList.count > 1)
            {
                jDialog.text =  i18n("Are you sure you want to delete these files?")
            }else
            {
                jDialog.text = i18n("Are you sure you want to delete the file?")
            }
            jDialogType = 2
            jDialog.open()
            close()
        }
    }

    function show(parent = control, x, y)
    {
        popup(wholeScreen, menuX, menuY)
    }
}
