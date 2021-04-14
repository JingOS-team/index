/*
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.11
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

Rectangle {
    id:leftMenu

    color: "#00000000"

    ListView {
        id:menuListView
        clip: true
        anchors.fill: parent
        model: ListModel {
            id:leftMenuModel
        }
        delegate: leftMenuDelegate
    }

    Component.onCompleted: {
        leftMenuModel.append({"menuName": "Type", "openState": true, "subNode":[]})
        addSubNode(0, "Document", "assets/leftmenu/documentSelect.png", "assets/leftmenu/documentUnselect.png", false, "qrc:/widgets/views/Document", "null")//文档类
        addSubNode(0, "Picture", "assets/leftmenu/picSelect.png", "assets/leftmenu/picUnselect.png", false, "qrc:/widgets/views/Picture", "null")//图片类
        addSubNode(0, "Video", "assets/leftmenu/videoSelect.png", "assets/leftmenu/videoUnselect.png", false, "qrc:/widgets/views/Video", "null")//音视频类
        addSubNode(0, "Music", "assets/leftmenu/musicSelect.png", "assets/leftmenu/musicUnselect.png", false, "qrc:/widgets/views/Music", "null")//其他类 都是文件 文件夹不在这里展示                        

        leftMenuModel.append({"menuName": "Location", "openState": true, "subNode":[]})
        addSubNode(1, "Recents", "assets/leftmenu/recentsSelect.png", "assets/leftmenu/recentsUnselect.png", false, "qrc:/widgets/views/Recents", "null")//最近浏览 1个月期限
        addSubNode(1, leftMenuData.getUserName(), "assets/leftmenu/jingosSelect.png", "assets/leftmenu/jingosUnselect.png", true, leftMenuData.getHomePath(), "null")//用户名
        addSubNode(1, "Downloads", "assets/leftmenu/downloadSelect.png", "assets/leftmenu/downloadUnselect.png", false, leftMenuData.getDownloadsPath(), "null")//系统级目录--下载 此文件夹可能会被删除 删除就不再展示了 用户再创建-再展示
        addSubNode(1, "On My Pad", "assets/leftmenu/onMyPadSelect.png", "assets/leftmenu/onMyPadUnselect.png", false, leftMenuData.getRootPath(), "null")//根目录
        addSubNode(1, "Trash", "assets/leftmenu/trashSelect.png", "assets/leftmenu/trashUnselect.png", false, leftMenuData.getTrashPath(), "null")//回收站

        leftMenuModel.append({"menuName": "Collection", "openState": true, "subNode":[]})
        var collectionList = leftMenuData.getCollectionList();
        if(collectionList.lenght > 0) {
            for(var i in collectionList) {
                addSubNode(2, collectionList[i].label, "assets/leftmenu/folderSelect.png", "assets/leftmenu/folderUnselect.png", false, "null", "null")
            }
        }

        currentTitle = leftMenuData.getUserName()
        isMenuPath = true
    }

    Component {
        id:leftMenuDelegate

        Column {
            id:objColumn

            Component.onCompleted: {
                for(var i = 1; i < objColumn.children.length - 1; ++i) {
                    objColumn.children[i].visible = true
                }
            }

            Rectangle {
                visible: {
                    if(subNode.count > 0) {
                        true
                    } else {
                        false
                    }
                }

                width:typeRect.width
                height: typeRect.height
                color: "#00000000"

                Rectangle {
                    id: typeRect

                    color: "#00000000"

                    width: menuListView.width
                    height: 90

                    Text {
                        id: typeText

                        text: menuName
                        elide: Text.ElideRight
                        color: '#4D000000'
                        font {
                            pointSize: theme.defaultFont.pointSize - 2
                        }

                        anchors.left: parent.left
                        anchors.leftMargin: 50
                        anchors.bottom: typeRect.bottom
                        anchors.bottomMargin: 10

                        width: parent.width
                    }

                    Kirigami.JIconButton {
                        id: typeIcon
                        width: 44 + 10
                        height: 44 + 10
                        source: {
                            if(openState)
                            {
                                "qrc:/assets/leftmenu/downArrow.png"
                            }else
                            {
                                "qrc:/assets/leftmenu/upArrow.png"
                            }
                        }

                        anchors.right: parent.right
                        anchors.rightMargin: 40
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
                    radius: 15
                    
                    anchors.left: parent.left
                    anchors.leftMargin: wholeScreen.width / 76.8

                    width: parent.width - parent.width / 9.6
                    height: 78

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
                                currentBrowser.openFolder(model.path)
                                root.searchState = false
                                if(model.path == "qrc:/widgets/views/Document"
                                || model.path == "qrc:/widgets/views/Picture"
                                || model.path == "qrc:/widgets/views/Video"
                                || model.path == "qrc:/widgets/views/Music"
                                || model.path == "qrc:/widgets/views/Recents")
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
                    }

                    Image
                    {   
                        id: subDelegateIcon    

                        source: model.subItemChecked ? model.subIconSelect : model.subIconUnselect
                        fillMode: Image.PreserveAspectFit

                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.verticalCenter: parent.verticalCenter

                        width: 32
                        height: 32
                    }

                    Text
                    {
                        text: model.subName
                        elide: Text.ElideRight
                        color: model.subItemChecked ? '#FFFFFFFF' : '#FF000000'
                        font
                        {
                            pointSize: theme.defaultFont.pointSize + 2
                        }

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: subDelegateIcon.right
                        anchors.leftMargin: 20

                        width: parent.width
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
        var noName = false //root这个目录比较特殊 左侧菜单的name和右侧要展示title不一样 所以需要特殊判断 其他的则需要path和name都一起匹配
        if(path == leftMenuData.getRootPath())
        {
            noName = true
        }
        for(var i = 0 ; i < leftMenuModel.count; ++i)
        {
            var node = leftMenuModel.get(i).subNode
            for(var j = 0; j < node.count; ++j)
            {
                node.get(j).subItemChecked = false
                if(node.get(j).path == path)
                {
                    if(noName)
                    {
                        node.get(j).subItemChecked = true
                        isMenuPath = true
                    }else if(getCurrentTitle(path) == node.get(j).subName)
                    {
                        node.get(j).subItemChecked = true
                        isMenuPath = true
                    }
                    
                }
            }
        }
    }
}