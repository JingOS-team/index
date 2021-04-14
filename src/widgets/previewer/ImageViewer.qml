/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.10 as Controls
import QtGraphicalEffects 1.0 as Effects
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.13 as Kirigami
import org.kde.jinggallery 0.2 as Koko
import org.kde.kquickcontrolsaddons 2.0 as KQA
import org.kde.mauikit 1.2 as Maui
import QtGraphicalEffects 1.12

Rectangle{

    anchors.fill: parent
   
    property alias myheader: myheader

    property int beginX : -1
    property int beginY : -1

    Image {
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.centerIn: parent.centerIn
        source: root.imageUrl
        visible: root.currentBrowser.currentFMModel.get(root.imageIndex).mime !== "image/gif"
        
        MouseArea  {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed:  {
                beginX = mouseX
            }


            onReleased:  {
                var distanceX = mouseX - beginX
                
                if (Math.abs(distanceX) <= 20) {
                    myheader.visible = !myheader.visible
                }else if(distanceX > 20) {
                    showNextPic(false)
                }else if(distanceX < -20) {
                    showNextPic(true)
                }
            }
        }
    }

    AnimatedImage{
        id: gifImage

        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.centerIn: parent.centerIn
        source: root.imageUrl

        visible: root.currentBrowser.currentFMModel.get(root.imageIndex).mime === "image/gif"
        playing: visible
        
        MouseArea  {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed:  {
                console.log("gif")
                beginX = mouseX
            }

            onReleased:   {
                var distanceX = mouseX - beginX
                
                if (Math.abs(distanceX) <= 20) {
                    myheader.visible = !myheader.visible
                }else if(distanceX > 20) {
                    showNextPic(false)
                }else if(distanceX < -20) {
                    showNextPic(true)
                }
            }
        }
    }


    Header {
        id: myheader
        width: parent.width
        height: 120
        visible: true

        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0)
                gradient: Gradient {
                    GradientStop {  position: 0.0;    color: "#a0000000" }
                    GradientStop {  position: 1.0;    color: "#00000000" }
                }
            }
        }
    }

    function showNextPic(isNext) {
        while(true) {
            if(isNext) {
                root.imageIndex = root.imageIndex + 1
                if(root.imageIndex >= root.currentBrowser.currentFMList.count) {
                    root.imageIndex = 0
                }
            }else {
                root.imageIndex = root.imageIndex - 1
                if(root.imageIndex < 0) {
                    root.imageIndex = root.currentBrowser.currentFMList.count - 1
                }
            }
            const item = root.currentBrowser.currentFMModel.get(root.imageIndex)
            if(Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime)) {
                myheader.currentname = item.label
                root.imageUrl = item.path
                leftMenuData.addFileToRecents(item.path.toString());
                if(item.mime === "image/gif") {   
                    gifImage.playing = true
                }
                break
            }
        }
    }
}
