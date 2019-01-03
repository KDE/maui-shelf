import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui

import LibraryModel 1.0
import LibraryList 1.0

Maui.Page
{
    id: control

    property alias list : _libraryList

    headBarExit: false

    headBar.leftContent: [

        Maui.ToolButton
        {
            iconName: "view-list-icons"
         },
        Maui.ToolButton
        {
            iconName: "view-sort"
            onClicked: sortMenu.popup()

            Maui.Menu
            {
                id: sortMenu

                Maui.MenuItem
                {
                    text: qsTr("Title")
                    checkable: true
                }

                Maui.MenuItem
                {
                    text: qsTr("Add date")
                    checkable: true
                }

                Maui.MenuItem
                {
                    text: qsTr("Creation date")
                    checkable: true
                }

                Maui.MenuItem
                {
                    text: qsTr("Format")
                    checkable: true
                 }

                Maui.MenuItem
                {
                    text: qsTr("Size")
                    checkable: true
                }
            }
        }
    ]

    headBar.rightContent:[
        Maui.ToolButton
        {
            iconName: "item-select"
        },
        Maui.ToolButton
        {
            id: menuBtn
            iconName: "overflow-menu"
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

            viewerView.open(item.url)
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
