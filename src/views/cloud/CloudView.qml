import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui

import CloudList 1.0
import LibraryModel 1.0

Maui.Page
{
    id: control

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

    LibraryModel
    {
        id: _cloudModel
        list: _cloudList
    }

    CloudList
    {
        id: _cloudList
        account: currentAccount
        onWarning:
        {
            notify("dialog-information", "An error happened", error)
        }

        onCloudItemReady:
        {
            viewerView.open(item.url)
        }
    }

    Maui.GridBrowser
    {
        id: _gridBrowser
        anchors.fill: parent
        itemSize : iconSizes.huge + fontSizes.default
        model: _cloudModel

        onItemClicked:
        {
            _cloudList.requestItem(index)
        }
    }

}
