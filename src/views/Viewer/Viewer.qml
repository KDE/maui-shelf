import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.mauikit 1.0 as Maui
import PDF 1.0 as PDF

Maui.Page
{
    id: control
    headBarTitle: poppler.info.title
    height: 500
    width: 200

    Rectangle
    {
        anchors.fill: parent
        color: "yellow"
        opacity: 0.5
    }

    PDF.Document
    {
        id: poppler

        property bool isLoading: true

        onPagesLoaded: {
            isLoading = false;

            var title = getDocumentInfo("Title")
            if (title !== "")
                headBarTitle = title;
        }
    }

    ListView
    {
        id: _listView
        anchors.fill: parent
        model: poppler
        clip: true
        focus: true
        interactive: false
        //        highlightFollowsCurrentItem: true
        //        highlightMoveDuration: 0
        snapMode: ListView.SnapOneItem
        spacing: space.big
        cacheBuffer: height * poppler.providersNumber

        property int currentPage: 0

        delegate: ItemDelegate
        {
            id: delegate
            width: parent.width
            height: width * (model.height / model.width)
            property int page : index

            Image
            {
                id: pageImg
                anchors.fill: parent

                cache: false
                //                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + _listView.currentPage;
//                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + index;
                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + _listView.currentPage;
//                                source: "image://poppler/page/" + _listView.currentPage;
                sourceSize.width: delegate.width
                fillMode: Image.PreserveAspectFit

                //                onSourceChanged: console.log(source)
            }



            //            onIndexChanged: console.log("DELEGATE INDEX", index)

        }
    }

    footBar.floating: true;
    footBarOverlap: true

    footBar.middleContent: [
        Maui.ToolButton
        {
            iconName: "go-previous"
            onClicked:
            {
                if(  _listView.currentPage > 0)
                _listView.currentPage =  _listView.currentPage - 1
            }
        },

        Maui.ToolButton
        {
            iconName: "go-next"
            onClicked:
            {
                if( _listView.currentPage +1 < poppler.pages)
                _listView.currentPage = _listView.currentPage + 1
            }
        }
    ]

    function open(filePath)
    {
        if(Maui.FM.fileExists(filePath))
        {
            currentView = views.viewer
            _listView.currentPage = 0
            //            _listView.currentItem.page = 0
            poppler.path = filePath
        }
    }
}
