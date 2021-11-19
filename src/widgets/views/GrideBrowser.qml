

/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *             2021 Zhang He Gang <zhanghegang@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.0


/**
 * GridView
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
Item {
    id: control
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    focus: true

    implicitHeight: contentHeight + margins * 2
    implicitWidth: contentWidth + margins * 2


    /**
      * itemSize : int
      */
    property int itemSize: 0


    /**
      * itemWidth : int
      */
    property int itemWidth: itemSize


    /**
      * itemHeight : int
      */
    property int itemHeight: itemSize


    /**
      * cellWidth : int
      */
    property alias cellWidth: controlView.cellWidth


    /**
      * cellHeight : int
      */
    property alias cellHeight: controlView.cellHeight


    /**
      * model : var
      */
    property alias model: controlView.model


    /**
      * delegate : Component
      */
    property alias delegate: controlView.delegate


    /**
      * contentY : int
      */
    property alias contentY: controlView.contentY


    /**
      * currentIndex : int
      */
    property alias currentIndex: controlView.currentIndex


    /**
      * count : int
      */
    property alias count: controlView.count


    /**
      * cacheBuffer : int
      */
    property alias cacheBuffer: controlView.cacheBuffer


    /**
      * flickable : Flickable
      */
    property alias flickable: controlView


    /**
      * contentHeight : int
      */
    property alias contentHeight: controlView.contentHeight


    /**
      * contentWidth : int
      */
    property alias contentWidth: controlView.contentWidth


    /**
      * topMargin : int
      */
    property int topMargin: margins


    /**
      * bottomMargin : int
      */
    property int bottomMargin: margins


    /**
      * rightMargin : int
      */
    property int rightMargin: margins


    /**
      * leftMargin : int
      */
    property int leftMargin: margins


    /**
      * margins : int
      */
    property int margins: (Kirigami.Settings.isMobile ? 0 : Maui.Style.space.medium)


    /**
      * adaptContent : bool
      */
    property bool adaptContent: true


    /**
      * enableLassoSelection : bool
      */
    property bool enableLassoSelection: false


    /**
      * selectionMode : bool
      */
    property bool selectionMode: false


    /**
      * itemsSelected :
      */
    signal itemsSelected(var indexes)


    /**
      * areaClicked :
      */
    signal areaClicked(var mouse)


    /**
      * areaRightClicked :
      */
    signal areaRightClicked(var mouse)


    /**
      * keyPress :
      */
    signal keyPress(var event)

    GridView {
        id: controlView

        property var selectedIndexes: []

        anchors.fill: parent

        anchors.left: parent.left
        anchors.leftMargin: 45 * appScaleSize
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 * appScaleSize
        rightMargin: 45 * appScaleSize
        property int size_
        Component.onCompleted: {
            controlView.size_ = control.itemWidth
        }
        flow: GridView.FlowLeftToRight
        focus: true
        cellWidth: control.itemWidth
        cellHeight: control.itemHeight
        boundsBehavior: !Kirigami.Settings.isMobile ? Flickable.StopAtBounds : Flickable.OvershootBounds

        cacheBuffer: controlView.height * 1.5

        //anima start
        // populate: Transition{
        // NumberAnimation{
        //     property: "opacity"
        //     from: 0
        //     to: 1.0
        //     duration: 1000
        // }
        // NumberAnimation { properties: "x,y"; duration: 1000 }
        // }//populate Transition is end

        // add:Transition {
        //     ParallelAnimation{
        //         NumberAnimation{
        //             property: "opacity"
        //             from: 0
        //             to : 1.0
        //             duration: 1000
        //         }

        //         NumberAnimation{
        //             property: "y"
        //             from: 0
        //             duration:  1000
        //         }
        //     }
        // }// add transition is end

        // displaced: Transition {
        //     SpringAnimation{
        //         property: "y"
        //         spring: 3
        //         damping: 0.1
        //         epsilon: 0.25
        //     }
        // }

        // remove: Transition {
        //     SequentialAnimation{
        //         NumberAnimation{
        //             property: "y"
        //             to: 0
        //             duration: 600
        //         }

        //         NumberAnimation{
        //             property: "opacity"
        //             to:0
        //             duration: 600
        //         }
        //     }
        // }//remove Transition is end
        // anima end
        MouseArea {
            id: _mouseArea
            z: -1
            enabled: true
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.RightButton | Qt.LeftButton

            onClicked: {
                control.areaClicked(mouse)
                control.forceActiveFocus()

                if (mouse.button === Qt.RightButton) {
                    var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                    menuX = realMap.x
                    menuY = realMap.y
                    control.areaRightClicked(mouse)
                    return
                }
            }

            onWheel: {
                if (wheel.modifiers & Qt.ControlModifier) {
                    if (wheel.angleDelta.y != 0) {
                        var factor = 1 + wheel.angleDelta.y / 600
                        control.resizeContent(factor)
                    }
                } else
                    wheel.accepted = false
            }

            onPositionChanged: {

            }

            onPressed: {

            }

            onPressAndHold: {
                if (mouse.source !== Qt.MouseEventNotSynthesized
                        && control.enableLassoSelection
                        && /*!selectLayer.visible*/ true) {
                    mouse.accepted = true
                } else {
                    mouse.accepted = false
                }
                var realMap = mapToItem(wholeScreen, mouse.x, mouse.y)
                menuX = realMap.x
                menuY = realMap.y
                control.areaRightClicked(mouse)
            }

            onReleased: {
                if (mouse.button !== Qt.LeftButton
                        || !control.enableLassoSelection
                        || /*!selectLayer.visible*/ true) {
                    mouse.accepted = false
                    return
                }
            }
        }

        ScrollBar.vertical: Kirigami.JVerticalScrollBar {}
    }


    /**
      *
      */
    function resizeContent(factor) {
        const newSize = control.itemSize * factor

        if (newSize > control.itemSize) {
            control.itemSize = newSize
        } else {
            if (newSize >= Maui.Style.iconSizes.small)
                control.itemSize = newSize
        }
    }


    /**
      *
      */
    function adaptGrid() {
        var fullWidth = controlView.width
        var realAmount = parseInt(fullWidth / controlView.size_, 10)
        var amount = parseInt(fullWidth / control.cellWidth, 10)

        var leftSpace = parseInt(fullWidth - (realAmount * controlView.size_),
                                 10)
        var size = Math.min(amount, realAmount)
                >= control.count ? Math.max(control.cellWidth,
                                            control.itemSize) : parseInt(
                                       (controlView.size_) + (parseInt(
                                                                  leftSpace / realAmount,
                                                                  10)), 10)

        control.cellWidth = size
    }
}
