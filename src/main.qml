import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.shelf 1.0 as Shelf

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
        property bool thumbnailsPreview : true
        property bool darkMode: true
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
            settings.filterType: FB.FMList.DOCUMENT
            callback: function(paths)
            {
                console.log(paths)
                Shelf.Library.openFiles(paths)
            }
        }
    }

    Loader
    {
        id: _dialogLoader
    }

    Maui.StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: initModule === "viewer" ? viewerView : libraryView

        Viewer
        {
            id: viewerView
            visible: StackView.status === StackView.Active
            showCSDControls:  initModule === "viewer"
        }

        Component
        {
            id: libraryView

            LibraryView
            {
                showCSDControls:  initModule === "collection"
            }
        }
    }

    Connections
    {
        target: Shelf.Library

        ignoreUnknownSignals: true

        onRequestedFiles:
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
