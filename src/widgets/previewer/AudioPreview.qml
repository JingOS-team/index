/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.0

Maui.Page {
    id: control
    anchors.fill: parent
    property alias player: player

    headBar.visible: false
    footBar.visible: false

    background: Rectangle{
        color: "#00000000"
    }

    MediaPlayer {
        id: player
        source: currentUrl
        autoLoad: true
        autoPlay: true
        property string title : player.metaData.title

        onTitleChanged:{
            infoModel.append({key:"Title", value: player.metaData.title})
            infoModel.append({key:"Artist", value: player.metaData.albumArtist})
            infoModel.append({key:"Album", value: player.metaData.albumTitle})
            infoModel.append({key:"Author", value: player.metaData.author})
            infoModel.append({key:"Codec", value: player.metaData.audioCodec})
            infoModel.append({key:"Copyright", value: player.metaData.copyright})
            infoModel.append({key:"Duration", value: player.metaData.duration})
            infoModel.append({key:"Track", value: player.metaData.trackNumber})
            infoModel.append({key:"Year", value: player.metaData.year})
            infoModel.append({key:"Rating", value: player.metaData.userRating})
            infoModel.append({key:"Lyrics", value: player.metaData.lyrics})
            infoModel.append({key:"Genre", value: player.metaData.genre})
            infoModel.append({key:"Artwork", value: player.metaData.coverArtUrlLarge})
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width, 164)
            height: Math.min(164, parent.height)
            spacing: Maui.Style.space.big

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Kirigami.Icon {
                    height: parent.height
                    width: parent.width
                    source: iteminfo.icon
                    smooth: true
                }
            }
        }
    }

    Rectangle {
        id: playBarFooter

        anchors.bottom: parent.bottom

        width: parent.width
        height: 160

        color: "#00000000"
        visible: true

        Rectangle {
            id: shadowRect
            width: parent.width
            height: 160
        }

        DropShadow {
            anchors.fill: shadowRect
            samples: 16
            color: "#50000000"
            source: shadowRect
        }
        
        Rectangle {
            width: parent.width
            height: 160

            color: "#00000000"

            Kirigami.JIconButton {
                id: previousImage

                anchors.left: parent.left
                anchors.leftMargin: 70
                anchors.top: parent.top
                anchors.verticalCenter: parent.verticalCenter

                width: 44 + 10
                height: width

                source: "qrc:/assets/previousTrack.png"

                onClicked: 
                {
                    playNextMusic(false)
                }
            }

            Kirigami.JIconButton {
                id: playImage

                anchors.left: previousImage.right
                anchors.leftMargin: 66
                anchors.verticalCenter: parent.verticalCenter

                width: 60 + 10
                height: width
                source: player.playbackState === MediaPlayer.PlayingState ? "qrc:/assets/pause.png" : "qrc:/assets/play.png" 
                
                onClicked:  {
                    player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                }
            }
            
            Kirigami.JIconButton {
                id: nextTrackImage

                anchors.left: playImage.right
                anchors.leftMargin: 66
                anchors.verticalCenter: parent.verticalCenter

                width: 44 + 10
                height: 44 + 10

                source: "qrc:/assets/nextTrack.png"

                onClicked: 
                {
                    playNextMusic(true)
                }
            }

            Rectangle {
                id: currentTime

                anchors.left: nextTrackImage.right
                anchors.leftMargin: 70
                
                width:  wholeScreen.width / 2
                height: 160

                color: "#00000000"
                
                Rectangle {
                    id: playBar

                    width: currentTime.width                    
                    height: parent.height

                    visible: true
                    color: "#00000000"
                    
                    Slider  {
                        id: progressBar

                        anchors.verticalCenter: parent.verticalCenter

                        width: currentTime.width - _label2.width - wholeScreen.width / 38.4

                        z: parent.z + 1
                        from: 0
                        to: 1000
                        value: (1000 * player.position) / player.duration
                        spacing: 0
                        focus: true
                        onMoved: player.seek((progressBar.value / 1000) * player.duration)
                        enabled: player.playing
                        
                        handle: Rectangle  {
                            id: handleRect

                            anchors.verticalCenter:parent.verticalCenter

                            width: wholeScreen.width / 41.74
                            height: wholeScreen.height / 30

                            x: progressBar.leftPadding + progressBar.visualPosition
                            * (progressBar.availableWidth - width)
                            y: 0
                            color:  {
                                "#FFFFFFFF"
                            }
                            radius: 8
                        }

                        DropShadow {
                            anchors.fill: handleRect

                            radius: 8
                            samples: 16
                            color: "#50000000"
                            source: handleRect
                        }

                        background: Rectangle {
                            id: rect1

                            anchors.verticalCenter: parent.verticalCenter

                            width: progressBar.availableWidth
                            height: 8

                            color: "#3E3C3C43"
                            opacity: 0.4
                            radius: 2

                            Rectangle {
                                id: rect2

                                width: progressBar.visualPosition * parent.width
                                height: 8

                                color: "#FF43BDF4"
                                radius: 2
                            }
                        }
                    }

                    Text  {
                        id: _label2

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        visible: text.length
                        text:  Maui.FM.formatTime(player.position/1000) + "/" +  Maui.FM.formatTime(player.duration/1000) 

                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                        color: "#FF8E8E93"
                        font.weight: Font.Normal
                        font.pointSize: theme.defaultFont.pointSize - 3
                        opacity: 0.7
                        
                        Component.onCompleted: {
                            _label2.width = contentWidth
                        }
                    }
                }
            }
        }
    }

    function playNextMusic(isNext){
        var tmpIndex = root.imageIndex
        while(true){
            if(isNext)  {
                if(root.imageIndex == root.currentBrowser.currentFMList.count - 1) {
                    root.imageIndex = tmpIndex
                    break
                }else {
                    root.imageIndex = root.imageIndex + 1
                }
            }else {
                if(root.imageIndex == 0) {
                    root.imageIndex = tmpIndex
                    break
                }else {
                    root.imageIndex = root.imageIndex - 1
                }
            }
            const item = root.currentBrowser.currentFMModel.get(root.imageIndex)
            if(item.mime.indexOf("audio") != -1) {
                iteminfo = item
                root.currentTitle = item.label
                currentUrl = item.path
                break
            }
        }
    }
}


