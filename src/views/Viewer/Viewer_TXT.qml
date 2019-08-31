import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.mauikit 1.0 as Maui

Maui.Editor
{
    id: _editor
    headBar.visible: false
    property int currentPage : body.cursorPosition

    body.readOnly: true    

//    footBar.middleContent:[

//        ToolButton
//        {
//            icon.name:  "zoom-in"
//            onClicked:
//            {
//                body.font.pointSize = body.font.pointSize + fontSizes.small
//            }
//        },

//        ToolButton
//        {
//            icon.name:  "zoom-out"
//            onClicked:
//            {
//                body.font.pointSize = body.font.pointSize - fontSizes.small

//            }
//        }
//    ]

    function open(filePath)
    {
        _editor.document.load("file://"+filePath)
    }
}
