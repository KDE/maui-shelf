import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.13
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import org.kde.kirigami 2.7 as Kirigami

//import StoreList 1.0

import "views/library/"
import "views/Viewer/"
import "views/cloud/"

Maui.ApplicationWindow
{
    id: root
    title: viewerView.title
    flickable: swipeView.currentItem.flickable

//    floatingHeader:
    autoHideHeader: swipeView.currentIndex === views.viewer && swipeView.currentItem.currentViewer
    floatingFooter: true

    property bool selectionMode: false
    readonly property var views :({
                             viewer : 0,
                             library: 1,
                             cloud: 2,
                             store: 3,
                             search: 4
                         })

    headBar.rightContent: ToolButton
    {
//        visible: Maui.Handy.isTouch
        icon.name: "item-select"
        checkable: true
        checked: root.selectionMode
        onClicked: root.selectionMode = !root.selectionMode
//        onPressAndHold: currentBrowser.selectAll()
    }

    MauiLab.AppViews
        {
            id: swipeView
           anchors.fill: parent

            Viewer
            {
                id: viewerView
               MauiLab.AppView.iconName: "document-preview-archive"
                MauiLab.AppView.title: qsTr("Viewer")
            }

            LibraryView
            {
                id: libraryView
                MauiLab.AppView.iconName: "view-books"
                MauiLab.AppView.title: qsTr("Library")
            }
        }

//            Loader
//            {
//                id: cloudViewLoader
//            }

//            Loader
//            {
//                id: storeViewLoader
//            }

//            Maui.Page
//            {
//                id: searchView
//            }


        /*** Components ***/

//        Component
//        {
//            id: _cloudViewComponent
//            CloudView
//            {
//                anchors.fill : parent
//            }
//        }

//        Component
//        {
//            id: _storeViewComponent

//            Maui.Store
//            {
//                anchors.fill : parent
//                detailsView: false
//                list.category: StoreList.EBOOKS
//                list.provider: StoreList.OPENDESKTOPCC
//                fitPreviews: true

//                onOpenFile:  viewerView.open(filePath)

//                onFileReady:
//                {
//                    viewerView.open("file://"+item.url)
////                    libraryView.list.insert(item.url)
//                }
//            }
//        }




    footer: MauiLab.SelectionBar
    {
        id: _selectionbar
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
        padding: Maui.Style.space.big
        maxListHeight: swipeView.height - Maui.Style.space.medium

        onItemClicked : console.log(index)

        onExitClicked: clear()

        Action
        {
            text: qsTr("Open")
            icon.name: "document-open"
            onTriggered:
            {
                for(var item of _selectionbar.items)
                    viewerView.open(item)

                _selectionbar.clear()
            }
        }

        Action
        {
            text: qsTr("Share")
            icon.name: "document-share"
        }

        Action
        {
            text: qsTr("Export")
            icon.name: "document-export"
        }
    }


    Component.onCompleted:
    {
//        cloudViewLoader.sourceComponent = _cloudViewComponent
//        storeViewLoader.sourceComponent= _storeViewComponent
    }

}
