import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.shelf as Shelf

Maui.SideBarView
{
    id: control

    property alias list : _libraryList
    property alias flickable : _browser.flickable
    property alias sources : _libraryList.sources

    sideBar.preferredWidth: 200
    sideBar.minimumWidth: 200
    sideBar.resizeable: false
    sideBar.content: Sidebar
    {
        anchors.fill: parent
    }

    LibraryMenu
    {
        id: _menu
        index: _browser.currentIndex
        model: _libraryModel
    }

    Maui.PageLayout
    {
        id: _pageLayout
        Maui.Controls.showCSD: control.Maui.Controls.showCSD
        anchors.fill: parent
        split: !root.isWide
        altHeader: Maui.Handy.isMobile

        FloatingViewer
        {
            id: _floatingViewer
            active: viewerView.tabView.count > 0 || item
            visible: viewerView.tabView.count > 0

            DragHandler
            {
                target: _floatingViewer
                xAxis.maximum: _pageLayout.width - _floatingViewer.width
                xAxis.minimum: 0

                yAxis.maximum : _pageLayout.height - _floatingViewer.height
                yAxis.minimum: 0

                onActiveChanged:
                {
                    if(!active)
                    {
                        let newX = Math.abs(_floatingViewer.x - (_pageLayout.width - _floatingViewer.implicitWidth - 20))
                        _floatingViewer.x = Qt.binding(()=> { return (_pageLayout.width - _floatingViewer.implicitWidth - 20 - newX) < 0 ? 20 : _pageLayout.width - _floatingViewer.implicitWidth - 20 - newX})
                        _floatingViewer.y = Qt.binding(()=> { return _floatingViewer.parent.height - _floatingViewer.implicitHeight - 20})

                    }
                }
            }
        }

        headBar.forceCenterMiddleContent: root.isWide
        leftContent: [ToolButton
            {
                visible: control.sideBar.collapsed
                icon.name: control.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                onClicked: control.sideBar.toggle()
                checked: control.sideBar.visible
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Toggle sidebar")
            }
        ]

        rightContent:[
            Maui.ToolButtonMenu
            {
                icon.name: _browser.viewType === Maui.AltBrowser.ViewType.List ? "view-list-details" : "view-list-icons"

                MenuItem
                {
                    text: i18n("Open")
                    icon.name: "document-open"
                    onTriggered: openFileDialog()
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("List")
                    checkable: true
                    icon.name: "view-list-details"
                    checked: _browser.viewType === Maui.AltBrowser.ViewType.List
                    onTriggered: viewerSettings.viewType = Maui.AltBrowser.ViewType.List
                }

                MenuItem
                {
                    text: i18n("Grid")
                    checkable: true
                    icon.name: "view-list-icons"
                    checked: _browser.viewType === Maui.AltBrowser.ViewType.Grid
                    onTriggered: viewerSettings.viewType = Maui.AltBrowser.ViewType.Grid
                }

                MenuSeparator {}

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

                MenuSeparator {}

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
            }
        ]

        middleContent: Maui.SearchField
        {
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter
            placeholderText: i18n("Filter...")
            onAccepted: _browser.model.filter = text
            onCleared:  _libraryModel.clearFilters()
        }

        Maui.AltBrowser
        {
            id: _browser

            anchors.fill: parent

            enableLassoSelection: true
            gridView.itemSize: Math.min(180, Math.floor(gridView.availableWidth/3))
            gridView.itemHeight: 220
            viewType: viewerSettings.viewType

            Connections
            {
                target: _browser.currentView
                function onItemsSelected(indexes)
                {
                    for(var i in indexes)
                    {
                        const item =  _browser.model.get(indexes[i])
                        _selectionbar.append(item.path, item)
                    }
                }
            }

            holder.visible: _browser.count === 0
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

            gridDelegate: Item
            {
                height: GridView.view.cellHeight
                width: GridView.view.cellWidth

                Maui.GridBrowserDelegate
                {
                    id: _gridTemplate
                    anchors.fill: parent
                    anchors.margins: !root.isWide ? Maui.Style.space.tiny : Maui.Style.space.big

                    imageHeight: _browser.gridView.itemSize
                    imageWidth: _browser.gridView.itemSize

                    isCurrentItem: parent.GridView.isCurrentItem || checked

                    draggable: true
                    Drag.keys: ["text/uri-list"]

                    Drag.mimeData: Drag.active ?
                                       {
                                           "text/uri-list": _browser.filterSelectedItems(model.path)
                                       } : {}


                label1.text: model.label
                imageSource: viewerSettings.showThumbnails ? model.preview : ""
                iconSource: model.icon
                iconSizeHint: Maui.Style.iconSizes.huge
                template.labelSizeHint: 32
                template.fillMode: Image.PreserveAspectFit

                checkable: root.selectionMode
                checked: _selectionbar.contains(model.path)
                onToggled: _selectionbar.append(model.path, _browser.model.get(index))

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
                    _browser.currentIndex = index
                    const item = _browser.model.get(_browser.currentIndex)

                    if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                    {
                        const item = _browser.model.get(_browser.currentIndex)
                        _selectionbar.append(item.path, item)

                    }else if(Maui.Handy.singleClick)
                    {
                        Shelf.Library.openFiles([item.url])
                    }
                }

                onDoubleClicked:
                {
                    _browser.currentIndex = index
                    if(!Maui.Handy.singleClick && !selectionMode)
                    {
                        const item = _browser.model.get(_browser.currentIndex)
                        Shelf.Library.openFiles([item.url])
                    }
                }

                onPressAndHold:
                {
                    _browser.currentIndex = index
                    _menu.show()
                }

                onRightClicked:
                {
                    _browser.currentIndex = index
                    _menu.show()
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
                                   "text/uri-list": _browser.filterSelectedItems(model.path)
                               } : {}

        label1.text: model.label
        label2.text: String(FB.FM.fileDir(model.path)).replace(FB.FM.homePath(), "")

        label3.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")
        imageSource: viewerSettings.showThumbnails ? model.preview : ""

        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.medium
        checkable: root.selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: _selectionbar.append(model.path, _browser.model.get(index))

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
            _browser.currentIndex = index
            const item = _browser.model.get(_browser.currentIndex)

            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                _selectionbar.append(item.path, item)

            }else if(Maui.Handy.singleClick)
            {
                Shelf.Library.openFiles([item.path])
            }
        }

        onDoubleClicked:
        {
            _browser.currentIndex = index

            if(!Maui.Handy.singleClick && !selectionMode)
            {
                const item = _browser.model.get(_browser.currentIndex)
                Shelf.Library.openFiles([item.path])
            }
        }

        onPressAndHold:
        {
            _browser.currentIndex = index
            _menu.show()
        }

        onRightClicked:
        {
            _browser.currentIndex = index
            _menu.show()
        }
    }

    footer: Maui.SelectionBar
    {
        id: _selectionbar
        //    implicitHeight: 80
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

        maxListHeight: _stackView.height - Maui.Style.space.medium

        onItemClicked : console.log(index)

        onExitClicked:
        {
            clear()
            root.selectionMode = false
        }

        Action
        {
            text: i18n("Open")
            icon.name: "folder_open"
            onTriggered:
            {
                Shelf.Library.openFiles(_selectionbar.uris)
            }
        }

        Action
        {
            text: i18n("Tag")
            icon.name: "tag"
            onTriggered:
            {
                _dialogLoader.sourceComponent = tagsDialogComponent
                dialog.composerList.urls = _selectionbar.uris
                dialog.open()
            }
        }

        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered:
            {
                Maui.Platform.shareFiles(_selectionbar.uris)
            }
        }

        Action
        {
            text: i18n("Export")
            icon.name: "document-export"
            onTriggered:
            {
                _dialogLoader.sourceComponent = null
                _dialogLoader.sourceComponent = _fileDialog
                dialog.browser.settings.onlyDirs = true
                dialog.singleSelection = true
                dialog.callback = function(paths)
                {
                    FB.FM.copy(_selectionbar.uris, paths[0])
                }
                dialog.open()
            }
        }
    }

}
}

function openFolders(paths)
{
    control.sources = paths
}

function filterSelection(url)
{
    if(_selectionbar.contains(url))
    {
        return selectionBox.uris
    }else
    {
        return [url]
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
    _dialogLoader.sourceComponent = null
    _dialogLoader.sourceComponent = _fileDialog
    _dialogLoader.item.browser.settings.filterType = FB.FMList.DOCUMENT
    _dialogLoader.item.browser.settings.filters = [".cbz", ".cbr"]
    _dialogLoader.item.callback = function(paths)
    {
        console.log(paths)
        Shelf.Library.openFiles(paths)
    }
    _dialogLoader.item.open()
}

function openSettingsDialog()
{
    _dialogLoader.sourceComponent = _settingsDialogComponent
    _dialogLoader.item.open()
}

}
