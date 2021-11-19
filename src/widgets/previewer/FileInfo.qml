
/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.2 as Maui
import QtGraphicalEffects 1.0

Popup {
    property var item: ({})
    property var localPath: ""
    property var fileSize: ""

    id: control
    width: 275 * appScaleSize
    height: 366 * appScaleSize
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Kirigami.JBlurBackground {
        id: blurBk
        anchors.fill: parent
        sourceItem: control.parent
        backgroundColor: Kirigami.JTheme.floatBackground
    }

    Kirigami.Icon {
        id: iconImage
        anchors {
            top: parent.top
            topMargin: 35 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }
        width: 70 * appScaleSize
        height: 70 * appScaleSize
        source: getIcon(item)
    }

    Text {
        id: fileNameText
        anchors {
            top: iconImage.bottom
            topMargin: 6 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - 100 * appScaleSize
        text: item.label
        font.pixelSize: 11 * appFontSize
        color: Kirigami.JTheme.majorForeground
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAnywhere
        maximumLineCount: 2
        elide: Text.ElideRight
        clip: true
    }

    Text {
        id: fileSizeText
        anchors {
            top: fileNameText.bottom
            topMargin: 3 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        text: fileSize
        font.pixelSize: 10 * appFontSize
        color: Kirigami.JTheme.minorForeground

        Connections {
            target: leftMenuData
            onRefreshDirSize: {
                fileSize = Maui.FM.formatSizeForQulonglong(size)
                if (fileSize.indexOf("KiB") != -1) {
                    fileSize = fileSize.replace("KiB", "K")
                } else if (fileSize.indexOf("MiB") != -1) {
                    fileSize = fileSize.replace("MiB", "M")
                } else if (fileSize.indexOf("GiB") != -1) {
                    fileSize = fileSize.replace("GiB", "G")
                }
            }
        }
    }

    Text {
        id: infoNameText
        anchors {
            top: fileSizeText.bottom
            topMargin: 28 * appScaleSize
            left: parent.left
            leftMargin: 25 * appScaleSize
        }
        text: i18n("Information")
        font.pixelSize: 17 * appFontSize
        // color: "black"
        color: Kirigami.JTheme.majorForeground
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        clip: true
    }

    Rectangle //文件类型
    {
        id: kindRect
        width: parent.width
        height: 30 * appScaleSize
        anchors {
            top: infoNameText.bottom
            topMargin: 15 * appScaleSize
        }
        color: "#00000000"

        Text {
            anchors {
                left: parent.left
                leftMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Kind")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }

        TextField {
            anchors {
                right: parent.right
                rightMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle {
                color: "#00000000"
            }
            text: item.mime
            horizontalAlignment: Text.AlignRight
            width: parent.width / 5 * 3
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            readOnly: true
            selectByMouse: true
        }
    }

    Kirigami.JMenuSeparator {
        anchors.top: kindRect.bottom
    }

    Rectangle //创建时间
    {
        id: createdRect
        width: parent.width
        height: 30 * appScaleSize
        anchors {
            top: kindRect.bottom
        }
        color: "#00000000"

        Text {
            anchors {
                left: parent.left
                leftMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Created")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.date), "dd.MM.yyyy")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator {
        anchors.top: createdRect.bottom
    }

    Rectangle //最后修改时间
    {
        id: modifiedRect
        width: parent.width
        height: 30 * appScaleSize
        anchors {
            top: createdRect.bottom
        }
        color: "#00000000"

        Text {
            anchors {
                left: parent.left
                leftMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Modified")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.modified), "dd.MM.yyyy")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator {
        anchors.top: modifiedRect.bottom
    }

    Rectangle //最后访问时间
    {
        id: lastopenedRect
        width: parent.width
        height: 30 * appScaleSize
        anchors {
            top: modifiedRect.bottom
        }
        color: "#00000000"

        Text {
            anchors {
                left: parent.left
                leftMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Last opened")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.lastread), "dd.MM.yyyy")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator {
        anchors.top: lastopenedRect.bottom
    }

    Rectangle //所在目录
    {
        id: whereRect
        width: parent.width
        height: 30 * appScaleSize
        anchors {
            top: lastopenedRect.bottom
        }
        color: "#00000000"

        Text {
            id: whereTextId
            anchors {
                left: parent.left
                leftMargin: 25 * appScaleSize
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Where")
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            elide: Text.ElideRight
        }

        TextField {
            anchors {
                right: parent.right
                rightMargin: 25 * appScaleSize
                top: whereTextId.top
                topMargin: -5 * appScaleSize
            }
            background: Rectangle {
                color: "#00000000"
            }
            text: localPath
            horizontalAlignment: Text.AlignRight
            width: parent.width / 5 * 3
            font.pixelSize: 11 * appFontSize
            color: Kirigami.JTheme.minorForeground
            readOnly: true
            selectByMouse: true
        }
    }

    function show(index) {
        if (index == -1) //在页面的空白处右键info 相当于获取上级目录的信息
        {
            item = Maui.FM.getFileInfo(root.currentPath)
        } else {
            item = root.currentBrowser.currentFMModel.get(index)
        }
        if (item.path.indexOf("file://") >= 0) {
            localPath = item.path.replace("file://", "")
        } else {
            localPath = item.path
        }

        if (item.isdir == "true") //文件夹大小获取
        {
            leftMenuData.getDirSize(localPath)
        } else //单个文件获取
        {
            fileSize = Maui.FM.formatSizeForQulonglong(item.size)
            if (fileSize.indexOf("KiB") != -1) {
                fileSize = fileSize.replace("KiB", "K")
            } else if (fileSize.indexOf("MiB") != -1) {
                fileSize = fileSize.replace("MiB", "M")
            } else if (fileSize.indexOf("GiB") != -1) {
                fileSize = fileSize.replace("GiB", "G")
            }
        }
        var lastg = localPath.lastIndexOf("/")
        if (lastg >= 0) {
            localPath = localPath.substring(0, lastg)
        }

        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }

    onClosed: {
        leftMenuData.cancelGetDirSize()
    }
}
