/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.maui.index 1.0 as Index
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.0

Kirigami.JArrowPopup {

    width: 314 * appScaleSize
    height: contentItem.height + 8 * appScaleSize
    blurBackground.arrowX: width * 0.3 + 11 * appScaleSize
    blurBackground.arrowWidth: 16 * appScaleSize
    blurBackground.arrowHeight: 11 * appScaleSize
    blurBackground.arrowPos: Kirigami.JRoundRectangle.ARROW_TOP
    leftPadding: 0
    rightPadding: 0
    modal: true
    Overlay.modal: Rectangle {
        color: "#00000000"
    }

    contentItem: Rectangle {
        id: processView
        width: 314 * appScaleSize
        height: processListView.height
        color: "#00000000"
        clip: true
        ListView {
            id: processListView
            width: parent.width
            height: count > 5 ? 5 * 45 * appScaleSize : count * 45 * appScaleSize
            model: Index.ProcessModel
            delegate: processItemDelegate
            clip: true
            ScrollBar.vertical: Kirigami.JVerticalScrollBar {
            }
        }

        Component {
            id: processItemDelegate
            Item {
                width: processListView.width
                height: 45 * appScaleSize
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 20 * appScaleSize
                    height: parent.height
                    color: "#00000000"

                    Rectangle {
                        id: spinnerProgress
                        property real progress: model.job.percent / 100
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18 * appScaleSize
                        height: 18 * appScaleSize
                        border.width: 2 * appScaleSize
                        opacity: 0.2
                        border.color: Kirigami.JTheme.buttonForeground
                        radius: 18 * appScaleSize
                        color: "transparent"
                        MouseArea {
                            anchors.fill: parent
                            enabled: oprationIcon.visible
                            onClicked: {
                                var result
                                if (model.isSuspended) {
                                    result = Index.ProcessModel.resumeJob(model.job)
                                } else {
                                    result = Index.ProcessModel.suspendJob(
                                                model.job)
                                }
                                if (result) {
                                    oprationIcon.source = model.isSuspended ? "qrc:/assets/suspend.svg" : "qrc:/assets/resume.svg"
                                }
                            }
                        }
                    }
                    Image {
                        id: oprationIcon
                        anchors.centerIn: spinnerProgress
                        width: 11 * appScaleSize
                        height: 11 * appScaleSize
                        source: model.isSuspended ? "qrc:/assets/suspend.svg" : "qrc:/assets/resume.svg"
                        visible: false
                    }
                    ConicalGradient {
                        source: spinnerProgress
                        visible: spinnerProgress.visible
                        anchors.fill: spinnerProgress
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00
                                color: Kirigami.JTheme.highlightColor
                            }
                            GradientStop {
                                position: spinnerProgress.progress
                                color: Kirigami.JTheme.highlightColor
                            }
                            GradientStop {
                                position: spinnerProgress.progress + 0.01
                                color: "transparent"
                            }
                            GradientStop {
                                position: 1.00
                                color: "transparent"
                            }
                        }
                    }

                    Column {
                        id: contentText
                        anchors {
                            left: spinnerProgress.right
                            leftMargin: 12 * appScaleSize
                            verticalCenter: spinnerProgress.verticalCenter
                        }
                        spacing: 2 * appScaleSize
                        Text {
                            id: copyTitle
                            width: 159 * appScaleSize
                            height: contentHeight
                            text: i18n("Copying new folder")
                            font.pixelSize: 12 * appFontSize
                            color: Kirigami.JTheme.majorForeground
                            elide: Text.ElideRight
                            clip: true
                        }
                        Text {
                            id: copySize
                            width: 159 * appScaleSize
                            height: contentHeight
                            text: model.totalFiles + i18n("items") + " " + i18n(
                                      "in total ") + model.totalSize
                            font.pixelSize: 9 * appFontSize
                            color: Kirigami.JTheme.minorForeground
                            elide: Text.ElideRight
                            clip: true
                        }
                    }

                    Rectangle {
                        id: cancelButton
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        width: 50 * appScaleSize
                        height: 16 * appScaleSize
                        border.width: 1 * appScaleSize
                        border.color: Kirigami.JTheme.buttonBorder
                        radius: 3 * appScaleSize
                        color: Kirigami.JTheme.buttonBackground
                        Text {
                            id: cancelText
                            anchors {
                                centerIn: parent
                            }
                            text: i18n("Cancel")
                            font.pixelSize: 12 * appFontSize
                            color: Kirigami.JTheme.majorForeground
                            elide: Text.ElideRight
                            clip: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var result = Index.ProcessModel.killJob(model.job)
                                console.log("killRect:" + result)
                            }
                        }
                    }

                    Rectangle {
                        id: divRect
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 1 * appScaleSize
                        visible: index === processListView.count - 1 ? false : true
                        color: Kirigami.JTheme.dividerForeground
                    }
                }
            }
        }
    }
}
