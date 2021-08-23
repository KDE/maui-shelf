import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.imagetools 1.0 as IT

import org.kde.kirigami 2.9 as Kirigami

import PDF 1.0 as PDF

Maui.Page
{
    id: control

    property bool fitWidth: false
    property int currentPage : _listView.currentIndex
    property alias currentItem :_listView.currentItem
    property alias orientation : _listView.orientation

    headBar.visible: false
    footBar.visible: !Kirigami.Settings.isMobile && poppler.pages > 1

    padding: 0

    footBar.middleContent: [
        Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                enabled: _listView.currentIndex > 0
                icon.name:  _listView.orientation === ListView.Horizontal ? "go-previous" : "go-up"
                onTriggered:
                {
                    if( _listView.currentIndex > 0)
                    _listView.currentIndex = _listView.currentIndex - 1
                }
            }

            Action
            {
                text:  _listView.currentIndex + 1 +" / "+ poppler.pages
            }

            Action
            {
                enabled: _listView.currentIndex +1 < poppler.pages
                icon.name:  _listView.orientation === ListView.Horizontal ? "go-next" : "go-down"
                onTriggered:
                {
                    if( _listView.currentIndex +1 < poppler.pages)
                    _listView.currentIndex = _listView.currentIndex + 1
                }
            }
        }
    ]

        Maui.ListBrowser
        {
            id: _listView
            anchors.fill: parent
            model: PDF.Document
            {
                id: poppler

                property bool isLoading: true

                onPagesLoaded:
                {
                    isLoading = false;

                    var title = getDocumentInfo("Title")
                    if (title !== "")
                        control.title = title;
                    else control.title = FB.FM.getFileInfo("file://"+poppler.path).label

                    console.log(poppler.path, control.title)
                }
            }

            orientation: ListView.Vertical
            snapMode: ListView.SnapOneItem
            //        cacheBuffer: control.fitWidth ? poppler.providersNumber *  : height * poppler.providersNumber

            flickable.onMovementEnded:
            {
                var index = indexAt(contentX, contentY)
                currentIndex = index
            }

            delegate: Item
            {
                id: delegate
                width: ListView.view.width
                height: ListView.view.height

                IT.ImageViewer
                {
                    id: pageImg
                    asynchronous: true

                    anchors.centerIn: parent
                    height: fitWidth ? undefined : parent.height
                    width:  parent.width

                    cache: false
                    //                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + _listView.currentPage;
                    //                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + index;
                    source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + index
                    //                                source: "image://poppler/page/" + _listView.currentPage;
                    sourceSize.width: 2000
//                    sourceSize.height: 2000
                    //                    imageWidth: 1000
                    //                    imageHeight: 1000
                    fillMode: Image.PreserveAspectFit

                    //                onSourceChanged: console.log(source)
                }
            }

            //         ScrollBar.vertical: ScrollBar {}
        }

    function open(filePath)
    {
        poppler.path = filePath.replace("file://", "")
    }
}
