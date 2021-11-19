// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//           2021      Zhang He Gang <zhanghegang@jingos.com>
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import Qt.labs.settings 1.0
import QtQml.Models 2.3

import org.kde.kirigami 2.15 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.index 1.0 as Index
import jingos.display 1.0

import "widgets"
import "widgets/views"
import "widgets/previewer"

Kirigami.ApplicationWindow {
    id: root

    width: screen.width
    height: screen.height

    property bool isOpenWithUrl: false
    property string currentTitle: i18n("Document")
    property bool isMenuPath: true
    property int textDefaultSize: theme.defaultFont.pointSize
    property bool selectionMode: false
    property bool isCreateFolfer: false
    property string newFolderPath: "null"
    property bool searchState: false
    property bool isSpecialPath: false
    property bool isNothingHere: false
    property int menuX: 0
    property int menuY: 0

    property url currentPath: currentBrowser ? currentBrowser.currentPath : ""
    property FileBroswerView currentBrowser: currentTab
                                                          && currentTab.browser ? currentTab.browser : null
    property var currentItem: ({})
    property alias currentTab:wholeScreen.mainCurrentTab
    property alias appSettings: settings
    property alias root_zipList: _zipList
    property alias root_selectionBar: _selectionBar
    property alias root_renameSelectionBar: _renameSelectionBar
    property alias root_menuSelectionBar: _menuSelectionBar
    property alias root_musicPage: wholeScreen.mainMusicPage
    property alias root_fileInfo: _fileInfo
    property alias root_editTagMenu: _editTagMenu
    property alias root_tagMenu: _tagMenu
    property alias root_indexColumn: wholeScreen.mainIndexColumn
    property alias _browserList: wholeScreen.mainPageContent
    property alias leftMenu: wholeScreen.mainLeftmenu
    property alias tabsObjectModel: wholeScreen.mainTabObject
    property alias previewimagemodel: wholeScreen.mainPreviewImage
    property alias preiviewLoader: wholeScreen.mainPreviewLoader
    property var imageUrl: "" 
    property var imageTitle: "" 
    property int imageIndex: 0 
    property int deleteIndex: 0
    property alias root_nullPage: wholeScreen.mainNullPage
    property var appScaleSize: JDisplay.dp(1.0)
    property var appFontSize: JDisplay.sp(1.0)
    property bool isAppOpenning: false
    property bool isDarkTheme: Kirigami.JTheme.colorScheme === "jingosDark"
    property int jDialogType: 1
    property QtObject m_zipList: QtObject {
        id: _zipList
        property var _uris: []
    }
    property string searchText: ""

    visible: realVisible

    onActiveChanged: {
        console.log(" active changed::" + active)
        if (!active) {
            openTimer.stop()
            isAppOpenning = false
        }
    }

    onCurrentPathChanged: {
        root_musicPage.resetList()
        root_musicPage.setPause(false)
        root_musicPage.visible = false
        leftMenu.syncSidebar(currentBrowser.currentPath)
        currentTitle = getCurrentTitle(currentBrowser.currentPath)
    }

    Timer {
        id: searchTimer
        running: false
        repeat: false
        interval: 500

        onTriggered: {
            currentBrowser.currentFMList.search(
                        searchText,
                        currentBrowser.currentFMList)
        }
    }

    Timer {
        id: openTimer
        interval: 3000
        onTriggered: {
            isAppOpenning = false
        }
    }

    CustomPopup {
        id: customPopup
    }

    Index.LeftMenuData {
        id: leftMenuData
    }

    Index.CompressedFile
    {
        id: _compressedFile
    }

    FileInfo {
        id: _fileInfo
    }

    TagMenu {
        id: _tagMenu
    }

    EditTagMenu {
        id: _editTagMenu
    }

    Kirigami.JToolTip {
        id: toast
        font.pixelSize: 17 * appFontSize
    }

    Settings {
        id: settings
        category: "Browser"
        property bool showHiddenFiles: false
        property bool showThumbnails: true
        property bool singleClick: Kirigami.Settings.isMobile ? true : Maui.Handy.singleClick
        property bool previewFiles: Kirigami.Settings.isMobile
        property bool restoreSession: false
        property bool supportSplit: !Kirigami.Settings.isMobile

        property int viewType: Maui.FMList.LIST_VIEW
        property int listSize: 0 
        property int gridSize: 1

        property var lastSession: [[({
                                         "path": Maui.FM.homePath(),
                                         "viewType": 1
                                     })]]
        property int lastTabIndex: 0
    }

    Settings {
        id: sortSettings
        category: "Sorting"
        property bool foldersFirst: true
        property int sortBy: Maui.FMList.LABEL
        property int sortOrder: Qt.AscendingOrder
        property bool group: false
        property bool globalSorting: Kirigami.Settings.isMobile
    }

    Settings {
        id: tagsSettings
        category: "tagsSettings"
        property string tag0: i18n("Important")
        property string tag1: i18n("Life")
        property string tag2: i18n("Temporary")
        property string tag3: i18n("Work")
        property string tag4: i18n("Meeting")
        property string tag5: i18n("File")
        property string tag6: i18n("Picture")
        property string tag7: i18n("Private")
    }

    SelectionBar
    {
        id: _renameSelectionBar
    }

    SelectionBar
    {
        id: _menuSelectionBar
    }

    SelectionBar
    {
        id: _selectionBar
    }

    // add by huan lele
    Kirigami.JOpenModeDialog {
        id: _openWithDialog
    }

    //end add
    Kirigami.JDialog {
        id: jDialog
        property var deleteUrls

        closePolicy: Popup.CloseOnEscape
        leftButtonText: i18n("Cancel")
        rightButtonText: i18n("Delete")
        title: i18n("Delete")

        text: {
            if (_selectionBar.items.length > 1) {
                i18n("Are you sure you want to delete these files?")
            } else {
                i18n("Are you sure you want to delete the file?")
            }
        }

        onLeftButtonClicked: {
            close()
        }

        onRightButtonClicked: {
            if (jDialogType == 1) {
                if (_selectionBar.items.length >= 1) {
                    Maui.FM.removeFiles(_selectionBar.uris)
                    clearSelectionBar()
                } else {
                    Maui.FM.removeFiles([currentItem.nickname])
                }
                root.currentBrowser.currentFMList.refresh()
            } else if (jDialogType == 2) {
                Maui.FM.emptyTrash()
                root.currentBrowser.currentFMList.refresh()
            } else if (jDialogType === 3) {
                Maui.FM.removeFiles(jDialog.deleteUrls)
                clearSelectionBar()
            }

            selectionMode = false
            close()
        }
    }
    Kirigami.JDialog {
        id: errorDialog
        property var errorTitle
        property var errorContent
        title: errorDialog.errorTitle
        text: errorDialog.errorContent
        centerButtonText: i18n("OK")
        onCenterButtonClicked: {
            errorDialog.close()
        }
    }

    function mainMoveToTrash(urls) {
        for (var i = 0; i < urls.length; i++) {
            var url = urls[i].toString()
            var isCF = Index.ProcessModel.isCopyingFile(url)
            if (isCF) {
                showToast(i18n("The file could not be deleted because it is being copied."))
                return
            }
            if (url.startsWith("file:///media")) {
                jDialogType = 3
                jDialog.text = i18n("Deleted files cannot be recovered.  Are you sure you want to delete this file ?")
                jDialog.deleteUrls = urls
                jDialog.open()
                return
            }
        }
        leftMenuData.moveToTrash(urls)
    }

    FileMainView
    {
        id: wholeScreen

        anchors.fill: parent
        color: "#00000000"
     }

    Connections {
        target: inx
        function onOpenPath(paths) {
            for (var index in paths) {
                currentBrowser.openFolder(paths[index])
                break
            }
            isOpenWithUrl = true
        }
    }

    function openTab(path) {
        if (path) {
            const component = Qt.createComponent(
                                "qrc:/widgets/views/BrowserLayout.qml")

            if (component.status === Component.Ready) {
                const object = component.createObject(tabsObjectModel, {
                                                          "path": path
                                                      })
                tabsObjectModel.append(object)
                _browserList.currentIndex = tabsObjectModel.count - 1
            }
        }
    }

    function getCurrentTitle(path) {
        path = path.toString()
        if (path == leftMenuData.getRootPath())
        {
            return i18n("On My Pad")
        } else if (path == leftMenuData.getTrashPath())
        {
            return i18n("Trash")
        } else if (path == "qrc:/widgets/views/tag0") {
            return tagsSettings.tag0
        } else if (path == "qrc:/widgets/views/tag1") {
            return tagsSettings.tag1
        } else if (path == "qrc:/widgets/views/tag2") {
            return tagsSettings.tag2
        } else if (path == "qrc:/widgets/views/tag3") {
            return tagsSettings.tag3
        } else if (path == "qrc:/widgets/views/tag4") {
            return tagsSettings.tag4
        } else if (path == "qrc:/widgets/views/tag5") {
            return tagsSettings.tag5
        } else if (path == "qrc:/widgets/views/tag6") {
            return tagsSettings.tag6
        } else if (path == "qrc:/widgets/views/tag7") {
            return tagsSettings.tag7
        } else if (path == "qrc:/widgets/views/Recents") {
            return i18n("Recents")
        } else if (path == "qrc:/widgets/views/Document") {
            return i18n("Document")
        } else if (path == "qrc:/widgets/views/Picture") {
            return i18n("Picture")
        } else if (path == "qrc:/widgets/views/Video") {
            return i18n("Video")
        } else if (path == "qrc:/widgets/views/Music") {
            return i18n("Music")
        } else {
            var index = path.lastIndexOf("/")
            if (index == -1) {
                return unescape(
                            path)
            } else {
                return unescape(path.substring(index + 1))
            }
        }
    }

    //add by huan lele
    function openWith(item)
    {
        var services = Maui.KDE.services(item.path)
        if (services.length <= 0) {
            showToast(i18n("Sorry, opening this file is not supported at present."))
            return
        } else {
            if (item.mime.indexOf("video") != -1 || Maui.FM.checkFileType(
                        Maui.FMList.IMAGE, item.mime)
                    || (item.mime.indexOf("audio") != -1))
            {
                if (services.length == 1) {
                    Maui.KDE.openWithApp(services[0].actionArgument,
                                         [item.path])
                    return
                } else {
                    _openWithDialog.model.clear()
                    _openWithDialog.urls = [item.path]
                    for (var i in services) {
                        _openWithDialog.model.append(services[i])
                    }
                    _openWithDialog.open()
                }
            } else {
                if (services.length == 1) {
                    if (isAppOpenning) {
                        return
                    }
                    Maui.KDE.openWithApp(services[0].actionArgument,
                                         [item.path])
                    isAppOpenning = true
                    if (openTimer.running) {
                        openTimer.restart()
                    } else {
                        openTimer.start()
                    }
                    return
                } else {
                    _openWithDialog.model.clear()
                    _openWithDialog.urls = [item.path]
                    for (var i in services) {
                        _openWithDialog.model.append(services[i])
                    }
                    _openWithDialog.open()
                }
            }
        }
    }
    //end add

    function addToSelection(item, index) {
        if (_selectionBar == null || item.path.startsWith("tags://")
                || item.path.startsWith("applications://")) {
            return
        }

        if (_selectionBar.contains(item.nickname)) {
            _selectionBar.removeAtUri(item.nickname)
            return
        }

        _selectionBar.append(item.nickname, item)
    }

    function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
    {
        if (_selectionBar == null) {
            return
        }
        selectIndexes([...Array(root.currentBrowser.currentFMList.count).keys()])
    }

    function selectIndexes(indexes) {
        if (_selectionBar == null) {
            return
        }
        for (var i in indexes)
            addToSelection(root.currentBrowser.currentFMModel.get(indexes[i]),
                           i)
    }

    function getIcon(model) {
        var imageSource = ""
        var modelType = model.suffix
        var modelMimeType = model.mime
        var isTrash = model.path.indexOf(".local/share/Trash/files") !== -1
        if (modelMimeType === "inode/directory") {
            imageSource = "qrc:/assets/folder_icon.svg"
        } else if (modelMimeType.indexOf("image") !== -1) {
            var isImageCopying = Index.ProcessModel.isCopyingFile(model.path.toString())
            if (isImageCopying) {
                return ""
            }
            imageSource = leftMenuData.getVideoPreview(model.path)
        } else if (modelMimeType.indexOf("audio") !== -1) {
            imageSource = "qrc:/assets/music.svg"
        } else if (modelMimeType.indexOf("video") !== -1) {
            var isVideoCopying = Index.ProcessModel.isCopyingFile(model.path.toString())
            if (isVideoCopying) {
                return ""
            }
            imageSource = leftMenuData.getVideoPreview(model.path)
        } else if (modelMimeType.indexOf("text") !== -1) {
            imageSource = "qrc:/assets/text.svg"
        } else if (modelType.indexOf("doc") !== -1) {
            imageSource = "qrc:/assets/word.svg"
        } else if (modelType.indexOf("ppt") !== -1) {
            imageSource = "qrc:/assets/ppt.svg"
        } else if (modelType.indexOf("xls") !== -1) {
            imageSource = "qrc:/assets/excel.svg"
        } else if (modelType.indexOf("pdf") !== -1) {
            imageSource = "qrc:/assets/pdf.svg"
        } else if (modelType.indexOf("7zip") !== -1 || modelMimeType.indexOf(
                       "7zip") !== -1) {
            imageSource = "qrc:/assets/7zip.svg"
        } else if (modelType.indexOf("zip") !== -1 || modelMimeType.indexOf(
                       "zip") !== -1) {
            imageSource = "qrc:/assets/zip.svg"
        } else if (modelType.indexOf("rar") !== -1 || modelMimeType.indexOf(
                       "rar") !== -1) {
            imageSource = "qrc:/assets/rar.svg"
        } else if (modelType.indexOf("tar") !== -1 || modelMimeType.indexOf(
                       "tar") !== -1) {
            imageSource = "qrc:/assets/tar.svg"
        } else {
            imageSource = "qrc:/assets/default.svg"
        }
        return imageSource
    }

    function getTagSource(model) {
        var tagIndex = leftMenuData.isTagFile(model.path)
        var tagSource = ""
        switch (tagIndex) {
        case 0:
            tagSource = "qrc:/assets/leftmenu/tag0.png"
            break
        case 1:
            tagSource = "qrc:/assets/leftmenu/tag1.png"
            break
        case 2:
            tagSource = "qrc:/assets/leftmenu/tag2.png"
            break
        case 3:
            tagSource = "qrc:/assets/leftmenu/tag3.png"
            break
        case 4:
            tagSource = "qrc:/assets/leftmenu/tag4.png"
            break
        case 5:
            tagSource = "qrc:/assets/leftmenu/tag5.png"
            break
        case 6:
            tagSource = "qrc:/assets/leftmenu/tag6.png"
            break
        case 7:
            tagSource = "qrc:/assets/leftmenu/tag7.png"
            break
        default:
            tagSource = ""
        }
        return tagSource
    }

    function playVideo(item) {
        var startIndex = 0
        var videoModel = {
            "mimeType": item.mime,
            "mediaType": 1,
            "previewurl": "",
            "imageTime": "",
            "mediaurl": item.path
        }
        previewimagemodel.append(videoModel)
        preiviewLoader.currentIndex = startIndex
        preiviewLoader.imgModel = previewimagemodel
        preiviewLoader.title = ""
        preiviewLoader.active = true
    }

    function showImageViewer(item) {
        var startIndex = 0
        var count = -1
        for (var i = 0; i < root.currentBrowser.currentFMList.count; i++) {
            var normalModel = root.currentBrowser.currentFMModel.get(i)
            if (Maui.FM.checkFileType(
                        Maui.FMList.IMAGE,
                        normalModel.mime))
            {
                var imageModel = {
                    "mimeType": normalModel.mime,
                    "mediaType": 0,
                    "previewurl": normalModel.path,
                    "imageTime": "",
                    "mediaUrl": ""
                }
                previewimagemodel.append(imageModel)
                count++
                if (normalModel.path == item.path) {
                    startIndex = count
                }
            }
        }

        preiviewLoader.currentIndex = startIndex
        preiviewLoader.imgModel = previewimagemodel
        preiviewLoader.title = ""
        preiviewLoader.active = true
    }

    function showToast(tips) {
        toast.text = tips
        toast.show(tips, 1500)
    }

    function clearSelectionBar() {
        _selectionBar.clear()
    }

    property Action copyAction: Action {
        shortcut: "Ctrl+C"

        onTriggered: {
            if (_selectionBar.items.length > 0) {
                currentBrowser.copy(_selectionBar.uris)
                showToast(_selectionBar.items.length + i18n(
                              " files have been copied"))
                clearSelectionBar()
                selectionMode = false
            }
        }
    }

    property Action pasteAction: Action {
        shortcut: "Ctrl+V"

        onTriggered: {
            const data = Maui.Handy.getClipboard()
            const urls = data.urls
            var destUrl = String(root.currentBrowser.currentFMList.path)
            console.log(" Ctrl V url " + root.currentBrowser.currentFMList.path)
            if (!urls || destUrl.startsWith("qrc:/")) {
                return
            }
            if (data.cut) {
                Index.ProcessModel.insertCutJob(urls, root.currentBrowser.currentFMList.path)
                control.currentFMList.updateTag(urls)
            } else {
                Index.ProcessModel.insertCopyJob(urls,  root.currentBrowser.currentFMList.path)
            }
        }
    }

}
