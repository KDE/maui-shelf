import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

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

    Maui.Doodle
    {
        id: doodle
        sourceItem: currentViewer.currentItem
        hint: 1
    }

    Maui.Holder
    {
        anchors.fill: parent
        visible: !viewer
        emoji: "qrc:/assets/draw-watercolor.svg"
        title : i18n("Nothing here")
        body: i18n("Drop or open a document to view.")
        emojiSize: Maui.Style.iconSizes.huge
    }

    floatingHeader: true
    autoHideHeader: true
    headBar.forceCenterMiddleContent: root.isWide

    headBar.farLeftContent: ToolButton
    {
        icon.name: "go-previous"
        onClicked: _stackView.pop()
    }

    headBar.rightContent: [

        ToolButton
        {
            icon.name: "love"
            icon.color: currentPathFav ? "#f84172" : Kirigami.Theme.textColor
            onClicked:
            {
                if(FB.Tagging.fav(control.currentPath))
                    currentPathFav= FB.Tagging.isFav(control.currentPath)
            }
        },

        ToolButton
        {
            icon.name: "document-share"
            onClicked:
            {
                Maui.Platform.shareFiles([control.currentPath])
            }
        },

        Maui.ToolButtonMenu
        {
            icon.name: "overflow-menu"

            MenuItem
            {
                icon.name: "tool_pen"
                text: i18n("Doodle")

                onTriggered: doodle.open()
            }

            MenuSeparator {}

            MenuItem
            {
                icon.name: "view-right-new"
                text: i18n("Browse Horizontally")

                checkable: true
                checked:  currentViewer.orientation === ListView.Horizontal
                onClicked:
                {
                    currentViewer.orientation = currentViewer.orientation === ListView.Horizontal ? ListView.Vertical : ListView.Horizontal
                }
            }

            MenuItem
            {
                icon.name:  "zoom-fit-width"
                text: i18n("Fill")
                checkable: true
                checked: currentViewer.fitWidth
                onTriggered:
                {
                    currentViewer.fitWidth= !currentViewer.fitWidth
                }
            }

            MenuItem
            {
                text: i18n("Fullscreen")
                checkable: true
                checked: root.visibility === Window.FullScreen
                icon.name: "view-fullscreen"
                onTriggered: root.visibility = (root.visibility === Window.FullScreen  ? Window.Windowed : Window.FullScreen)
            }
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
        if(FB.FM.fileExists(  control.currentPath))
        {
            _stackView.push(viewerView)
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
