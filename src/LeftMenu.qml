import QtQuick 2.11
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

Rectangle//左侧菜单区域
{
    id:leftMenu

    color: "#00000000"

    ListView{
        id:menuListView
        clip: true
        anchors.fill: parent
        model: ListModel{
            id:leftMenuModel
        }
        delegate: leftMenuDelegate

        Connections
        {
            target: leftMenuData
            onAddCollection: 
            {
                refreshCollectionMenu()
            }

            onRemoveCollection: 
            {
                var node = leftMenuModel.get(2).subNode
                for(var j = 0; j < node.count; ++j)
                {
                    if(node.get(j).path == folderPath)
                    {
                        node.remove(j)
                        break
                    }
                }
            }
        }
    }

    Connections
    {
        target: leftMenuData
        onDeviceAdded: 
        {
            refreshUSBMenu(deviceList)
        }

        onDeviceRemoved:
        {
            refreshUSBMenu(deviceList)

            if(currentPath.toString().startsWith("file:///media/jingos/"))//如果用户在挂载目录下 需要退出当前目录  a--多个u盘情况下如果不是拔出的目录，也会退出 b--如果用户自己浏览挂载目录也会退出
            {
                for(var i = 0 ; i < leftMenuModel.count; ++i)
                {
                    var node = leftMenuModel.get(i).subNode
                    for(var j = 0; j < node.count; ++j)
                    {
                        if(node.get(j).subItemChecked)
                        {
                            node.get(j).subItemChecked = false
                        }
                    }
                }

                var userNameNode = leftMenuModel.get(1).subNode.get(1)
                userNameNode.subItemChecked = true
                currentTitle = userNameNode.subName
                clearSelectionBar()
                root.selectionMode = false
                currentBrowser.openFolder(userNameNode.path)
                root.searchState = false
                root.isSpecialPath = false
            }
        }
    }

    // MenuData(const QString &menuName, bool isOpen)
	// SubNode(const QString &subName, const QString &selectIcon, const QString &unselectIcon, bool itemChecked, const QString &path, const QString &tag)
    Component.onCompleted: {
        //Type 文件类型分类  当硬盘足够大 文件足够多的时候 这个效率是否会有问题？
        leftMenuModel.append({"menuName": i18n("Type"), "openState": true, "subNode":[]})
        // addSubNode(0, "Document", "assets/leftmenu/documentSelect.png", "assets/leftmenu/documentUnselect.png", false, leftMenuData.getHomePath(), "null")//文档类
        addSubNode(0, i18n("Document"), "assets/leftmenu/documentSelect.png", "assets/leftmenu/documentUnselect.png", false, "qrc:/widgets/views/Document", "null")//文档类
        addSubNode(0, i18n("Picture"), "assets/leftmenu/picSelect.png", "assets/leftmenu/picUnselect.png", false, "qrc:/widgets/views/Picture", "null")//图片类
        addSubNode(0, i18n("Video"), "assets/leftmenu/videoSelect.png", "assets/leftmenu/videoUnselect.png", false, "qrc:/widgets/views/Video", "null")//音视频类
        addSubNode(0, i18n("Music"), "assets/leftmenu/musicSelect.png", "assets/leftmenu/musicUnselect.png", false, "qrc:/widgets/views/Music", "null")//其他类 都是文件 文件夹不在这里展示                        

        //Location
        leftMenuModel.append({"menuName": i18n("Location"), "openState": true, "subNode":[]})
        addSubNode(1, i18n("Recents"), "assets/leftmenu/recentsSelect.png", "assets/leftmenu/recentsUnselect.png", false, "qrc:/widgets/views/Recents", "null")//最近浏览 1个月期限
        addSubNode(1, leftMenuData.getUserName(), "assets/leftmenu/jingosSelect.png", "assets/leftmenu/jingosUnselect.png", true, leftMenuData.getHomePath(), "null")//用户名
        addSubNode(1, i18n("Downloads"), "assets/leftmenu/downloadSelect.png", "assets/leftmenu/downloadUnselect.png", false, leftMenuData.getDownloadsPath(), "null")//系统级目录--下载 此文件夹可能会被删除 删除就不再展示了 用户再创建-再展示
        addSubNode(1, i18n("On My Pad"), "assets/leftmenu/onMyPadSelect.png", "assets/leftmenu/onMyPadUnselect.png", false, leftMenuData.getRootPath(), "null")//根目录
        addSubNode(1, i18n("Trash"), "assets/leftmenu/trashSelect.png", "assets/leftmenu/trashUnselect.png", false, leftMenuData.getTrashPath(), "null")//回收站

        var deviceList = leftMenuData.getUSBDevice();//如果有usb设备，则展示
        for(var i in deviceList)
        {
            addSubNode(1, "USB", "assets/leftmenu/usbSelect.png", "assets/leftmenu/usbUnselect.png", false, deviceList[i], "null")//外接存储设备
        }

        //Collection 快速浏览 只对文件夹有效 一开始是没有的 要不要展示 后面再决定 
        leftMenuModel.append({"menuName": i18n("Favorite"), "openState": true, "subNode":[]})
        var collectionList = leftMenuData.getCollectionList();
        for(var i in collectionList)
        {
            addSubNode(2, collectionList[i].label, "assets/leftmenu/folderSelect.png", "assets/leftmenu/folderUnselect.png", false, collectionList[i].path, "null")
        }

        //Tags 标签 固定只有八个 颜色无法修改 名称默认有 用户可以修改 一个文件只允许有一个tag
        leftMenuModel.append({"menuName": i18n("Tags"), "openState": true, "subNode":[]})
        addSubNode(3, tagsSettings.tag0, "assets/leftmenu/tag0Select.png", "assets/leftmenu/tag0.png", false, "qrc:/widgets/views/tag0", "null")
        addSubNode(3, tagsSettings.tag1, "assets/leftmenu/tag1Select.png", "assets/leftmenu/tag1.png", false, "qrc:/widgets/views/tag1", "null")
        addSubNode(3, tagsSettings.tag2, "assets/leftmenu/tag2Select.png", "assets/leftmenu/tag2.png", false, "qrc:/widgets/views/tag2", "null")
        addSubNode(3, tagsSettings.tag3, "assets/leftmenu/tag3Select.png", "assets/leftmenu/tag3.png", false, "qrc:/widgets/views/tag3", "null")
        addSubNode(3, tagsSettings.tag4, "assets/leftmenu/tag4Select.png", "assets/leftmenu/tag4.png", false, "qrc:/widgets/views/tag4", "null")
        addSubNode(3, tagsSettings.tag5, "assets/leftmenu/tag5Select.png", "assets/leftmenu/tag5.png", false, "qrc:/widgets/views/tag5", "null")
        addSubNode(3, tagsSettings.tag6, "assets/leftmenu/tag6Select.png", "assets/leftmenu/tag6.png", false, "qrc:/widgets/views/tag6", "null")
        addSubNode(3, tagsSettings.tag7, "assets/leftmenu/tag7Select.png", "assets/leftmenu/tag7.png", false, "qrc:/widgets/views/tag7", "null")

        currentTitle = leftMenuData.getUserName()
        isMenuPath = true
        currentLeftMenuIndex = 1
        currentLeftMenuNodeIndex = 1
        // Maui.TagsList.getTags();
    }

    Component{
        id:leftMenuDelegate

        Column{
            id:objColumn

            Component.onCompleted: {
                for(var i = 1; i < objColumn.children.length - 1; ++i) {
                    objColumn.children[i].visible = true
                }
            }

            // MouseArea{
            Rectangle{
                visible:
                {
                    if(subNode.count > 0)
                    {
                        true
                    }else
                    {
                        false
                    }
                }
                width:typeRect.width
                height: typeRect.height
                color: "#00000000"
                Rectangle
                {
                    id: typeRect

                    color: "#00000000"

                    width: menuListView.width
                    height: 45

                    Text
                    {
                        id: typeText

                        text: menuName
                        elide: Text.ElideRight
                        color: '#4D000000'
                        font
                        {
                            pixelSize: 12
                        }

                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.bottom: typeRect.bottom
                        anchors.bottomMargin: 5

                        width: parent.width
                    }

                    Kirigami.JIconButton
                    {
                        id: typeIcon
                        width: 22 + 10
                        height: 22 + 10
                        source: 
                        {
                            if(openState)
                            {
                                "qrc:/assets/leftmenu/downArrow.png"//展开状态
                            }else
                            {
                                "qrc:/assets/leftmenu/upArrow.png"//收缩状态
                            }
                        }

                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.bottom: typeRect.bottom

                        onClicked: 
                        {
                            openState = !openState
                            var flag = false;
                            for(var i = 1; i < objColumn.children.length - 1; ++i) {
                                flag = objColumn.children[i].visible;
                                objColumn.children[i].visible = !objColumn.children[i].visible
                            }
                        }
                    }
                }
            }

            Repeater {//子选项 Document类
                model: subNode

                delegate: Rectangle
                {
                    id: subDelegateRow

                    color: model.subItemChecked ? "#FF3C4BE8" : "#00000000"  
                    radius: 10
                    
                    anchors.left: parent.left
                    anchors.leftMargin: wholeScreen.width / 76.8

                    width: parent.width - parent.width / 9.6
                    height: 39

                    MouseArea 
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: 
                        {  
                            if(!model.subItemChecked)
                            {
                                for(var i = 0 ; i < leftMenuModel.count; ++i)
                                {
                                    var node = leftMenuModel.get(i).subNode
                                    for(var j = 0; j < node.count; ++j)
                                    {
                                        if(node.get(j).subItemChecked)
                                        {
                                            node.get(j).subItemChecked = false
                                        }
                                    }
                                }
                                model.subItemChecked = true
                                currentTitle = model.subName
                                clearSelectionBar()
                                root.selectionMode = false
                                root.isOpenWithUrl = false
                                currentBrowser.openFolder(model.path)
                                root.searchState = false
                                if(model.path == "qrc:/widgets/views/Document"
                                || model.path == "qrc:/widgets/views/Picture"
                                || model.path == "qrc:/widgets/views/Video"
                                || model.path == "qrc:/widgets/views/Music"
                                || model.path == "qrc:/widgets/views/Recents"
                                || model.path.indexOf("qrc:/widgets/views/tag") != -1)
                                {
                                    root.isSpecialPath = true
                                }else
                                {
                                    root.isSpecialPath = false
                                }
                            }
                        }

                        onEntered: //进入鼠标区域触发，悬浮属性为false，需点击才触发
                        {
                            if(!model.subItemChecked)
                            {
                                subDelegateRow.color = "#29787880"
                            }
                        } 
                        onExited: //退出鼠标区域(hoverEnabled得为true)，或者点击退出的时触发
                        {
                            if(!model.subItemChecked)
                            {
                                subDelegateRow.color = "#00000000"
                            }
                        }   
                        onCanceled://触摸屏的时候需要调用这个 才能够把hover取消
                        {
                            if(!model.subItemChecked)
                            {
                                subDelegateRow.color = "#00000000"
                            }
                        }
                    }

                    Image
                    {   
                        id: subDelegateIcon    

                        source: model.subItemChecked ? model.subIconSelect : model.subIconUnselect
                        fillMode: Image.PreserveAspectFit

                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.verticalCenter: parent.verticalCenter

                        width: 16
                        height: 16
                    }

                    Text
                    {
                        text: model.subName
                        elide: Text.ElideRight
                        color: model.subItemChecked ? '#FFFFFFFF' : '#FF000000'
                        font
                        {
                            pixelSize: 14
                        }

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: subDelegateIcon.right
                        anchors.leftMargin: 10

                        width: subDelegateRow.width - 32 - 25 - 20 - wholeScreen.width / 76.8
                    }

                states: 
                [
                    State 
                    {
                        name: "selected"
                        when: model.subItemChecked == true
                        PropertyChanges { target: subDelegateRow; color: "#FF3C4BE8"}
                    },

                    State 
                    {
                        name: "unselected"
                        when: model.subItemChecked == false
                        PropertyChanges { target: subDelegateRow; color: "#00000000"}
                    }
                ]
                }
            }
        }
    }

    function addSubNode(menuIndex, subName, subIconSelect, subIconUnselect, subItemChecked, path, tag)
    {
        leftMenuModel.get(menuIndex).subNode.append({"subName": subName, "subIconSelect": subIconSelect, "subIconUnselect": subIconUnselect, "subItemChecked": subItemChecked,
        "path": path, "tag": tag})
    }

    function removeModelData(menuIndex, nodeIndex)
    {
        leftMenuModel.get(menuIndex).subNode.remove(nodeIndex)
    }

    function syncSidebar(path)
    {
        isMenuPath = false
        for(var i = 0 ; i < leftMenuModel.count; ++i)
        {
            var node = leftMenuModel.get(i).subNode
            for(var j = 0; j < node.count; ++j)
            {
                node.get(j).subItemChecked = false
                if(node.get(j).path == path)
                {
                    if(getCurrentTitle(path) == node.get(j).subName)
                    {
                        node.get(j).subItemChecked = true
                        isMenuPath = true
                    }
                }
            }
        }
    }

    function refreshCollectionMenu()
    {
        var node = leftMenuModel.get(2).subNode
        node.clear()

        var collectionList = leftMenuData.getCollectionList();
        for(var i in collectionList)
        {
            addSubNode(2, collectionList[i].label, "assets/leftmenu/folderSelect.png", "assets/leftmenu/folderUnselect.png", false, collectionList[i].path, "null")
        }
    }

    function refreshUSBMenu(deviceList)
    {
        var node = leftMenuModel.get(1).subNode
        if(node.count > 5)
        {
            for(var i = 5; i < node.count; i++)
            {
                node.remove(i)
            }
        }

        for(var i in deviceList)
        {
            addSubNode(1, "USB", "assets/leftmenu/usbSelect.png", "assets/leftmenu/usbUnselect.png", false, deviceList[i], "null")//外接存储设备
        }
    }


    function refreshTagsMenu()
    {
        var node = leftMenuModel.get(3).subNode
        for(var i = 0 ; i < node.count; ++i)
        {
            var subNode = node.get(i)
            switch(i)
            {
                case 0: subNode.subName = tagsSettings.tag0
                    break;
                case 1: subNode.subName = tagsSettings.tag1
                    break;
                case 2: subNode.subName = tagsSettings.tag2
                    break;
                case 3: subNode.subName = tagsSettings.tag3
                    break;
                case 4: subNode.subName = tagsSettings.tag4
                    break;
                case 5: subNode.subName = tagsSettings.tag5
                    break;
                case 6: subNode.subName = tagsSettings.tag6
                    break;
                case 7: subNode.subName = tagsSettings.tag7
                    break;
            }
        }
    }
}