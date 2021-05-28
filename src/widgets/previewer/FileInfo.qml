import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.2 as Maui
import QtGraphicalEffects 1.0

Popup
// Menu
{
    // infoModel.append({key: "Type", value: iteminfo.mime})
    // infoModel.append({key: "Date", value: Qt.formatDateTime(new Date(model.date), "d MMM yyyy")})
    // infoModel.append({key: "Modified", value: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")})
    // infoModel.append({key: "Last Read", value: Qt.formatDateTime(new Date(model.lastread), "d MMM yyyy")})
    // infoModel.append({key: "Size", value: Maui.FM.formatSize(iteminfo.size)})
    // infoModel.append({key: "Path", value: iteminfo.path})
    // infoModel.append({key: "Thumbnail", value: iteminfo.thumbnail})
    // infoModel.append({key: "Icon Name", value: iteminfo.icon})

    property var item : ({})
    property var localPath: ""
    property var fileSize: ""

    id: control
    parent: Overlay.overlay
    width: 275
    height: 366
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

    // onVisibleChanged:{
    //     blurBk.startX = control.x
    //     blurBk.startY = control.y
    // }
    // background: Kirigami.JBlurBackground{
    //     id: blurBk
    //     anchors.fill: parent
    //     sourceItem: applicationWindw().pageStack.currentItem
    // }

    Kirigami.Icon
    {
        id: iconImage
        anchors{
            top: parent.top
            topMargin: 35
            horizontalCenter: parent.horizontalCenter
        }
        width: 70
        height: 70
        source: getIcon(item)
    }

    Text {
        id: fileNameText
        anchors{
            top: iconImage.bottom
            topMargin: 6
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - 100
        text: item.label
        font.pixelSize: 11
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAnywhere
        maximumLineCount: 2
        elide: Text.ElideRight
        clip: true
    }

    Text {
        id: fileSizeText
        anchors{
            top: fileNameText.bottom
            topMargin: 3
            horizontalCenter: parent.horizontalCenter
        }
        // width: parent.width - 5
        horizontalAlignment: Text.AlignHCenter
        text: fileSize//Maui.FM.formatSize(item.size)
        font.pixelSize: 10
        color: "#4D000000"

        Connections
        {
            target: leftMenuData
            onRefreshDirSize: 
            {
                fileSize = Maui.FM.formatSize(size)
                if(fileSize.indexOf("KiB") != -1)
                {
                    fileSize = fileSize.replace("KiB", "K")
                }else if(fileSize.indexOf("MiB") != -1)
                {
                    fileSize = fileSize.replace("MiB", "M")
                }else if(fileSize.indexOf("GiB") != -1)
                {
                    fileSize = fileSize.replace("GiB", "G")
                }
            }
        }

    }

    Text {
        id: infoNameText
        anchors{
            top: fileSizeText.bottom
            topMargin: 28
            left: parent.left
            leftMargin: 25
        }
        // width: parent.width - 5
        text: i18n("Information")
        font.pixelSize: 17
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        clip: true
    }

    Rectangle//文件类型
    {
        id: kindRect
        width: parent.width
        height: 30
        anchors{
            top: infoNameText.bottom
            topMargin: 15
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Kind")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }

        // Text {
        //     anchors{
        //         right: parent.right
        //         rightMargin: 50
        //         verticalCenter: parent.verticalCenter
        //     }
        //     text: item.mime
        //     font.pointSize: textDefaultSize  - 3
        //     color: "#4D000000"
        //     elide: Text.ElideRight
        // }

        TextField  {
            anchors{
                right: parent.right
                rightMargin: 25
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle
            {
                color: "#00000000"
            }
            text: item.mime
            horizontalAlignment: Text.AlignRight
            width: parent.width / 5 * 3
            font.pixelSize: 11
            color: "#4D000000"
            readOnly : true
            selectByMouse: true
        }
    }

    Kirigami.JMenuSeparator 
    { 
        anchors.top: kindRect.bottom
    }

    Rectangle //创建时间
    {
        id: createdRect
        width: parent.width
        height: 30
        anchors{
            top: kindRect.bottom
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Created")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }

        Text {
            anchors{
                right: parent.right
                rightMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.date), "dd.MM.yyyy")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator 
    { 
        anchors.top: createdRect.bottom
    }

    Rectangle//最后修改时间
    {
        id: modifiedRect
        width: parent.width
        height: 30
        anchors{
            top: createdRect.bottom
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Modified")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }

        Text {
            anchors{
                right: parent.right
                rightMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.modified), "dd.MM.yyyy")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator 
    { 
        anchors.top: modifiedRect.bottom
    }

    Rectangle//最后访问时间
    {
        id: lastopenedRect
        width: parent.width
        height: 30
        anchors{
            top: modifiedRect.bottom
        }
        color: "#00000000"

        Text {
            anchors{
                left: parent.left
                leftMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Last opened")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }

        Text {
            anchors{
                right: parent.right
                rightMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: Qt.formatDateTime(new Date(item.lastread), "dd.MM.yyyy")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }
    }

    Kirigami.JMenuSeparator 
    { 
        anchors.top: lastopenedRect.bottom
    }

    Rectangle//所在目录
    {
        id: whereRect
        width: parent.width
        height: 30
        anchors{
            top: lastopenedRect.bottom
        }
        color: "#00000000"

        Text {
            id: whereTextId
            anchors{
                left: parent.left
                leftMargin: 25
                verticalCenter: parent.verticalCenter
            }
            text: i18n("Where")
            font.pixelSize: 11
            color: "#4D000000"
            elide: Text.ElideRight
        }

        // Text {
        //     anchors{
        //         right: parent.right
        //         rightMargin: 50
        //         top: whereTextId.top
        //     }
        //     text: localPath
        //     horizontalAlignment: Text.AlignRight
        //     width: parent.width / 5 * 3
        //     font.pointSize: textDefaultSize - 3
        //     color: "#4D000000"
        //     wrapMode: Text.WrapAnywhere
        //     elide: Text.ElideRight
        //     maximumLineCount: 4
        // }

        TextField  {
            anchors{
                right: parent.right
                rightMargin: 25
                top: whereTextId.top
                topMargin: -10
            }
            background: Rectangle
            {
                color: "#00000000"
            }
            text: localPath
            horizontalAlignment: Text.AlignRight
            width: parent.width / 5 * 3
            font.pixelSize: 11
            color: "#4D000000"
            readOnly : true
            selectByMouse: true
        }
    }



    function show(index)
    {
        if(index == -1)//在页面的空白处右键info 相当于获取上级目录的信息
        {
            item = Maui.FM.getFileInfo(root.currentPath)
        }else
        {
            item = root.currentBrowser.currentFMModel.get(index)
        }
        if(item.path.indexOf("file://") >= 0)
        {
            localPath = item.path.replace("file://", "")
        }else
        {
            localPath = item.path
        }

        //计算文件或者文件夹大小 start
        if(item.isdir == "true")//文件夹大小获取
        {
            leftMenuData.getDirSize(localPath)
        }else//单个文件获取
        {
            fileSize = Maui.FM.formatSize(item.size)
            if(fileSize.indexOf("KiB") != -1)
            {
                fileSize = fileSize.replace("KiB", "K")
            }else if(fileSize.indexOf("MiB") != -1)
            {
                fileSize = fileSize.replace("MiB", "M")
            }else if(fileSize.indexOf("GiB") != -1)
            {
                fileSize = fileSize.replace("GiB", "G")
            }
        }
        //计算文件或者文件夹大小 end

        var lastg = localPath.lastIndexOf("/") 
        if(lastg >= 0)
        {
            localPath = localPath.substring(0, lastg)
        }
        
        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }

    onClosed:
    {
        leftMenuData.cancelGetDirSize()
    }
}
