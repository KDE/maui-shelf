import QtQuick 2.9
import QtQuick.Controls 2.5
import org.kde.mauikit 1.0 as Maui

import LibraryModel 1.0
import LibraryList 1.0

Maui.Page
{
    id: control

    property alias list : _libraryList
    property alias currentIndex: _gridBrowser.currentIndex

    headBar.leftContent: [

        ToolButton
        {
            icon.name: "view-list-icons"
        },
        ToolButton
        {
            icon.name: "view-sort"
            onClicked: sortMenu.popup()

            Menu
            {
                id: sortMenu

                MenuItem
                {
                    text: qsTr("Title")
                    checkable: true
                }

                MenuItem
                {
                    text: qsTr("Add date")
                    checkable: true
                }

                MenuItem
                {
                    text: qsTr("Creation date")
                    checkable: true
                }

                MenuItem
                {
                    text: qsTr("Format")
                    checkable: true
                }

                MenuItem
                {
                    text: qsTr("Size")
                    checkable: true
                }
            }
        }
    ]

    headBar.rightContent:[
        ToolButton
        {
            icon.name: "item-select"
        },
        ToolButton
        {
            id: menuBtn
            icon.name: "overflow-menu"
        }
    ]

    Maui.GridBrowser
    {
        id: _gridBrowser
        anchors.fill: parent
        itemSize : iconSizes.huge + fontSizes.default
        model: _libraryModel

        onItemClicked:
        {
            var item = _libraryList.get(index)
            //            viewerView.open("file://"+item.url)
            //            Maui.FM.openUrl(item.url)

            viewerView.open(item)
        }
    }

    LibraryModel
    {
        id: _libraryModel
        list: _libraryList
    }

    LibraryList
    {
        id: _libraryList
        query: "select *, title as label from documents"
    }

}
