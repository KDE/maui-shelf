import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.shelf 1.0 as Shelf

Maui.AltBrowser
{
    id: control
    enableLassoSelection: true
    gridView.itemSize: 180
    gridView.itemHeight: 220
    floatingFooter: true
    viewType: viewerSettings.viewType

    property alias list : _libraryList

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

    holder.visible: control.list.count == 0
    holder.title: i18n("Nothing here!")
    holder.body: i18n("Add new sources to manage your documents.")
    holder.emoji: "qrc:/assets/document-new.svg"
    holder.actions:[

        Action
        {
            text: i18n("Open file")
            onTriggered: openFileDialog()
        },

        Action
        {
            text: i18n("Add sources")
            onTriggered: openSettingsDialog()
        }
    ]

    model: Maui.BaseModel
    {
        id: _libraryModel
        sort: "modified"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Shelf.LibraryList
        {
            id: _libraryList
        }
    }

    altHeader: Maui.Handy.isMobile
    headBar.forceCenterMiddleContent: root.isWide
    headBar.leftContent: [Maui.ToolButtonMenu
    {
        icon.name: "application-menu"

        MenuItem
        {
            text: i18n("Open")
            icon.name: "document-open"
            onTriggered: openFileDialog()
        }

        MenuItem
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered: openSettingsDialog()
        }

        MenuItem
        {
            text: i18n("About")
            icon.name: "documentinfo"
            onTriggered: root.about()
        }
    },

    ToolButton
        {
            visible: viewerView.tabView.count
            icon.name: "view-readermode-active"
            text: viewerView.tabView.count
            onClicked: toggleViewer()
        }

    ]

    headBar.rightContent:[
        Maui.ToolButtonMenu
        {
            icon.name: control.viewType === Maui.AltBrowser.ViewType.List ? "view-list-details" : "view-list-icons"

            Maui.LabelDelegate
            {
                isSection: true
                label: i18n("View type")
                width: ListView.view.width
            }

            MenuItem
            {
                text: i18n("List")
                checkable: true
                icon.name: "view-list-details"
                checked: control.viewType === Maui.AltBrowser.ViewType.List
                onTriggered: viewerSettings.viewType = Maui.AltBrowser.ViewType.List
            }

            MenuItem
            {
                text: i18n("Grid")
                checkable: true
                icon.name: "view-list-icons"
                checked: control.viewType === Maui.AltBrowser.ViewType.Grid
                onTriggered: viewerSettings.viewType = Maui.AltBrowser.ViewType.Grid
            }

            Maui.LabelDelegate
            {
                isSection: true
                label: i18n("Sort by")
                width: ListView.view.width
            }

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

    headBar.middleContent: Maui.SearchField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter
        placeholderText: i18n("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  _libraryModel.clearFilters()
    }

    gridView.flickable.header: Pane
    {
    width: parent.width
    height: implicitContentHeight + topPadding + bottomPadding
    padding: Maui.Style.space.big

   contentItem: Flow
    {
        spacing: Maui.Style.space.medium

        Button
        {
            text: i18n("Comics")
            icon.name: "animal"
            onClicked: _libraryModel.filters = [".cbz", ".cbr"]
        }

        Button
        {
            text: i18n("Favs")
            icon.name: "love"
        }

        Button
        {
            text: i18n("Important")
        }

//        Repeater
//        {

//        }
    }

    }

    gridDelegate: Item
    {
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        Maui.GridBrowserDelegate
        {
            id: _gridTemplate
            anchors.fill: parent
            anchors.margins: !root.isWide ? Maui.Style.space.tiny : Maui.Style.space.big

            imageHeight: control.gridView.itemSize
            imageWidth: control.gridView.itemSize

            isCurrentItem: parent.GridView.isCurrentItem || checked

            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}


        label1.text: model.label
        imageSource: model.preview
        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.huge
        template.labelSizeHint: 32
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
                viewerView.open(item.path)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                const item = control.model.get(control.currentIndex)
                viewerView.open(item.path)
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
    label2.text: String(FB.FM.fileDir(model.path)).replace(FB.FM.homePath(), "")

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
            viewerView.open(item.path)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index

        if(!Maui.Handy.singleClick && !selectionMode)
        {
            const item = control.model.get(control.currentIndex)
            viewerView.open(item.path)
        }
    }
}

footer: Maui.SelectionBar
{
    id: _selectionbar
    anchors.horizontalCenter: parent.horizontalCenter
    width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

    maxListHeight: _stackView.height - Maui.Style.space.medium

    onItemClicked : console.log(index)

    onExitClicked: clear()

    Action
    {
        text: i18n("Open")
        icon.name: "folder_open"
        onTriggered:
        {
            for(var file of _selectionbar.uris)
            {
                console.log("OPEN FILES<<<<<<<<<<<<<<", file)
                viewerView.open(file)
            }
        }
    }

    Action
    {
        text: i18n("Tag")
        icon.name: "tag"
        onTriggered:
        {

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

function openFileDialog()
{
    _dialogLoader.sourceComponent = _fileDialog
    _dialogLoader.item.open()
}

function openSettingsDialog()
{
    _dialogLoader.sourceComponent = _settingsDialogComponent
    _dialogLoader.item.open()
}

}
