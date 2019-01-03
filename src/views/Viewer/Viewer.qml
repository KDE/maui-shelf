import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control

    property string currentPath : ""
    headBarTitle: poppler.info.title
    height: 500
    width: 200
    headBarExit: false

    property alias viewer : _viewerLoader.item

    headBar.leftContent:[
        Maui.ToolButton
        {
            iconName: "love"
        },

        Maui.ToolButton
        {
            iconName:  "bookmark-new"
        },

        Maui.ToolButton
        {
            iconName:  "zoom-fit-width"
        }
    ]

    headBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "zoom-original"
        },



        Maui.ToolButton
        {
            iconName:  "zoom-fit-height"
        },

        Maui.ToolButton
        {
            iconName:  "zoom-fit-width"
        },

        Maui.ToolButton
        {
            iconName: "view-fullscreen"
        },
        Maui.ToolButton
        {
            iconName:  "edit-find"
        }
    ]



    Loader
    {
        id: _viewerLoader
        anchors.fill: parent
    }

    Component
    {
        id: _pdfComponent

        Viewer_PDF
        {
            anchors.fill: parent
        }
    }

    Component
    {
        id: _txtComponent

        Viewer_TXT
        {
            anchors.fill: parent
        }
    }


    function open(filePath)
    {
        console.log("trying to open", filePath)
        if(Maui.FM.fileExists(filePath))
        {
            currentView = views.viewer
            //            _listView.currentItem.page = 0
            control.currentPath = filePath
            if(filePath.endsWith(".pdf"))
                _viewerLoader.sourceComponent = _pdfComponent
            else
                _viewerLoader.sourceComponent = _txtComponent

            viewer.open(control.currentPath)

        }
    }
}
