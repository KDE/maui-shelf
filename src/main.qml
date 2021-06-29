import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.13

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

//import StoreList 1.0

import "views/library/"
import "views/Viewer/"
import "views/cloud/"

Maui.ApplicationWindow
{
    id: root
    title: viewerView.title

    headBar.visible: false

    property bool selectionMode: false

   StackView
    {
        id: _stackView
        anchors.fill: parent

        Viewer
        {
            id: viewerView
            visible: StackView.status === StackView.Active
        }

        initialItem: LibraryView
        {
            id: libraryView
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




    Component.onCompleted:
    {
        //        cloudViewLoader.sourceComponent = _cloudViewComponent
        //        storeViewLoader.sourceComponent= _storeViewComponent
    }

}
