/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.10 as Controls
import QtGraphicalEffects 1.0 as Effects
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import org.kde.jinggallery 0.2 as Koko
import org.kde.kquickcontrolsaddons 2.0 as KQA
import org.kde.mauikit 1.2 as Maui
import QtGraphicalEffects 1.12

// Maui.Page {
// Kirigami.Page{
Rectangle{

    anchors.fill: parent
   
    property alias myheader: myheader

    property int beginX : -1
    property int beginY : -1

    Image
    // Maui.ImageViewer
    {
        // animated: iteminfo.mime === "image/gif"
        // fillMode: Image.fillMode

        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.centerIn: parent.centerIn
        source: root.imageUrl
        visible: root.currentBrowser.currentFMModel.get(root.imageIndex).mime !== "image/gif"
        
        MouseArea 
        {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: 
            {
                beginX = mouseX
            }

            onReleased: 
            {
                var distanceX = mouseX - beginX
                
                if (Math.abs(distanceX) <= 20)//认为是点击
                {
                    myheader.visible = !myheader.visible
                }else if(distanceX > 20)//右滑
                {
                    showNextPic(false)
                }else if(distanceX < -20)//左滑
                {
                    showNextPic(true)
                }
            }
        }
    }

        // Image
    // Maui.ImageViewer
    AnimatedImage
    {
        // animated: root.currentBrowser.currentFMModel.get(root.imageIndex).mime === "image/gif"
        // fillMode: Image.fillMode
        id: gifImage

        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.centerIn: parent.centerIn
        source: root.imageUrl

        visible: root.currentBrowser.currentFMModel.get(root.imageIndex).mime === "image/gif"
        playing: visible
        
        MouseArea 
        {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: 
            {
                beginX = mouseX
            }


            onReleased: 
            {
                var distanceX = mouseX - beginX
                
                if (Math.abs(distanceX) <= 20)//认为是点击
                {
                    myheader.visible = !myheader.visible
                }else if(distanceX > 20)//右滑
                {
                    showNextPic(false)
                }else if(distanceX < -20)//左滑
                {
                    showNextPic(true)
                }
            }
        }
    }


    Header
    {
        id: myheader
        width: parent.width
        height: 60 * appScaleSize
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

    Kirigami.JIconButton{
        id: leftArrow
        width: (30 + 10) * appScaleSize
        height: width
        source: "qrc:/assets/leftarrow.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        visible:
        {
            if(myheader.visible)
            {
                if(isFirst())
                {
                    false
                }else
                {
                    true
                }
            }else
            {
                false
            }
        }
        onClicked: {  
            showNextPic(false)
        }
    }

    Kirigami.JIconButton{
        id: rightArrow
        width: (30 + 10) * appScaleSize
        height: width
        source: "qrc:/assets/rightarrow.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 0
        visible:
        {
            if(myheader.visible)
            {
                if(isLast())
                {
                    false
                }else
                {
                    true
                }
            }else
            {
                false
            }
        }
        onClicked: {  
            showNextPic(true)
        }
    }

    function showNextPic(isNext)
    {
        var tmpIndex = root.imageIndex
        while(true)
        {
            if(isNext)
            {
                // root.imageIndex = root.imageIndex + 1
                // if(root.imageIndex >= root.currentBrowser.currentFMList.count)
                // {
                //     root.imageIndex = 0
                // }
                if(root.imageIndex == root.currentBrowser.currentFMList.count - 1)
                {
                    root.imageIndex = tmpIndex
                    break
                }else
                {
                    root.imageIndex = root.imageIndex + 1
                }
            }else
            {
                // root.imageIndex = root.imageIndex - 1
                // if(root.imageIndex < 0)
                // {
                //     root.imageIndex = root.currentBrowser.currentFMList.count - 1
                // }
                if(root.imageIndex == 0)
                {
                    root.imageIndex = tmpIndex
                    break
                }else
                {
                    root.imageIndex = root.imageIndex - 1
                }
            }
            const item = root.currentBrowser.currentFMModel.get(root.imageIndex)
            if(Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime))
            {
                myheader.currentname = item.label
                root.imageUrl = item.path
                leftMenuData.addFileToRecents(item.path.toString());
                if(item.mime === "image/gif")
                {   
                    gifImage.playing = true
                }
                break
            }
        }
    }

    function isFirst()
    {
        var isFirst = false
        var tmpIndex = root.imageIndex
        while(true)
        {
            if(tmpIndex == 0)
            {
                isFirst = true
                break
            }else
            {
                tmpIndex = tmpIndex - 1
            }
            const item = root.currentBrowser.currentFMModel.get(tmpIndex)
            if(Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime))
            {
                break
            }
        }
        return isFirst
    }

    function isLast()
    {
        var isLast = false
        var tmpIndex = root.imageIndex
        while(true)
        {
            if(tmpIndex == root.currentBrowser.currentFMList.count - 1)
            {
                isLast = true
                break
            }else
            {
                tmpIndex = tmpIndex + 1
            }
            const item = root.currentBrowser.currentFMModel.get(tmpIndex)
            if(Maui.FM.checkFileType(Maui.FMList.IMAGE, item.mime))
            {
                break
            }
        }
        return isLast
    }
}
