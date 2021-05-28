import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
 
 
Item {
 
    Popup {
        id: popup
        width: backgroundWidth
        height: backgroundHeight;
        modal: true
        //三角形区域
        Rectangle {
            id: bar
            visible: popup.visible
            rotation: 45
            width: 20; 
            height: 20
            color: barColor
            anchors.bottom: parent.top
            anchors.bottomMargin: -width / 2
            anchors.right: parent.right
            anchors.rightMargin: parent.width / 3
            radius: 4
        }
        background: Rectangle {
            id: background
            color: barColor
            radius: 4
            anchors.left: parent.left;
            anchors.leftMargin: 12
            border.color: borderColor
            border.width: borderWidth
        }
    }
 
    function show1() {
        //popup.x = (root.width - popup.width) / 2
        //popup.y = root.height + verticalOffset
        popup.x = 106//86
        popup.y =  60
        popupVisible = true
    }

    function show(parent = control, x, y)
    {
        // popup(parent, x, y)
        popup.x = parent.x
        popup.y = parent.y
        popupVisible = true
    }

 
    function hide() {
        popupVisible = false
    }
}