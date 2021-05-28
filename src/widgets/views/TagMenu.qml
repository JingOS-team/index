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
    property var index : -1

    id: control
    parent: Overlay.overlay
    width: 260
    height: 313
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle
    {
        radius: 9
        ShaderEffectSource
        {
            id: footerBlur

            width: parent.width
            height: parent.height

            visible: false
            sourceItem: wholeScreen
            sourceRect: Qt.rect(control.x, control.y, width, height)
        }

        FastBlur{
            id:fastBlur

            anchors.fill: parent

            source: footerBlur
            radius: 72
            cached: true
            visible: false
        }

        Rectangle{
            id:maskRect

            anchors.fill:fastBlur

            visible: false
            clip: true
            radius: 9
        }
        OpacityMask{
            id: mask
            anchors.fill: maskRect
            visible: true
            source: fastBlur
            maskSource: maskRect
        }

        Rectangle{
            anchors.fill: footerBlur
            color: "#CCF7F7F7"
            radius: 9
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

    Text {
        id: tagsText
        anchors{
            top: parent.top
            topMargin: 32
            left: parent.left
            leftMargin: 25
        }
        horizontalAlignment: Text.AlignHCenter
        text: i18n("Tags")
        font.pixelSize: 17
        color: "#FF000000"
    }

    Kirigami.JIconButton
    {
        id: editIcon
        width: 22
        height: 22
        source: 
        {
            "qrc:/assets/tag_edit.png"
        }

        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 27

        onClicked: 
        {
            close()
            root_editTagMenu.show(item)
        }
    }

    ListView{
        id:tagsListView
        clip: true
        width: 440
        height: 240
        anchors{
            top: tagsText.bottom
            topMargin: 15
            left: parent.left
            leftMargin: 20
            right: parent.right
            rightMargin: 20
        }
        model: ListModel{
            id:tagsModel
        }
        delegate: tagsDelegate
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
            width: 220
            height: 30
            color: "#00000000"

            Image
            {
                id: tagImage
                anchors{
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: 16
                height: 16
                source: tagIcon
            }

            Text {
                anchors{
                    left: tagImage.right
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                text: tagName
                font.pixelSize: 11
                color: "#99000000"
                elide: Text.ElideRight
            }

            Image
            {
                id: selectImage
                anchors{
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: 16
                height: 16
                source: "qrc:/assets/view_select.png"
                visible:
                {
                    var tagIndex = leftMenuData.isTagFile(item.path)
                    if(index == tagIndex)
                    {
                        true
                    }else
                    {
                        false
                    }
                }
            }

            Kirigami.JMenuSeparator 
            { 
                anchors.top: tagRect.bottom
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
                    if(control.index != -1)
                    {
                        leftMenuData.addToTag(control.item.path, index, false)
                        root.currentBrowser.currentFMList.refreshItem(control.index, control.item.path)
                    }else//批量打tag
                    {
                        for(var i = 0; i < root_selectionBar.items.length; i++)
                        {
                            var selectItem = root_selectionBar.items[i]
                            leftMenuData.addToTag(selectItem.path, index, true)

                            for(var j = 0; j < root.currentBrowser.currentFMList.count; j++)
                            {
                                var item = root.currentBrowser.currentFMModel.get(j)
                                if(item.path == selectItem.path)
                                {
                                    root.currentBrowser.currentFMList.refreshItem(j, selectItem.path)
                                    break
                                }
                            }
                        }
                        clearSelectionBar()
                    }
                    if(sortSettings.sortBy == Maui.FMList.PLACE || String(root.currentPath).startsWith("qrc:/widgets/views/tag"))
                    {
                        root.currentBrowser.currentFMList.refresh()
                    }
                    close()
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
        control.index = index
        if(index != -1)
        {
            item = root.currentBrowser.currentFMModel.get(index)
        }
        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }

    onVisibleChanged:
    {
      if(!visible)
      {
          if(index == -1)
          {
              clearSelectionBar()
          }
      }
    }
}
