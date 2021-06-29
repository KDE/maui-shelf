import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui

import org.maui.shelf 1.0

Maui.AltBrowser
{
    id: control
    enableLassoSelection: true
    gridView.itemSize: 180
    gridView.itemHeight: 220

    property alias list : _libraryList
    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    Connections
    {
        target: control.currentView
        function onItemsSelected(indexes)
        {
            for(var i in indexes)
            {
                const item =  control.model.get(indexes[i])
                _selectionbar.append(item.path, item)
            }
        }
    }

    model: Maui.BaseModel
    {
        id: _libraryModel
        sort: "modified"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: LibraryList
        {
            id: _libraryList
        }
    }

    headBar.leftContent: ToolButton
    {
        enabled: list.count > 0
        icon.name: control.viewType === Maui.AltBrowser.ViewType.List ? "view-list-icons" : "view-list-details"

        onClicked:
        {
            control.viewType =  control.viewType === Maui.AltBrowser.ViewType.List ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List
        }
    }

    headBar.rightContent:[
        Maui.ToolButtonMenu
        {
            icon.name: "view-sort"
            MenuItem
            {
                text: i18n("Title")
                checkable: true
                checked: _libraryModel.sort === "label"
                onTriggered: _libraryModel.sort = "label"
            }

            MenuItem
            {
                text: i18n("Date")
                checkable: true
                checked: _libraryModel.sort === "modified"
                onTriggered: _libraryModel.sort = "modified"
            }

            MenuItem
            {
                text: i18n("Size")
                checkable: true
                checked: _libraryModel.sort === "size"
                onTriggered: _libraryModel.sort = "size"
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Ascending")
                checked: _libraryModel.sortOrder === Qt.AscendingOrder
                onTriggered: _libraryModel.sortOrder = Qt.AscendingOrder
            }

            MenuItem
            {
                text: i18n("Descending")
                checked: _libraryModel.sortOrder === Qt.DescendingOrder
                onTriggered: _libraryModel.sortOrder = Qt.DescendingOrder
            }
        }
    ]

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  control.model.filter = text
    }


    gridDelegate: Item
    {
        property bool isCurrentItem : GridView.isCurrentItem

        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        Maui.GridBrowserDelegate
        {
            id: _gridTemplate
            anchors.fill: parent
            anchors.margins: !root.isWide ? Maui.Style.space.tiny : Maui.Style.space.big

            isCurrentItem: parent.isCurrentItem || checked

            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}


        label1.text: model.label
        imageSource: model.thumbnail
        iconSource: model.icon
        template.fillMode: Image.PreserveAspectFit

        checkable: root.selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: _selectionbar.append(model.path, control.model.get(index))

        Connections
        {
            target: _selectionbar
            function onUriRemoved(uri)
            {
                if(uri === model.path)
                    _gridTemplate.checked = false
            }

            function onUriAdded(uri)
            {
                if(uri === model.path)
                    _gridTemplate.checked = true
            }

            function onCleared()
            {
                _gridTemplate.checked = false
            }
        }

        onClicked:
        {
            control.currentIndex = index
            const item = control.model.get(control.currentIndex)

            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                const item = control.model.get(control.currentIndex)
                _selectionbar.append(item.path, item)

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

listDelegate: Maui.ListBrowserDelegate
{
    id: _listDelegate

    isCurrentItem: ListView.isCurrentItem || checked

    height: Math.floor(Maui.Style.rowHeight * 1.6)
    width: ListView.view.width

    draggable: true
    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ?
                       {
                           "text/uri-list": control.filterSelectedItems(model.path)
                       } : {}

    label1.text: model.label
    label2.text: model.path

    label3.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

    iconSource: model.icon
    iconSizeHint: Maui.Style.iconSizes.medium
    checkable: root.selectionMode
    checked: _selectionbar.contains(model.path)
    onToggled: _selectionbar.append(model.path, control.model.get(index))

    Connections
    {
        target: _selectionbar
        function onUriRemoved(uri)
        {
            if(uri === model.path)
                _listDelegate.checked = false
        }

        function onUriAdded(uri)
        {
            if(uri === model.path)
                _listDelegate.checked = true
        }

        function onCleared()
        {
            _listDelegate.checked = false
        }
    }

    onClicked:
    {
        control.currentIndex = index
        const item = control.model.get(control.currentIndex)

        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            _selectionbar.append(item.path, item)

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



footer: Maui.SelectionBar
{
    id: _selectionbar
    anchors.horizontalCenter: parent.horizontalCenter
    width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
    padding: Maui.Style.space.big
    maxListHeight: swipeView.height - Maui.Style.space.medium

    onItemClicked : console.log(index)

    onExitClicked: clear()

    Action
    {
        text: i18n("Open")
        icon.name: "document-open"
        onTriggered:
        {
            for(var item of _selectionbar.items)
            viewerView.open(item)

            _selectionbar.clear()
        }
    }

    Action
    {
        text: i18n("Share")
        icon.name: "document-share"
    }

    Action
    {
        text: i18n("Export")
        icon.name: "document-export"
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

}
