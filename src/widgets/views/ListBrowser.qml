

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


/**
 * ListBrowser
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

    implicitHeight: contentHeight + margins * 2
    implicitWidth: contentWidth + margins * 2


    /**
      * model : var
      */
    property alias model: _listView.model


    /**
      * delegate : Component
      */
    property alias delegate: _listView.delegate


    /**
      * section : ListView.section
      */
    property alias section: _listView.section


    /**
      * contentY : int
      */
    property alias contentY: _listView.contentY


    /**
      * currentIndex : int
      */
    property alias currentIndex: _listView.currentIndex


    /**
      * currentItem : Item
      */
    property alias currentItem: _listView.currentItem


    /**
      * count : int
      */
    property alias count: _listView.count


    /**
      * cacheBuffer : int
      */
    property alias cacheBuffer: _listView.cacheBuffer


    /**
      * orientation : ListView.orientation
      */
    property alias orientation: _listView.orientation


    /**
      * snapMode : ListView.snapMode
      */
    property alias snapMode: _listView.snapMode


    /**
      * spacing : int
      */
    property alias spacing: _listView.spacing


    /**
      * flickable : Flickable
      */
    property alias flickable: _listView


    /**
      * scrollView : ScrollView
      */
    // property alias scrollView : _scrollView


    /**
      * contentHeight : int
      */
    property alias contentHeight: _listView.contentHeight


    /**
      * contentWidth : int
      */
    property alias contentWidth: _listView.contentWidth


    /**
      * atYEnd : bool
      */
    property alias atYEnd: _listView.atYEnd


    /**
      * atYBeginning : bool
      */
    property alias atYBeginning: _listView.atYBeginning


    /**
      * margins : int
      */
    property int margins: control.enableLassoSelection ? Maui.Style.space.medium : Maui.Style.space.small


    /**
      * topMargin : int
      */
    property int topMargin: margins


    /**
      * bottomMargin : int
      */
    property int bottomMargin: margins


    /**
      * bottomMargin : int
      */
    property int rightMargin: margins


    /**
      * leftMargin : int
      */
    property int leftMargin: margins


    /**
      * leftMargin : int
      */
    property int verticalScrollBarPolicy: ScrollBar.AlwaysOff //ScrollBar.AlwaysOn


    /**
      * horizontalScrollBarPolicy : ScrollBar.policy
      */
    property int horizontalScrollBarPolicy: _listView.orientation === Qt.Horizontal ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff //ScrollBar.AlwaysOn


    /**
      * holder : Holder
      */
    // property alias holder : _holder


    /**
      * enableLassoSelection : bool
      */
    property bool enableLassoSelection: false


    /**
      * selectionMode : bool
      */
    property bool selectionMode: false


    /**
      * lassoRec : Rectangle
      */
    property string backColor: "transparent"


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

    Kirigami.Theme.colorSet: Kirigami.Theme.View

    Keys.enabled: true
    Keys.forwardTo: _listView

    Rectangle {
        anchors.fill: parent
        color: backColor
    }

    ListView {
        id: _listView
        property var selectedIndexes: []

        anchors.fill: parent

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 * appScaleSize
        focus: true
        cacheBuffer: _listView.height * 1.5
        spacing: 20 * appScaleSize
        boundsBehavior: !Kirigami.Settings.isMobile ? Flickable.StopAtBounds : Flickable.OvershootBounds

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
}
