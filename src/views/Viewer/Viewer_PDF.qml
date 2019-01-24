import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui

import PDF 1.0 as PDF

Maui.Page
{
    id: control

    property bool fitWidth: false
    property int currentPage : _listView.currentIndex

    headBar.visible: false

    margins: 0

    footBar.middleContent: [
        Maui.ToolButton
        {
            enabled: _listView.currentIndex > 0
            iconName:  _listView.orientation === ListView.Horizontal ? "go-previous" : "go-up"
            onClicked:
            {
                if( _listView.currentIndex > 0)
                _listView.currentIndex = _listView.currentIndex - 1
            }
        },

        Label
        {
            color: control.colorScheme.textColor
            text:  _listView.currentIndex +" / "+ poppler.pages
            font.bold: false
            font.weight: Font.Thin
            font.pointSize: fontSizes.medium
            anchors.verticalCenter: parent.verticalCenter
        },

        Maui.ToolButton
        {
            enabled: _listView.currentIndex +1 < poppler.pages
            iconName:  _listView.orientation === ListView.Horizontal ? "go-next" : "go-down"
            onClicked:
            {
                if( _listView.currentIndex +1 < poppler.pages)
                _listView.currentIndex = _listView.currentIndex + 1
            }
        }
    ]

    footBar.leftContent:[

        Maui.ToolButton
        {
            iconName:  "zoom-fit-width"
            checkable: true
            checked: control.fitWidth
            onClicked:
            {
                control.fitWidth= !control.fitWidth
            }
        }
    ]

    footBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "view-right-new"
            checkable: true
            checked:  _listView.orientation === ListView.Horizontal
            onClicked:
            {
                //                _listView.orientation = checked ? ListView.Horizontal :  ListView.Vertical
              _listView.orientation = _listView.orientation === ListView.Horizontal ? ListView.Vertical : ListView.Horizontal
            }
        }
    ]


    PDF.Document
    {
        id: poppler

        property bool isLoading: true

        onPagesLoaded: {
            isLoading = false;

            var title = getDocumentInfo("Title")
            if (title !== "")
                control.headBarTitle = title;
            else control.headBarTitle = Maui.FM.getFileInfo(control.currentPath).label
        }
    }

    ListView
    {
        id: _listView
        anchors.fill : parent
        model: poppler
        clip: true
        focus: true
        orientation: ListView.Vertical
        //        interactive: false
        //        highlightFollowsCurrentItem: true
        //        highlightMoveDuration: 0
        snapMode: control.fitWidth ? ListView.NoSnap : ListView.SnapOneItem
        spacing: space.big
        //        cacheBuffer: control.fitWidth ? poppler.providersNumber *  : height * poppler.providersNumber

        onMovementEnded:
        {
            var index = indexAt(contentX, contentY)
            currentIndex = index
        }

        delegate: ItemDelegate
        {
            id: delegate
            width: _listView.width
            height: control.fitWidth ? pageImg.implicitHeight : _listView.height

            background: Rectangle
            {
                color: "transparent"
            }

            Image
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
                sourceSize.width: delegate.width
                //                sourceSize.height: delegate.height
                fillMode: Image.PreserveAspectFit

                //                onSourceChanged: console.log(source)
            }
        }

        //         ScrollBar.vertical: ScrollBar {}
    }
    function open(filePath)
    {
        poppler.path = filePath
    }
}
