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
    property var currentNodeIndex: -1

    id: control
    parent: Overlay.overlay
    width: 350
    height: 162 - 16
    modal: true//false
    focus: true
    closePolicy: Popup.CloseOnEscape //| Popup.CloseOnPressOutside
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

    Kirigami.JIconButton
    {
        id: backIcon
        width: 22
        height: 22
        source: 
        {
            "qrc:/assets/back_arrow.png"
        }

        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 16

        onClicked: 
        {
            close()
            root_tagMenu.show(index)
        }
    }

    Rectangle
    {
        width: 150
        height: 22
        anchors{
            top: parent.top
            topMargin: 16
            left: backIcon.right
            leftMargin: 8
        }
        color: "#00000000"

        Text {
            id: tagsText
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Edit Tags")
            font.pixelSize: 17
            color: "#FF000000"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle
    {
        width: 300
        height: 30
        id: tagTextRect
        anchors{
            left: parent.left
            leftMargin: 25
            right: parent.right
            rightMargin: 25
            top: backIcon.bottom
            topMargin: 16
        }
        color: "#FFFFFFFF"
        radius: 6

        TextField  {
            id: tagText
            anchors{
                left: parent.left
                leftMargin: 9
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle
            {
                width: 0
                height: 0
                color: "#00000000"
            }
            text: "test"
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: 11
            color: "#4D000000"
            maximumLength: 16
            // selectByMouse: true

            onEditingFinished: 
            {
                checkEdit()
            }
        }
    }

    DropShadow {
        anchors.fill: tagTextRect
        horizontalOffset: 0
        verticalOffset: 4
        radius: 6
        samples: 24
        cached: true
        color: Qt.rgba(0, 0, 0, 0.1)
        source: tagTextRect
        visible: true
    }

    ListView{
        id:tagsListView
        clip: true
        width: 30 * 8 + 9 * 7
        height: 30
        orientation: ListView.Horizontal
        spacing: 9
        anchors{
            top: tagTextRect.bottom
            topMargin: 16
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

    // Component.onCompleted: {
    //     tagsModel.append({"tagName": tagsSettings.tag0, "tagIcon": "qrc:/assets/tagedit/tag0.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": true})
    //     tagsModel.append({"tagName": tagsSettings.tag1, "tagIcon": "qrc:/assets/tagedit/tag1.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagsModel.append({"tagName": tagsSettings.tag2, "tagIcon": "qrc:/assets/tagedit/tag2.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagsModel.append({"tagName": tagsSettings.tag3, "tagIcon": "qrc:/assets/tagedit/tag3.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagsModel.append({"tagName": tagsSettings.tag4, "tagIcon": "qrc:/assets/tagedit/tag4.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagsModel.append({"tagName": tagsSettings.tag5, "tagIcon": "qrc:/assets/tagedit/tag5.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagsModel.append({"tagName": tagsSettings.tag6, "tagIcon": "qrc:/assets/tagedit/tag6.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagsModel.append({"tagName": tagsSettings.tag7, "tagIcon": "qrc:/assets/tagedit/tag7.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
    //     tagText.text = tagsSettings.tag0
    //     currentNodeIndex = 0
    // }

    Component{
        id:tagsDelegate
        
        Image
        {
            id: tagImage
            // anchors{
            //     left: parent.left
            //     verticalCenter: parent.verticalCenter
            // }
            width: 30
            height: 30
            source: 
            {
                if(isSelect)
                {
                    selectIcon
                }else
                {
                    tagIcon
                }
            }

            MouseArea
            {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked:
                {
                    if(currentNodeIndex != index)
                    {
                        //如果修改过文字以后进行切换则需要保存下来
                        var node = tagsModel.get(currentNodeIndex)
                        if(node.tagName != tagText.text)
                        {
                            node.tagName = tagText.text
                            checkEdit()
                        }

                        if(tagText.text == "")
                        {
                            return
                        }

                        //进行正常的切换操作
                        for(var i = 0 ; i < tagsModel.count; ++i)
                        {
                            var node = tagsModel.get(i)
                            if(i == index)
                            {
                                node.isSelect = true
                                tagText.text = node.tagName
                                currentNodeIndex = i
                            }else
                            {
                                node.isSelect = false
                            }
                        }
                    }
                }
            }
        }
    }

    function checkEdit()
    {
        if(tagText.text == "")
        {
            showToast(i18n("The tag name cannot empty."))
            return
        }

        var needFreshTagsMenu = false
        switch(currentNodeIndex)
        {
            case 0: 
                if(tagsSettings.tag0 != tagText.text)
                {
                    tagsSettings.tag0 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 1: 
                if(tagsSettings.tag1 != tagText.text)
                {
                    tagsSettings.tag1 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 2: 
                if(tagsSettings.tag2 != tagText.text)
                {
                    tagsSettings.tag2 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 3: 
                if(tagsSettings.tag3 != tagText.text)
                {
                    tagsSettings.tag3 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 4:
                if(tagsSettings.tag4 != tagText.text)
                {
                    tagsSettings.tag4 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 5: 
                if(tagsSettings.tag5 != tagText.text)
                {
                    tagsSettings.tag5 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 6: 
                if(tagsSettings.tag6 != tagText.text)
                {
                    tagsSettings.tag6 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            case 7: 
                if(tagsSettings.tag7 != tagText.text)
                {
                    tagsSettings.tag7 = tagText.text
                    needFreshTagsMenu = true
                }
                break;
            // default: tagSource = "";
        }
        if(needFreshTagsMenu)
        {
            root.leftMenu.refreshTagsMenu()
        }
    }

    function show(index)
    {
        tagsModel.clear()
        tagsModel.append({"tagName": tagsSettings.tag0, "tagIcon": "qrc:/assets/tagedit/tag0.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": true})
        tagsModel.append({"tagName": tagsSettings.tag1, "tagIcon": "qrc:/assets/tagedit/tag1.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        tagsModel.append({"tagName": tagsSettings.tag2, "tagIcon": "qrc:/assets/tagedit/tag2.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        tagsModel.append({"tagName": tagsSettings.tag3, "tagIcon": "qrc:/assets/tagedit/tag3.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        tagsModel.append({"tagName": tagsSettings.tag4, "tagIcon": "qrc:/assets/tagedit/tag4.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        tagsModel.append({"tagName": tagsSettings.tag5, "tagIcon": "qrc:/assets/tagedit/tag5.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        tagsModel.append({"tagName": tagsSettings.tag6, "tagIcon": "qrc:/assets/tagedit/tag6.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        tagsModel.append({"tagName": tagsSettings.tag7, "tagIcon": "qrc:/assets/tagedit/tag7.png", "selectIcon": "qrc:/assets/tagedit/tag0_select.png", "isSelect": false})
        
        tagText.text = tagsSettings.tag0
        currentNodeIndex = 0
        tagText.forceActiveFocus()

        control.index = index
        item = root.currentBrowser.currentFMModel.get(index)
        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }
}
