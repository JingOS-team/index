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
    property var editTagMenuIndex: -1
    property var currentNodeIndex: -1

    id: control
    width: 350 * appScaleSize
    height: (162 - 16) * appScaleSize
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    background: Kirigami.JBlurBackground {
        id: blurBk
        anchors.fill: parent
        sourceItem: control.parent
        backgroundColor: Kirigami.JTheme.floatBackground
    }

    Kirigami.JIconButton {
        id: backIcon
        width: 22 * appScaleSize
        height: 22 * appScaleSize
        source: "qrc:/assets/back_arrow.png"

        anchors.left: parent.left
        anchors.leftMargin: 20 * appScaleSize
        anchors.top: parent.top
        anchors.topMargin: 16 * appScaleSize

        onClicked: {
            close()
            root_tagMenu.show(editTagMenuIndex)
        }
    }

    Item {
        width: 150 * appScaleSize
        height: 22 * appScaleSize
        anchors {
            top: parent.top
            topMargin: 16 * appScaleSize
            left: backIcon.right
            leftMargin: 8 * appScaleSize
        }

        Text {
            id: tagsText
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Edit Tags")
            font.pixelSize: 17 * appFontSize
            color: Kirigami.JTheme.minorForeground
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Kirigami.JTextField {
        id: tagText
        width: 300 * appScaleSize
        height: 30 * appScaleSize
        anchors {
            left: parent.left
            leftMargin: 25 * appScaleSize
            right: parent.right
            rightMargin: 25 * appScaleSize
            top: backIcon.bottom
            topMargin: 16 * appScaleSize
        }
        text: "test"
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: 11 * appFontSize
        color: Kirigami.JTheme.minorForeground
        maximumLength: 16
        onEditingFinished: {
            checkEdit()
        }
    }

    ListView {
        id: tagsListView
        clip: true
        width: (30 * 8 + 9 * 7) * appScaleSize
        height: 30 * appScaleSize
        orientation: ListView.Horizontal
        spacing: 9 * appScaleSize
        anchors {
            top: tagText.bottom
            topMargin: 16 * appScaleSize
            left: parent.left
            leftMargin: 20 * appScaleSize
            right: parent.right
            rightMargin: 20 * appScaleSize
        }
        model: ListModel {
            id: tagsModel
        }
        delegate: tagsDelegate
    }

    Component {
        id: tagsDelegate

        Image {
            id: tagImage
            width: 30 * appScaleSize
            height: 30 * appScaleSize
            source: isSelect ? selectIcon : tagIcon

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    if (currentNodeIndex != index) {
                        var node = tagsModel.get(currentNodeIndex)
                        if (node.tagName != tagText.text) {
                            node.tagName = tagText.text
                            checkEdit()
                        }

                        if (tagText.text == "") {
                            return
                        }

                        for (var i = 0; i < tagsModel.count; ++i) {
                            var node = tagsModel.get(i)
                            if (i == index) {
                                node.isSelect = true
                                tagText.text = node.tagName
                                currentNodeIndex = i
                            } else {
                                node.isSelect = false
                            }
                        }
                    }
                }
            }
        }
    }

    function checkEdit() {
        if (tagText.text == "") {
            showToast(i18n("The tag name cannot empty."))
            return
        }

        var needFreshTagsMenu = false
        switch (currentNodeIndex) {
        case 0:
            if (tagsSettings.tag0 != tagText.text) {
                tagsSettings.tag0 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 1:
            if (tagsSettings.tag1 != tagText.text) {
                tagsSettings.tag1 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 2:
            if (tagsSettings.tag2 != tagText.text) {
                tagsSettings.tag2 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 3:
            if (tagsSettings.tag3 != tagText.text) {
                tagsSettings.tag3 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 4:
            if (tagsSettings.tag4 != tagText.text) {
                tagsSettings.tag4 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 5:
            if (tagsSettings.tag5 != tagText.text) {
                tagsSettings.tag5 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 6:
            if (tagsSettings.tag6 != tagText.text) {
                tagsSettings.tag6 = tagText.text
                needFreshTagsMenu = true
            }
            break
        case 7:
            if (tagsSettings.tag7 != tagText.text) {
                tagsSettings.tag7 = tagText.text
                needFreshTagsMenu = true
            }
            break
            // default: tagSource = "";
        }
        if (needFreshTagsMenu) {
            root.leftMenu.refreshTagsMenu()
        }
    }

    function show(index) {
        tagsModel.clear()
        tagsModel.append({
                             "tagName": tagsSettings.tag0,
                             "tagIcon": "qrc:/assets/tagedit/tag0.png",
                             "selectIcon": "qrc:/assets/tagedit/tag0_select.png",
                             "isSelect": true
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag1,
                             "tagIcon": "qrc:/assets/tagedit/tag1.png",
                             "selectIcon": "qrc:/assets/tagedit/tag1_select.png",
                             "isSelect": false
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag2,
                             "tagIcon": "qrc:/assets/tagedit/tag2.png",
                             "selectIcon": "qrc:/assets/tagedit/tag2_select.png",
                             "isSelect": false
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag3,
                             "tagIcon": "qrc:/assets/tagedit/tag3.png",
                             "selectIcon": "qrc:/assets/tagedit/tag3_select.png",
                             "isSelect": false
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag4,
                             "tagIcon": "qrc:/assets/tagedit/tag4.png",
                             "selectIcon": "qrc:/assets/tagedit/tag4_select.png",
                             "isSelect": false
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag5,
                             "tagIcon": "qrc:/assets/tagedit/tag5.png",
                             "selectIcon": "qrc:/assets/tagedit/tag5_select.png",
                             "isSelect": false
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag6,
                             "tagIcon": "qrc:/assets/tagedit/tag6.png",
                             "selectIcon": "qrc:/assets/tagedit/tag6_select.png",
                             "isSelect": false
                         })
        tagsModel.append({
                             "tagName": tagsSettings.tag7,
                             "tagIcon": "qrc:/assets/tagedit/tag7.png",
                             "selectIcon": "qrc:/assets/tagedit/tag7_select.png",
                             "isSelect": false
                         })

        tagText.text = tagsSettings.tag0
        currentNodeIndex = 0
        tagText.forceActiveFocus()

        control.editTagMenuIndex = index
        item = root.currentBrowser.currentFMModel.get(index)
        control.x = (wholeScreen.width - control.width) / 2
        control.y = (wholeScreen.height - control.height) / 2
        open()
    }
}
