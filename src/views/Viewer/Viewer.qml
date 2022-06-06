import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.kde.kirigami 2.7 as Kirigami
import org.shelf.poppler 1.0 as Poppler

Maui.Page
{
    id: control

    property string currentPath : _tabView.currentItem.path
    property bool currentPathFav : FB.Tagging.isFav(currentPath)
    property alias currentViewer: _tabView.currentItem
    property alias tabView :_tabView
    title: currentViewer ? currentViewer.title : ""
    padding: 0

    onGoBackTriggered: _stackView.pop()

    Component
    {
        id: _doodleComponent
        Maui.Doodle
        {
            sourceItem: currentViewer.currentItem
            hint: 1
        }
    }

    Loader
    {
        anchors.fill: parent
        active: !currentViewer
        visible: active
        asynchronous: true

        sourceComponent: Maui.Holder
        {
            emoji: "qrc:/assets/draw-watercolor.svg"
            title : i18n("Nothing here")
            body: i18n("Drop or open a document to view.")
        }
    }

    headBar.forceCenterMiddleContent: root.isWide

    headBar.farLeftContent: ToolButton
    {
        icon.name: "go-previous"
        text: i18n("Browser")
        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        onClicked: toggleViewer()
    }

    headBar.rightContent: Loader
    {
        asynchronous: true
        sourceComponent:  Maui.ToolButtonMenu
        {
            icon.name: "overflow-menu"

            Maui.MenuItemActionRow
            {
                Action
                {
                    icon.name: "love"
                    text: i18n("Fav")

                    checked: currentPathFav
                    icon.color: currentPathFav ? "#f84172" : Maui.Theme.textColor
                    onTriggered:
                    {
                        FB.Tagging.toggleFav(control.currentPath)
                        currentPathFav = FB.Tagging.isFav(control.currentPath)
                    }
                }

                Action
                {
                    icon.name: "tool_pen"
                    text: i18n("Doodle")

                    onTriggered:
                    {
                        _dialogLoader.sourceComponent = _doodleComponent
                        dialog.open()
                    }
                }

                Action
                {
                    icon.name: "document-share"
                    text: i18n("Share")

                    onTriggered:
                    {
                        Maui.Platform.shareFiles([control.currentPath])
                    }
                }
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

            //            MenuItem
            //            {
            //                icon.name:  "zoom-fit-width"
            //                text: i18n("Fill")
            //                checkable: true
            //                checked: currentViewer.fitWidth
            //                onTriggered:
            //                {
            //                    currentViewer.fitWidth= !currentViewer.fitWidth
            //                }
            //            }

            MenuItem
            {
                text: i18n("Fullscreen")
                checkable: true
                checked: root.visibility === Window.FullScreen
                icon.name: "view-fullscreen"
                onTriggered: root.visibility = (root.visibility === Window.FullScreen  ? Window.Windowed : Window.FullScreen)
            }
        }
    }

    Maui.TabView
    {
        id: _tabView
        anchors.fill: parent

        onCloseTabClicked: _tabView.closeTab(index)
    }

    Component
    {
        id: _pdfComponent

        Poppler.PDFViewer
        {
            Maui.TabViewInfo.tabTitle: title
            Maui.TabViewInfo.tabToolTipText:  path
            height: ListView.view.height
            width:  ListView.view.width
            onGoBackTriggered: _stackView.pop()
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

    function open(path)
    {
        if(FB.FM.fileExists(path))
        {
            if(!viewerView.visible)
            {
                toggleViewer()
            }

            if(path.endsWith(".pdf"))
            {
                _tabView.addTab(_pdfComponent, ({'path': path}))
            }
            else if(path.endsWith(".txt"))
            {
                _tabView.addTab(_txtComponent, ({'path': path}))
            }
            else if(path.endsWith(".epub"))
            {
                _tabView.addTab(_epubComponent, ({'path': path}))
            }
            else return;
        }
    }
}
