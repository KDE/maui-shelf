import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control

    property string currentPath : ""
    property bool currentPathFav : false
    property var currentItem : ({})

    padding: 0

    property alias viewer : _viewerLoader.item

    Maui.NewDialog
    {
        id: _newBookmarkDialog

        title: qsTr("New Bookmark...")
        rejectButton.visible: false
        textEntry.text: "Bookmark #"
       message: qsTr("Save new bookmark as")
       acceptButton.text: qsTr("Save")
        onAccepted:
        {
            console.log(viewer.currentPage)
            libraryView.list.bookmark(libraryView.currentIndex, viewer.currentPage)
        }
    }

    headBar.leftContent:[
        ToolButton
        {
            icon.name: "love"
            icon.color: currentPathFav ? "#f84172" : control.colorScheme.textColor
            onClicked:
            {
                if(libraryView.list.fav(libraryView.currentIndex, !currentPathFav))
                currentPathFav= !currentPathFav
            }
        },

        ToolButton
        {
            icon.name:  "bookmark-new"
            onClicked:
            {
                _newBookmarkDialog.open()
            }
        }
    ]

    headBar.rightContent: [

        ToolButton
        {
            icon.name: "view-fullscreen"
        },
        ToolButton
        {
            icon.name:  "edit-find"
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

    Component
    {
        id: _epubComponent

        Viewer_EPUB
        {
            anchors.fill: parent
        }
    }


    function open(item)
    {
        control.currentItem = item
        control.currentPath = currentItem.url
        control.currentPathFav = currentItem.fav == "1"

        console.log("openinf file:", control.currentPath)
        if(Maui.FM.fileExists(  control.currentPath))
        {
            currentView = views.viewer
            //            _listView.currentItem.page = 0
            if(control.currentPath.endsWith(".pdf"))
                _viewerLoader.sourceComponent = _pdfComponent
            else if(control.currentPath.endsWith(".txt"))
                _viewerLoader.sourceComponent = _txtComponent
            else if(control.currentPath.endsWith(".epub"))
                _viewerLoader.sourceComponent = _epubComponent
            else return;

            viewer.open(control.currentPath)

        }
    }
}
