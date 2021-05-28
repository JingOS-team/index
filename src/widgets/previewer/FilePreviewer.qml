import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Page
// Rectangle
{
    id: control

    // anchors.fill: parent

    property url currentUrl: ""

    property alias listView : _listView
    property alias model : _listView.model
    property alias currentIndex: _listView.currentIndex

    property bool isFav : false
    property bool isDir : false
    property bool showInfo: true
    property int type : 0 //那种类型的文件  1--音频

    // property alias tagBar : _tagsBar

    // title: _listView.currentItem.title

    // headerBackground.color: "transparent"
    // headBar.rightContent: ToolButton
    // {
    //     icon.name: "documentinfo"
    //     checkable: true
    //     checked: control.showInfo
    //     onClicked: control.showInfo = !control.showInfo
    // }

    background: Rectangle
    {
        color: "#00000000"
    }

    ListView
    {
        id: _listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        currentIndex: -1
        clip: true
        focus: true
        spacing: 0
        interactive: false//Maui.Handy.isTouch
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        highlightResizeDuration : 0
        snapMode: ListView.SnapOneItem
        cacheBuffer: width
        keyNavigationEnabled : true
        keyNavigationWraps : true
        // onMovementEnded: currentIndex = indexAt(contentX, contentY)

        delegate: Item
        {
            id: _delegate

            height: ListView.view.height
            width: ListView.view.width

            property bool isCurrentItem : ListView.isCurrentItem
            property url currentUrl: model.path
            property var iteminfo : model
            property alias infoModel : _infoModel
            readonly property string title: model.label

            Loader
            {
                id: previewLoader
                active: _delegate.isCurrentItem
                visible: !control.showInfo
                width: parent.width
                height: parent.height
                onActiveChanged: if(active) show(currentUrl)
            }

            Kirigami.ScrollablePage
            {
                id: _infoContent
                anchors.fill: parent
                visible: control.showInfo

                Kirigami.Theme.backgroundColor: "transparent"
                padding:  0
                leftPadding: padding
                rightPadding: padding
                topPadding: padding
                bottomPadding: padding

                ColumnLayout
                {
                    width: parent.width
                    spacing: 0

                    Item
                    {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        Kirigami.Icon
                        {
                            height: Maui.Style.iconSizes.large
                            width: height
                            anchors.centerIn: parent
                            source: iteminfo.icon
                        }
                    }

                    Maui.Separator
                    {
                        // position: Qt.Horizontal
                        Layout.fillWidth: true
                    }

                    Repeater
                    {
                        model: ListModel { id: _infoModel }
                        delegate: Maui.AlternateListItem
                        {
                            visible: model.value
                            Layout.preferredHeight: visible ? _delegateColumnInfo.label1.implicitHeight + _delegateColumnInfo.label2.implicitHeight + Maui.Style.space.large : 0
                            Layout.fillWidth: true
                            lastOne: index === _infoModel.count-1

                            Maui.ListItemTemplate
                            {
                                id: _delegateColumnInfo

                                iconSource: "documentinfo"
                                iconSizeHint: Maui.Style.iconSizes.medium

                                anchors.fill: parent
                                anchors.margins: Maui.Style.space.medium

                                label1.text: model.key
                                label1.font.weight: Font.Bold
                                label1.font.bold: true
                                label2.text: model.value
                                label2.elide: Qt.ElideMiddle
                                label2.wrapMode: Text.Wrap
                                label2.font.weight: Font.Light
                            }
                        }
                    }
                }
            }

            function show(path)//各个文件类型
            {
                leftMenuData.addFileToRecents(path.toString());

                initModel()

                control.isDir = model.isdir == "true"
                control.currentUrl = path
                root.currentTitle = iteminfo.label

                var source = "DefaultPreview.qml"
                if(iteminfo.mime.indexOf("audio") != -1)//音频 直接播放
                {
                    source = "AudioPreview.qml"
                    type = 1
                }
                else if(Maui.FM.checkFileType(Maui.FMList.TEXT, iteminfo.mime))
                {
                    source = "TextPreview.qml"
                }
                else if(Maui.FM.checkFileType(Maui.FMList.DOCUMENT, iteminfo.mime))
                {
                    source = "DocumentPreview.qml"
                }
                else
                {
                    source = "DefaultPreview.qml"
                }

                root.currentTitle = getCurrentTitle(currentBrowser.currentPath)
                if(source == "DefaultPreview.qml")
                {
                    return
                }
                previewLoader.source = source
                control.showInfo = source === "DefaultPreview.qml"
            }

            function initModel()
            {
                infoModel.clear()
                infoModel.append({key: "Type", value: iteminfo.mime})
                infoModel.append({key: "Date", value: Qt.formatDateTime(new Date(model.date), "d MMM yyyy")})
                infoModel.append({key: "Modified", value: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")})
                infoModel.append({key: "Last Read", value: Qt.formatDateTime(new Date(model.lastread), "d MMM yyyy")})
                infoModel.append({key: "Owner", value: iteminfo.owner})
                infoModel.append({key: "Group", value: iteminfo.group})
                infoModel.append({key: "Size", value: Maui.FM.formatSize(iteminfo.size)})
                infoModel.append({key: "Symbolic Link", value: iteminfo.symlink})
                infoModel.append({key: "Path", value: iteminfo.path})
                infoModel.append({key: "Thumbnail", value: iteminfo.thumbnail})
                infoModel.append({key: "Icon Name", value: iteminfo.icon})
            }
        }
    }

    footerColumn: [
        Maui.ToolBar
        {
            width: parent.width
            height: 1
            position: ToolBar.Bottom
            background: null
            visible: true
        }

       ]
}
