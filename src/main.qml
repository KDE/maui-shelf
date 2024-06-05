import QtQuick 
import QtCore
import QtQuick.Controls 

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.shelf as Shelf

import "views"
import "views/library/"
import "views/Viewer/"

Maui.ApplicationWindow
{
    id: root
    title: viewerView.title
    Maui.Style.styleType: Maui.Handy.isAndroid ? (viewerSettings.darkMode ? Maui.Style.Dark : Maui.Style.Light) : undefined

    property bool selectionMode: false
    property alias dialog :_dialogLoader.item

    Settings
    {
        id: viewerSettings
        property bool autoScan : true
        property bool darkMode: true
        property bool showThumbnails: true
        property int viewType : Maui.AltBrowser.ViewType.Grid
    }

    Component
    {
        id: _settingsDialogComponent

        SettingsDialog {}
    }

    Component
    {
        id: _fileDialog
        FB.FileDialog
        {
            mode: modes.OPEN
            browser.settings.filterType: FB.FMList.DOCUMENT
            browser.settings.filters: [".cbz", ".cbr"]
            callback: function(paths)
            {
                console.log(paths)
                Shelf.Library.openFiles(paths)
            }
        }
    }

    FB.OpenWithDialog
    {
        id: _openWithDialog
    }

    Component
    {
        id: tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: (tags) => composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Loader
    {
        id: _dialogLoader
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: initModule === "viewer" ? viewerView : libraryView

        Viewer
        {
            id: viewerView
            visible: StackView.status === StackView.Active
        }

        Component
        {
            id: libraryView

            LibraryView
            {
                Maui.Controls.showCSD: initModule === "collection"
            }
        }
    }

    Connections
    {
        target: Shelf.Library

        ignoreUnknownSignals: true

        function onRequestedFiles(files)
        {
            for(var file of files)
            {
                console.log("OPEN FILES<<<<<<<<<<<<<<", file)
                viewerView.open(file)
            }
        }
    }

    Component.onCompleted:
    {
        setAndroidStatusBarColor()
    }

    function toggleViewer()
    {
        if(viewerView.visible)
        {
            if(_stackView.depth === 1)
            {
                _stackView.replace(viewerView, libraryView)

            }else
            {
                _stackView.pop()
            }

        }else
        {
            _stackView.push(viewerView)
        }

        _stackView.currentItem.forceActiveFocus()
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor( Maui.Theme.backgroundColor, !viewerSettings.darkMode)
            Maui.Android.navBarColor(Maui.Theme.backgroundColor,  !viewerSettings.darkMode)
        }
    }
}
