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
    Maui.Style.styleType: viewerView.active ? Maui.Style.Dark : undefined

    property bool selectionMode: false

    Settings
    {
        id: viewerSettings
        property bool autoScan : true
        property bool showThumbnails: true
        property int viewType : Maui.AltBrowser.ViewType.Grid
    }

    Component
    {
        id: _settingsDialogComponent

        SettingsDialog
        {
            onClosed: destroy()
        }
    }

    Component
    {
        id: _fileDialog
        FB.FileDialog
        {
            mode: FB.FileDialog.Open
            onClosed: destroy()
        }
    }

    FB.OpenWithDialog
    {
        id: _openWithDialog
    }

    property FB.TagsDialog tagsDialog: null
    Component
    {
        id: tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: (tags) => composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: initModule === "viewer" ? viewerView : libraryView

        Viewer
        {
            id: viewerView
            readonly property bool active : StackView.status === StackView.Active
            Maui.Controls.showCSD: true
            clip: true
        }

        Component
        {
            id: libraryView

            LibraryView
            {
                Maui.Controls.showCSD: true
                clip: true
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
        if(viewerView.active)
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

    function tagUrls(urls)
    {
        if(!root.tagsDialog)
        {
            root.tagsDialog = tagsDialogComponent.createObject(root)
        }

        root.tagsDialog.composerList.urls = urls
        root.tagsDialog.open()
    }

    function saveFilesAs(urls)
    {
        var props = ({'mode' : FB.FileDialog.Save,
                         'browser.settings.filterType' : FB.FMList.DOCUMENT,
                         'browser.settings.filters' : [".cbz", ".cbr"],
                         'singleSelection' : true,
                         'suggestedFileName' : FB.FM.getFileInfo(urls[0]).label,
                         'callback' : function(paths)
                         {
                             FB.FM.copy(urls, paths[0])
                         }})
        var dialog = _fileDialog.createObject(root, props)
        dialog.open()
    }
}
