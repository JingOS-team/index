import QtQuick 2.9
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui
import QtQuick.Controls 2.14

Rectangle {
    id: listViewDelegate

    property string iconSource
    property string tagSource
    property string fileSize
    property string fileName
    property string fileDate
    property string tagColor
    property bool isFolder
    property int textDefaultSize: theme.defaultFont.pointSize
    property bool checked: _selectionBar.contains(path)
    property bool isRename: _renameSelectionBar.contains(path)
    property bool menuSelect: false
    property string tmpName
    property var clickMouse
    /**
      * draggable :
      */
    property bool draggable: false


    /**
      * pressed :
      */
    signal pressed(var mouse)

    /**
      * pressAndHold :
      */
    signal pressAndHold(var mouse)

    /**
      * clicked :
      */
    signal clicked(var mouse)

    /**
      * rightClicked :
      */
    signal rightClicked(var mouse)

    /**
      * doubleClicked :
      */
    signal doubleClicked(var mouse)

    signal contentDropped(var drop)

    /**
      * toggled :
      */
    signal toggled(bool state)

    color: "#FFFFFFFF"
    radius: 10
    // color: "#2E3C3C43"

    Image //编辑态时的选中 非选中状态
    {
        id: checkStatusImage

        anchors{
            left: parent.left
            leftMargin: 8
            verticalCenter: parent.verticalCenter
        }

        width: 22
        height: 22

        cache: false
        source: 
        {
            if(checked)
            {
                "qrc:/assets/select_all.png"
            }else{
                "qrc:/assets/unselect_rect.png"
            }
        }
        
        visible: 
        {
            if(root.selectionMode)
            {
                true
            }else
            {
                false
            }
        }
    }

    // Kirigami.Icon//文件或者文件夹icon
    // {
    //     id: iconImage

    //     anchors{
    //         left: 
    //         {
    //             if(root.selectionMode)
    //             {
    //                 checkStatusImage.right
    //             }else
    //             {
    //                 parent.left
    //             }
    //         }
    //         leftMargin: 
    //         {
    //             if(root.selectionMode)
    //             {
    //                 10
    //             }else
    //             {
    //                 0
    //             }
    //         }
    //         verticalCenter: parent.verticalCenter
    //     }
    //     width: 88
    //     height: width
    //     source: 
    //     {
    //         // if(mime.indexOf("image") == -1)
    //         // {
    //                 iconSource
    //         // }else
    //         // {
    //         //     thumbnail
    //         // }
    //     }
    //     isMask: true
    // }


    Image
    {
        id: iconImage
        asynchronous: true
        cache: true
        smooth: false
        sourceSize.width: 44
        sourceSize.height: 44

        fillMode: Image.PreserveAspectCrop
        anchors{
            left: 
            {
                if(root.selectionMode)
                {
                    checkStatusImage.right
                }else
                {
                    parent.left
                }
            }
            leftMargin: 
            {
                if(root.selectionMode)
                {
                    5
                }else
                {
                    0 + 5
                }
            }
            verticalCenter: parent.verticalCenter
        }

        width: 44
        height: 44
        visible: !root_zipList._uris.includes(model.path)
        source: 
        {
            iconSource
        }

        Connections
        {
            target: leftMenuData
            onRefreshImageSource: 
            {
                if(iconSource == imagePath)
                {
                    if(mime.indexOf("image") != -1)
                    {
                        iconImage.source = "qrc:/assets/image_default.png"
                    }else if(mime.indexOf("video") != -1)
                    {
                        iconImage.source = "qrc:/assets/video_default.png"
                    }
                    iconImage.source = imagePath
                }
            }
        }
    }

    AnimatedImage
    {
        id: gifImage

        width: 44
        height: 44

        fillMode: Image.PreserveAspectFit
        anchors{
            left: 
            {
                if(root.selectionMode)
                {
                    checkStatusImage.right
                }else
                {
                    parent.left
                }
            }
            leftMargin: 
            {
                if(root.selectionMode)
                {
                    5
                }else
                {
                    0 + 5
                }
            }
            verticalCenter: parent.verticalCenter
        }

        source: 
        {
            if(model.label.indexOf(".zip") != -1)
            {
                "qrc:/assets/zip.gif"
            }else
            {
                "qrc:/assets/unzip.gif"
            }
        }

        visible: root_zipList._uris.includes(model.path)

        playing: visible
        
        MouseArea 
        {
        }
    }

    Kirigami.Icon
    {
        visible: iconImage.status !== Image.Ready
        anchors{
            left: 
            {
                if(root.selectionMode)
                {
                    checkStatusImage.right
                }else
                {
                    parent.left
                }
            }
            leftMargin: 
            {
                if(root.selectionMode)
                {
                    5
                }else
                {
                    0 + 5
                }
            }
            verticalCenter: parent.verticalCenter
        }
        height: 44
        width: 44
        source: 
        {
            if(mime.indexOf("image") != -1)
            {
                "qrc:/assets/image_default.png"
            }else if(mime.indexOf("video") != -1)
            {
                "qrc:/assets/video_default.png"
            }else
            {
                "qrc:/assets/default.png"
            }
        }
        isMask: false
        opacity: 0.5
    }

    Rectangle{//文件名称和文件大小 或者文件夹名称和文件多少
        id:fileNameSize

        anchors{
            left: iconImage.right
            leftMargin: 15
            verticalCenter: parent.verticalCenter
        }
        width: parent.width / 2
        height: fileSizeText.height + fileNameText.height + 13//iconImage.height - 20
        color: "transparent"

        Text {
            visible:
            {
                if(!isRename)
                {
                    true
                }else
                {
                    false
                }
            } 
            id: fileNameText1
            anchors{
                top: parent.top
                topMargin: 12
                left: parent.left
            }
            width: parent.width
            text: fileName
            font.pixelSize: 11
            color: "black"
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 1
            elide: Text.ElideRight
            clip: true
        }

        TextField  {
                background: Rectangle
                {
                    color: "#00000000"
                }
                visible: 
                {
                    if(!isRename)
                    {
                        false
                    }else
                    {
                        true
                    }
                }
                id: fileNameText
                anchors{
                    top: parent.top
                    topMargin: 4
                    left: parent.left
                    leftMargin: -8
                }
                text:
                {
                    fileName
                } 
                maximumLength: 50
                font.pixelSize: 11
                color: "black"
                horizontalAlignment: Text.AlignLeft
                clip: true
                selectionColor: "#FF3C4BE8"
                width: parent.width

                onEditingFinished: {
                    if((fileNameText.text.indexOf("#") != -1)
                    || (fileNameText.text.indexOf("/") != -1)
                    || (fileNameText.text.indexOf("?") != -1))
                    {//不允许包含特殊字符
                        fileNameText.text = tmpName
                        showToast(i18n("The file name cannot contain the following characters: '# / ?'"))
                    }else if(fileNameText.text.startsWith("."))
                    {
                        fileNameText.text = tmpName
                        showToast(i18n("The file name cannot starts whit character: '.'"))
                    }else
                    {
                        var canRename = true
                        var userNotRename = false //处理用户rename了，但是没有任何修改直接退出了rename状态
                        for(var i = 0; i < currentBrowser.currentFMList.count; i++)
                        {
                            var item = currentFMModel.get(i)
                            if(item.label == fileNameText.text)
                            {
                                if(item.path != model.path)
                                {
                                    canRename = false
                                }else
                                {
                                    userNotRename = true
                                }
                                break
                            }
                        }

                        if(!userNotRename)
                        {
                            if(canRename)
                            {
                                var collectionList = leftMenuData.getCollectionList();
                                var needRefreshCollection = false
                                if(leftMenuData.isCollectionFolder(path))
                                {
                                    leftMenuData.addFolderToCollection(path.toString(), true, false)
                                    needRefreshCollection = true
                                }

                                Maui.FM.rename(path, fileNameText.text)

                                if(item.mime.indexOf("image/jpeg") != -1
                                || item.mime.indexOf("video") != -1)//对于生成了缩略图的文件来说 重命名时 会连带缩略图一起
                                {
                                    var index = item.path.lastIndexOf(".")
                                    var newPath = item.path.substring(0, index)//path/name
                                    index = newPath.lastIndexOf("/")
                                    var startPath = newPath.substring(0, index + 1);//path/
                                    var endPath = newPath.substring(index + 1, newPath.length)//name
                                    var tmpPreview = startPath + "." + endPath + ".jpg"
                                    Maui.FM.rename(tmpPreview, "." + fileNameText.text)
                                }

                                if(root.isSpecialPath)//如果是特殊目录，系统不会自动刷新，那么需要自行刷新
                                {
                                    timer_refresh.start()
                                }

                                if(needRefreshCollection)
                                {
                                    timer_fav.start();
                                }
                            }else
                            {
                                fileNameText.text = tmpName
                                showToast(i18n("The file name already exists."))
                            }
                        }
                    }
                    root_renameSelectionBar.clear()
                }

                onFocusChanged:
                {
                    if(focus)
                    {
                        tmpName = fileNameText.text
                    }
                }
            }

        // TextInput 
        // {
        //     id: fileNameText
        //     anchors{
        //         top: parent.top
        //     }
        //     text: 
        //     {
        //         fileName
        //     }
        //     font.pointSize: textDefaultSize - 3
        //     color: "black"
        //     // width: parent.width - 5
        //     horizontalAlignment: Text.AlignLeft
        //     wrapMode: Text.NoWrap
        //     clip: true
        //     maximumLength: 50
        //     selectionColor: "#FF3C4BE8"

        //     onEditingFinished: {
        //         if((fileNameText.text.indexOf("#") != -1)
        //         || (fileNameText.text.indexOf("/") != -1)
        //         || (fileNameText.text.indexOf("?") != -1))
        //         {
        //             fileNameText.text = tmpName
        //             showToast(i18n("The file name cannot contain the following characters: '# / ?'"))
        //         }else if(fileNameText.text.startsWith("."))
        //         {
        //             fileNameText.text = tmpName
        //             showToast(i18n("The file name cannot starts whit character: '.'"))
        //         }
        //         else
        //         {
        //             var canRename = true
        //             var userNotRename = false //处理用户rename了，但是没有任何修改直接退出了rename状态
        //             for(var i = 0; i < currentBrowser.currentFMList.count; i++)
        //             {
        //                 var item = currentFMModel.get(i)
        //                 if(item.label == fileNameText.text)
        //                 {
        //                     if(item.path != model.path)
        //                     {
        //                         canRename = false
        //                     }else
        //                     {
        //                         userNotRename = true
        //                     }
        //                     break
        //                 }
        //             }

        //             if(!userNotRename)
        //             {
        //                 if(canRename)
        //                 {
        //                     var collectionList = leftMenuData.getCollectionList();
        //                     var needRefreshCollection = false
        //                     if(leftMenuData.isCollectionFolder(path))
        //                     {
        //                         leftMenuData.addFolderToCollection(path.toString(), true, false)
        //                         needRefreshCollection = true
        //                     }

        //                     Maui.FM.rename(path, fileNameText.text)

        //                     if(item.mime.indexOf("image/jpeg") != -1
        //                     || item.mime.indexOf("video") != -1)//对于生成了缩略图的文件来说 重命名时 会连带缩略图一起
        //                     {
        //                         var index = item.path.lastIndexOf(".")
        //                         var newPath = item.path.substring(0, index)//path/name
        //                         index = newPath.lastIndexOf("/")
        //                         var startPath = newPath.substring(0, index + 1);//path/
        //                         var endPath = newPath.substring(index + 1, newPath.length)//name
        //                         var tmpPreview = startPath + "." + endPath + ".jpg"
        //                         Maui.FM.rename(tmpPreview, "." + fileNameText.text)
        //                     }

        //                     if(root.isSpecialPath)//如果是特殊目录，系统不会自动刷新，那么需要自行刷新
        //                     {
        //                         timer_refresh.start()
        //                     }

        //                     if(needRefreshCollection)
        //                     {
        //                         timer_fav.start();
        //                     }
        //                 }else
        //                 {
        //                     fileNameText.text = tmpName
        //                     showToast(i18n("The file name already exists."))
        //                 }
        //             }
        //         }
        //         root_renameSelectionBar.clear()
        //     }

        //     onFocusChanged:
        //     {
        //         if(focus)
        //         {
        //             tmpName = fileNameText.text
        //         }
        //     }
        // }

        Text {
            id: fileSizeText

            anchors{
                top: fileNameText.bottom
                //topMargin: 13
            }
            text: fileSize

            font.pixelSize: 10
            color: "#4D000000"

            visible:
            {
                if(String(root.currentPath).startsWith("trash:/") && model.isdir == "true")
                {
                    false
                }else
                {
                    true
                }
            }
        }
    }

    // Rectangle{
    //     id:tagRect
    //     anchors{
    //         right: fileDateText.left
    //         rightMargin: 10
    //         verticalCenter: fileDateText.verticalCenter
    //     }
    //     width: tagColor !== "" ? 10 : 0
    //     height: width
    //     radius: width/2
    //     color: "#FFFF0000"//tagColor
    // }

    Image{
        id:tagRect
        anchors{
            right: fileDateText.left
            rightMargin: 6
            verticalCenter: fileDateText.verticalCenter//parent.verticalCenter//fileDateText.verticalCenter
            // top: fileDateText.top
            // topMargin: -5
        }
        width: tagSource !== "" ? 16 : 0
        height: 16
        source: tagSource
    }

    Text {//最后修改日期
        id: fileDateText

        anchors{
            right: parent.right
            rightMargin: 22 + 10
            verticalCenter: parent.verticalCenter
        }
        text: fileDate
        // font.pointSize:  textDefaultSize - 3
        font.pixelSize: 11
        color: "#4D000000"
    }

    Loader{
        id:rightArrowLoader
        sourceComponent: rightArrowComponent
        active: isFolder
    }
    Component{
        id:rightArrowComponent
        Item{
            width: listViewDelegate.width
            height: listViewDelegate.height
            Image {
                id: rightArrowImage

                anchors{
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: 22
                height: 22
                asynchronous: true
                source: "qrc:/assets/right_arrow.png"
            }
        }
    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        enabled: listViewDelegate.draggable

        Rectangle
        {
            anchors.fill: parent
            radius: 10
            color: "blue"
            visible: parent.containsDrag
            opacity: 0.3
        }

        onDropped:
        {
            listViewDelegate.contentDropped(drop)
        }
    }

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton | Qt.LeftButton
        property bool pressAndHoldIgnored : false
        drag.axis: Drag.XAndYAxis

        onCanceled:
        {
            if(listViewDelegate.draggable)
            {
                drag.target = null
            }
        }

        onClicked:
        {
            if(mouse.button === Qt.RightButton)
            {
                listViewDelegate.rightClicked(mouse)
            }
            else
            {
                listViewDelegate.color = "#1F767680"
                clickMouse = mouse
                timer.start()
            }
        }

        onDoubleClicked:
        {
            listViewDelegate.doubleClicked(mouse)
        }

        onPressAndHold :
        {
          
                drag.target = null
                listViewDelegate.pressAndHold(mouse)
        }
    }

    Connections
    {
        target: root_selectionBar

        onUriRemoved:
        {
            if(String(root.currentPath).startsWith("trash:/"))    
            {
                if(uri === model.nickname)
                {
                    listViewDelegate.checked = false
                }
            }else
            {
                if(uri === model.path)
                {
                    listViewDelegate.checked = false
                }
            }
        }

        onUriAdded:
        {
            if(String(root.currentPath).startsWith("trash:/"))    
            {
                if(uri === model.nickname)
                {
                    listViewDelegate.checked = true
                }
            }else
            {
                if(uri === model.path)
                {
                    listViewDelegate.checked = true
                }
            }
        }

        onCleared: listViewDelegate.checked = false
    }

    Connections
    {
        target: root_renameSelectionBar
        
        onUriRemoved:
        {
            if(uri === model.path)
            {
                fileNameText.focus = false
                isRename = false
            }
        }

        onUriAdded:
        {
            if(uri === model.path)
            {
                fileNameText.forceActiveFocus()
                var indexOfd = fileNameText.text.lastIndexOf(".")
                if(indexOfd != -1)
                {
                    fileNameText.select(0, indexOfd)
                }else
                {
                    fileNameText.selectAll()
                }
                isRename = true
            }
        }

        onCleared: 
        {
            fileNameText.focus = false
        }
    }

    Connections
    {
        target: root_menuSelectionBar

        onUriRemoved:
        // function onUriRemoved() 
        {
            if(uri === model.path)
                listViewDelegate.color = "#FFFFFFFF"
        }

        onUriAdded:
        // function onUriAdded() 
        {
            if(uri === model.path)
                listViewDelegate.color = "#1F9F9FAA"
        }

        onCleared: 
        // function onCleared() 
        {
            listViewDelegate.color = "#FFFFFFFF"
        }
    }

    Timer {
        id: timer
        running: false
        repeat: false
        interval: 50
        onTriggered: {
            listViewDelegate.color = "#FFFFFFFF"
            listViewDelegate.clicked(clickMouse)
        }
    }

    Timer {
        id: timer_fav
        running: false
        repeat: false
        interval: 50
        onTriggered: {
            var index = path.lastIndexOf("/")
            var startPath = path.substring(0, index + 1)
            leftMenuData.addFolderToCollection((startPath + fileNameText.text).toString(), false, true)
        }
    }

    Timer {
        id: timer_refresh
        running: false
        repeat: false
        interval: 100
        onTriggered: {
            root.currentBrowser.currentFMList.refresh()
            // for(var j = 0; j < root.currentBrowser.currentFMList.count; j++)
            // {
            //     var listItem = root.currentBrowser.currentFMModel.get(j)
            //     if(listItem.path == path)
            //     {
            //         root.currentBrowser.currentFMList.refreshItem(j, listItem.path)
            //         break
            //     }
            // }
        }
    }
}
