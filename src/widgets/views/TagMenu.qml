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

Popup
{
    property var item : ({})
    property var tagMenuIndex : -1
    property var itemTagIndex: -1
    property var selectUrls : [];

    id: control
    width: 260 * appScaleSize
    height: (313 + 57) * appScaleSize
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Kirigami.JBlurBackground{
        id:blurBk
        anchors.fill: parent
        sourceItem: control.parent
        backgroundColor: Kirigami.JTheme.floatBackground
    }

    Text {
        id: tagsText
        anchors{
            top: parent.top
            topMargin: 32 * appScaleSize
            left: parent.left
            leftMargin: 25 * appScaleSize
        }
        horizontalAlignment: Text.AlignHCenter
        text: i18n("Tags")
        font.pixelSize: 17 * appFontSize
        color: Kirigami.JTheme.majorForeground
    }

    Kirigami.JIconButton
    {
        id: editIcon
        width: 22 * appScaleSize
        height: 22 * appScaleSize
        source: "qrc:/assets/tag_edit.png"

        anchors.right: parent.right
        anchors.rightMargin: 20 * appScaleSize
        anchors.top: parent.top
        anchors.topMargin: 27 * appScaleSize

        onClicked: {
            close()
            root_editTagMenu.show(tagMenuIndex)
        }
    }

    ListView{
        id:tagsListView
        clip: true
        width: 440 * appScaleSize
        height: 240 * appScaleSize
        anchors{
            top: tagsText.bottom
            topMargin: 15 * appScaleSize
            left: parent.left
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
        }
        model: ListModel{
            id:tagsModel
        }
        delegate: tagsDelegate
    }

    Rectangle {
        id: deleteRect
        anchors {
            top: tagsListView.bottom
            topMargin: 10 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }
        width: 220 * appScaleSize
        height: 33 * appScaleSize
        color: Kirigami.JTheme.buttonPopupBackground
        radius: 7 * appScaleSize
        Text {
            id: deleteText
            anchors.centerIn: parent
            color: Kirigami.JTheme.majorForeground
            font.pixelSize: 12 * appFontSize
            text: i18n("Delete Tags")
        }
        Rectangle {
            id: deleteBackgroundColor
            color: "transparent"
            anchors.fill: parent
            radius: parent.radius
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                deleteBackgroundColor.color = Kirigami.JTheme.pressBackground
            }
            onReleased: {
                deleteBackgroundColor.color = Kirigami.JTheme.hoverBackground
            }
            onEntered: {
                deleteBackgroundColor.color = Kirigami.JTheme.hoverBackground
            }
            onExited: {
                deleteBackgroundColor.color = "transparent"
            }
            onCanceled: {
                deleteBackgroundColor.color = "transparent"
            }
            onClicked: {
                close()
                selectUrls = []
                if(control.tagMenuIndex != -1)
                {
                    selectUrls[0] = control.item.path
                    leftMenuData.removeToTags(selectUrls,tagMenuIndex)
                    root.currentBrowser.currentFMList.refreshItem(control.tagMenuIndex, control.item.path)
                    if(sortSettings.sortBy == Maui.FMList.PLACE || String(root.currentPath).startsWith("qrc:/widgets/views/tag")) {
                        root.currentBrowser.currentFMList.refresh()
                    }
                }else
                {
                    for(var i = 0; i < root_selectionBar.items.length; i++)
                    {
                        var selectItem = root_selectionBar.items[i]
                        selectUrls[i] = selectItem.path;
                    }
                    selectionMode = false
                    clearSelectionBar()
                    leftMenuData.removeToTags(selectUrls,tagMenuIndex)
                    root.currentBrowser.currentFMList.refresh()
                }
            }
        }
    }

    Component.onCompleted: {
        tagsModel.append({"tagName": tagsSettings.tag0, "tagIcon": "qrc:/assets/leftmenu/tag0.png"})
        tagsModel.append({"tagName": tagsSettings.tag1, "tagIcon": "qrc:/assets/leftmenu/tag1.png"})
        tagsModel.append({"tagName": tagsSettings.tag2, "tagIcon": "qrc:/assets/leftmenu/tag2.png"})
        tagsModel.append({"tagName": tagsSettings.tag3, "tagIcon": "qrc:/assets/leftmenu/tag3.png"})
        tagsModel.append({"tagName": tagsSettings.tag4, "tagIcon": "qrc:/assets/leftmenu/tag4.png"})
        tagsModel.append({"tagName": tagsSettings.tag5, "tagIcon": "qrc:/assets/leftmenu/tag5.png"})
        tagsModel.append({"tagName": tagsSettings.tag6, "tagIcon": "qrc:/assets/leftmenu/tag6.png"})
        tagsModel.append({"tagName": tagsSettings.tag7, "tagIcon": "qrc:/assets/leftmenu/tag7.png"})
    }

    Component{
        id:tagsDelegate

        Rectangle
        {
            id: tagRect
            width: 220 * appScaleSize
            height: 30 * appScaleSize
            color: "#00000000"

            Image
            {
                id: tagImage
                anchors{
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: 16 * appScaleSize
                height: 16 * appScaleSize
                source: tagIcon
            }

            Text {
                anchors{
                    left: tagImage.right
                    leftMargin: 5 * appScaleSize
                    verticalCenter: parent.verticalCenter
                }
                text: tagName
                font.pixelSize: 11 * appFontSize
                // color: "#99000000"
                color: Kirigami.JTheme.minorForeground
                elide: Text.ElideRight
            }

            Kirigami.Icon {
                id: selectImage
                anchors{
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: 21 * appScaleSize
                height: 21 * appScaleSize
                source: "qrc:/assets/view_select.png"
                color: Kirigami.JTheme.majorForeground
                visible: index == itemTagIndex
            }

            Kirigami.JMenuSeparator 
            { 
                anchors {
                    top: tagRect.bottom
                    left: tagRect.left
                    right: tagRect.right
                }
                visible:
                {
                    true
                }
            }

            MouseArea
            {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked:
                {
                    if (selectImage.visible) {
                        return
                    }
                    selectUrls = []
                    selectionMode = false
                    close()
                    if(control.tagMenuIndex != -1) {
                        leftMenuData.addToTag(control.item.path, index, true)
                        root.currentBrowser.currentFMList.refreshItem(control.tagMenuIndex, control.item.path)
                        if(sortSettings.sortBy == Maui.FMList.PLACE || String(root.currentPath).startsWith("qrc:/widgets/views/tag")) {
                            root.currentBrowser.currentFMList.refresh()
                        }
                    } else {
                        for(var i = 0; i < root_selectionBar.items.length; i++) {
                            var selectItem = root_selectionBar.items[i]
                            selectUrls[i] = selectItem.path;
                        }
                        leftMenuData.addToTags(selectUrls,index)
                        clearSelectionBar()
                        root.currentBrowser.currentFMList.refresh()
                    }
                }
            }

            // Kirigami.JMouseHoverMask
            // {
            //     anchors.fill: parent
            //     acceptedButtons: Qt.LeftButton | Qt.RightButton
            //     radius: 18
            //     onClicked:
            //     {
            //     }
            // }
        }
    }

    function refreshTags()
    {
        tagsModel.clear()
        tagsModel.append({"tagName": tagsSettings.tag0, "tagIcon": "qrc:/assets/leftmenu/tag0.png"})
        tagsModel.append({"tagName": tagsSettings.tag1, "tagIcon": "qrc:/assets/leftmenu/tag1.png"})
        tagsModel.append({"tagName": tagsSettings.tag2, "tagIcon": "qrc:/assets/leftmenu/tag2.png"})
        tagsModel.append({"tagName": tagsSettings.tag3, "tagIcon": "qrc:/assets/leftmenu/tag3.png"})
        tagsModel.append({"tagName": tagsSettings.tag4, "tagIcon": "qrc:/assets/leftmenu/tag4.png"})
        tagsModel.append({"tagName": tagsSettings.tag5, "tagIcon": "qrc:/assets/leftmenu/tag5.png"})
        tagsModel.append({"tagName": tagsSettings.tag6, "tagIcon": "qrc:/assets/leftmenu/tag6.png"})
        tagsModel.append({"tagName": tagsSettings.tag7, "tagIcon": "qrc:/assets/leftmenu/tag7.png"})
    }


    function show(index)
    {
        // item = root.currentBrowser.currentFMModel.get(index)
        // if(item.path.indexOf("file://") >= 0)
        // {
        //     localPath = item.path.replace("file://", "")
        // }else
        // {
        //     localPath = item.path
        // }
        refreshTags()
        control.tagMenuIndex = index
        control.itemTagIndex = index
        if(index != -1)
        {
            item = root.currentBrowser.currentFMModel.get(index)
            itemTagIndex = leftMenuData.isTagFile(item.path)
        }
        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }

    onVisibleChanged:
    {
      if(!visible)
      {
          if(tagMenuIndex == -1)
          {
//              clearSelectionBar()
          }
      }
    }
}
