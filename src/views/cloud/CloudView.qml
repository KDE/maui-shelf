import QtQuick 2.0
import QtQuick.Controls 2.5

import org.mauikit.controls 1.0 as Maui

import CloudList 1.0
import LibraryModel 1.0

Maui.Page
{
    id: control

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
                    text: i18n("Title")
                    checkable: true
                }

                MenuItem
                {
                    text: i18n("Add date")
                    checkable: true
                }

                MenuItem
                {
                    text: i18n("Creation date")
                    checkable: true
                }

                MenuItem
                {
                    text: i18n("Format")
                    checkable: true
                 }

                MenuItem
                {
                    text: i18n("Size")
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
