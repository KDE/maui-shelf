import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import StoreList 1.0

import "views/library/"
import "views/Viewer/"
import "views/cloud/"

Maui.ApplicationWindow
{
    id: root
    about.appDescription: qsTr("Library is a documents viewer and collection manager.\nLibrary allows you to browse your local and cloud collection, and also allows you to download new content from the integrated store.")
    about.appIcon: "qrc:/assets/library.svg"

    readonly property var views :({
                             viewer : 0,
                             library: 1,
                             cloud: 2,
                             store: 3,
                             search: 4
                         })

    property int currentView : views.library

    headBar.middleContent: Kirigami.ActionToolBar
    {
        Layout.fillWidth: true
        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        actions:  [
            Action
            {
                id: _viewerButton
                icon.name: "document-preview-archive"
                text: qsTr("Viewer")
                onTriggered: currentView = views.viewer

            },

            Action
            {
                id: _libraryButton
                icon.name: "view-books"
                text: qsTr("Library")
                onTriggered: currentView = views.library
            },

            Action
            {
                id: _cloudButton
                icon.name: "folder-cloud"
                text: qsTr("Cloud")
                onTriggered: currentView = views.cloud
            },

            Action
            {
                id: _storeButton
                icon.name: "nx-software-center"
                text: qsTr("Store")
                onTriggered: currentView = views.store
            }
        ]
    }

    ColumnLayout
    {
        id: mainPage
        anchors.fill: parent

        SwipeView
        {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: isMobile
            currentIndex: currentView

            onCurrentIndexChanged: currentView = currentIndex

            Viewer
            {
                id: viewerView
            }

            LibraryView
            {
                id: libraryView
            }

            Loader
            {
                id: cloudViewLoader
            }

            Loader
            {
                id: storeViewLoader
            }

            Maui.Page
            {
                id: searchView
            }
        }

        /*** Components ***/

        Component
        {
            id: _cloudViewComponent
            CloudView
            {
                anchors.fill : parent
            }
        }

        Component
        {
            id: _storeViewComponent

            Maui.Store
            {
                anchors.fill : parent
                detailsView: false
                list.category: StoreList.EBOOKS
                list.provider: StoreList.OPENDESKTOPCC
                fitPreviews: true

                onOpenFile:  viewerView.open(filePath)

                onFileReady:
                {
                    viewerView.open("file://"+item.url)
//                    libraryView.list.insert(item.url)
                }
            }
        }

        Maui.SelectionBar
        {
            id: selectionBox
            Layout.fillWidth : true
            Layout.leftMargin: space.big
            Layout.rightMargin: space.big
            Layout.bottomMargin: space.big
            Layout.topMargin: space.small
        }
    }


    Component.onCompleted:
    {
//        cloudViewLoader.sourceComponent = _cloudViewComponent
        storeViewLoader.sourceComponent= _storeViewComponent
    }

}
