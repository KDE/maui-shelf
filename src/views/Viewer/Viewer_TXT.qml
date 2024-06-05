import QtQuick 
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.texteditor as TE

TE.TextEditor
{
    id: _editor
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
