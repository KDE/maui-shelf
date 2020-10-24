import QtQuick 2.13
import QtQuick.Controls 2.13

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control

    property string currentPath : ""
    property bool currentPathFav : false
    property var currentItem : ({})
    property alias currentViewer: _viewerLoader.item

    title: currentViewer ? currentViewer.title : ""
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

    Maui.Holder
    {
        visible: !viewer
        emoji: "qrc:/assets/draw-watercolor.svg"
        title : i18n("Nothing here")
        body: i18n("Drop or open a document to view.")
        emojiSize: Maui.Style.iconSizes.huge
    }

    floatingHeader: true
    autoHideHeader: true
    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: false
        expanded: true
        checkable: true

        Action
        {
            icon.name: "love"
            icon.color: currentPathFav ? "#f84172" : Kirigami.Theme.textColor
            onTriggered:
            {
                if(libraryView.list.fav(libraryView.currentIndex, !currentPathFav))
                    currentPathFav= !currentPathFav
            }
        }

        Action
        {
            icon.name:  "bookmark-new"
            onTriggered:
            {
                _newBookmarkDialog.open()
            }
        }
    }


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
        control.currentPath = currentItem.path
        control.currentPathFav = currentItem.fav == "1"

        console.log("openinf file:", control.currentPath)
        if(Maui.FM.fileExists(  control.currentPath))
        {
            swipeView.currentIndex = views.viewer
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
