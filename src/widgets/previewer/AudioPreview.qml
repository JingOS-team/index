/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.0

Maui.Page
{
    id: control
    anchors.fill: parent
    property alias player: player

    // property var iteminfo : ""

    headBar.visible: false
    footBar.visible: false

    background: Rectangle
    {
        color: "#00000000"
    }

    MediaPlayer
    {
        id: player
        source: currentUrl
        autoLoad: true
        autoPlay: true
    }

    Item
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big

        ColumnLayout
        {
            anchors.centerIn: parent
            width: Math.min(parent.width, 82)
            height: Math.min(82, parent.height)
            spacing: Maui.Style.space.big

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Kirigami.Icon
                {
                    height: parent.height
                    width: parent.width
                    source: iteminfo.icon
                    smooth: true
                }
            }
        }
    }

    Rectangle//底部播放器
    {
        id: playBarFooter

        anchors.bottom: parent.bottom

        width: parent.width
        height: 80

        color: "#00000000"
        visible: true

        Rectangle
        {
            id: shadowRect
            width: parent.width
            height: 80
            color: Kirigami.JTheme.cardBackground
        }

        DropShadow
        {
            anchors.fill: shadowRect
            samples: 16
            color: "#50000000"
            source: shadowRect
        }
        
        Rectangle
        {
            width: parent.width
            height: 80

            color: "#00000000"

            Kirigami.JIconButton//上一首
            {
                id: previousImage

                anchors.left: parent.left
                anchors.leftMargin: 50//35
                anchors.verticalCenter: parent.verticalCenter

                width: 22 + 10
                height: 22 + 10

                source: "qrc:/assets/previousTrack.png"

                onClicked: 
                {
                    playNextMusic(false)
                }
            }

            Kirigami.JIconButton//播放 暂停
            {
                id: playImage

                anchors.left: previousImage.right
                anchors.leftMargin: 33
                anchors.verticalCenter: parent.verticalCenter

                width: 30 + 10
                height: width
                source: player.playbackState === MediaPlayer.PlayingState ? "qrc:/assets/pause.png" : "qrc:/assets/play.png" 
                
                onClicked: 
                {
                    player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                }
            }
            
            Kirigami.JIconButton//下一首
            {
                id: nextTrackImage

                anchors.left: playImage.right
                anchors.leftMargin: 33
                anchors.verticalCenter: parent.verticalCenter

                width: 22 + 10
                height: 22 + 10

                source: "qrc:/assets/nextTrack.png"

                onClicked: 
                {
                    playNextMusic(true)
                }
            }

            Rectangle//播放进度条
            {
                id: currentTime

                anchors.left: nextTrackImage.right
                anchors.leftMargin: 35
                
                width:  wholeScreen.width / 2
                height: 80

                color: "#00000000"
                
                Rectangle//播放进度条
                {
                    id: playBar

                    width: currentTime.width                    
                    height: parent.height

                    visible: true
                    color: "#00000000"
                    
                    Slider
                    {
                        id: progressBar

                        anchors.verticalCenter: parent.verticalCenter

                        width: 300//currentTime.width - _label2.width - wholeScreen.width / 38.4

                        z: parent.z + 1
                        from: 0
                        to: 1000
                        value: (1000 * player.position) / player.duration//player.pos
                        spacing: 0
                        focus: true
                        onMoved: player.seek((progressBar.value / 1000) * player.duration)//player.pos = value
                        enabled: player.playing
                        
                        handle: Rectangle//选中拖动时候的效果
                        {
                            id: handleRect

                            anchors.verticalCenter:parent.verticalCenter

                            width: wholeScreen.width / 41.74
                            height: wholeScreen.height / 30

                            x: progressBar.leftPadding + progressBar.visualPosition
                            * (progressBar.availableWidth - width)
                            y: 0
                            color: 
                            {
                                "#FFFFFFFF"
                            }
                            radius: 4
                        }

                        DropShadow
                        {
                            anchors.fill: handleRect

                            radius: 4
                            samples: 16
                            color: "#50000000"
                            source: handleRect
                        }

                        background: Rectangle
                        {
                            id: rect1

                            anchors.verticalCenter: parent.verticalCenter

                            width: progressBar.availableWidth
                            height: 4

                            color: Kirigami.JTheme.dividerForeground//"#3E3C3C43"
                            // opacity: 0.4
                            radius: 2

                            Rectangle
                            {
                                id: rect2

                                width: progressBar.visualPosition * parent.width
                                height: 4

                                color: Kirigami.JTheme.highlightBlue//"#FF43BDF4"
                                radius: 2
                            }
                        }
                    }

                    Text//播放时间
                    {
                        id: _label2

                        anchors.right: parent.right
                        anchors.rightMargin: 35
                        anchors.verticalCenter: parent.verticalCenter

                        visible: text.length
                        text:  Maui.FM.formatTime(player.position/1000) + "/" +  Maui.FM.formatTime(player.duration/1000) 

                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                        color: Kirigami.JTheme.majorForeground//"#FF8E8E93"
                        font.weight: Font.Normal
                        font.pixelSize: 11
                        opacity: 0.7
                        
                        Component.onCompleted: {
                            _label2.width = contentWidth
                        }
                    }
                }

            }
        }
    }

    function playNextMusic(isNext)
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
            if(item.mime.indexOf("audio") != -1)
            {
                iteminfo = item
                root.currentTitle = item.label
                currentUrl = item.path
                break
            }
        }
    }
}


