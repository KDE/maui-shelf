import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import LibraryList 1.0

MauiLab.AltBrowser
{
    id: control
    enableLassoSelection: true

    gridView.itemSize: 100
    gridView.topMargin: Maui.Style.contentMargins
    listView.topMargin: Maui.Style.contentMargins
    listView.spacing: Maui.Style.space.medium

    property alias list : _libraryList

    Connections
    {
        target: control.currentView
        onItemsSelected:
        {
            for(var i in indexes)
            {
                const item =  control.model.get(indexes[i])
                _selectionbar.append(item.url, item)
            }
        }
    }

    headBar.rightSretch: false
    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: true
        expanded: isWide
        currentIndex : control.viewType === MauiLab.AltBrowser.ViewType.List ? 0 : 1

        Action
        {
            text: qsTr("List")
            icon.name: "view-list-details"
            onTriggered: control.viewType = MauiLab.AltBrowser.ViewType.List
        }

        Action
        {
            text: qsTr("Grid")
            icon.name: "view-list-icons"
            onTriggered: control.viewType= MauiLab.AltBrowser.ViewType.Grid
        }
    }
    headBar.rightContent:[
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

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  control.model.filter = text
    }


    gridDelegate: Item
    {
        id: _gridDelegate

        property bool isCurrentItem : GridView.isCurrentItem
        property alias checked :_gridTemplate.checked

        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        Maui.ItemDelegate
        {
            id: _gridItemDelegate
            padding: Maui.Style.space.tiny
            isCurrentItem : GridView.isCurrentItem
            anchors.centerIn: parent
            height: parent.height- 10
            width: control.gridView.itemSize - 10
            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.url)
                               } : {}

        background: Item {}
        Maui.GridItemTemplate
        {
            id: _gridTemplate
            isCurrentItem: _gridDelegate.isCurrentItem || checked
            hovered: _gridItemDelegate.hovered || _gridItemDelegate.containsPress
            anchors.fill: parent
            label1.text: model.label
            iconSource: model.icon
            iconSizeHint: height * 0.6
            checkable: selectionMode
            checked: _selectionbar.contains(model.url)
            onToggled: _selectionbar.append(model.url, control.model.get(index))
        }

        Connections
        {
            target: _selectionbar
            onUriRemoved:
            {
                if(uri === model.url)
                    _gridDelegate.checked = false
            }

            onUriAdded:
            {
                if(uri === model.url)
                    _gridDelegate.checked = true
            }

            onCleared: _gridDelegate.checked = false
        }

        onClicked:
        {
            control.currentIndex = index
            const item = control.model.get(control.currentIndex)

            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                const item = control.model.get(control.currentIndex)
                _selectionbar.append(item.url, item)

            }else if(Maui.Handy.singleClick)
            {
                viewerView.open(item)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                const item = control.model.get(control.currentIndex)
                viewerView.open(item)
            }
        }
    }
}

listDelegate: Maui.ItemDelegate
{
    id: _listDelegate

    property alias checked :_listTemplate.checked
    isCurrentItem: ListView.isCurrentItem || checked

    height: Maui.Style.rowHeight *1.5
    width: parent.width
    leftPadding: Maui.Style.space.small
    rightPadding: Maui.Style.space.small
    draggable: true
    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ?
                       {
                           "text/uri-list": control.filterSelectedItems(model.url)
                       } : {}

    Maui.ListItemTemplate
    {
        id: _listTemplate
        anchors.fill: parent
        label1.text: model.label
        label2.text: model.url
        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.big
        checkable: selectionMode
        checked: _selectionbar.contains(model.url)
        onToggled: _selectionbar.append(model.url, control.model.get(index))
        isCurrentItem: _listDelegate.isCurrentItem
    }

    Connections
    {
        target: _selectionbar
        onUriRemoved:
        {
            if(uri === model.url)
            _listDelegate.checked = false
        }

        onUriAdded:
        {
            if(uri === model.url)
            _listDelegate.checked = true
        }

        onCleared: _listDelegate.checked = false
    }

    onClicked:
    {
        control.currentIndex = index
        const item = control.model.get(control.currentIndex)

        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            _selectionbar.append(item.url, item)

        }else if(Maui.Handy.singleClick)
        {
            viewerView.open(item)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index

        if(!Maui.Handy.singleClick && !selectionMode)
        {
            const item = control.model.get(control.currentIndex)
            viewerView.open(item)
        }
    }
}


function filterSelectedItems(path)
{
    if(_selectionbar && _selectionbar.count > 0 && _selectionbar.contains(path))
    {
        const uris = _selectionbar.uris
        return uris.join("\n")
    }

    return path
}
model: Maui.BaseModel
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
