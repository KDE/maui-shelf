import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.shelf 1.0 as Shelf

import "views/library/"
import "views/Viewer/"

Maui.ApplicationWindow
{
    id: root
    title: viewerView.title

    headBar.visible: false

    property bool selectionMode: false
    property alias dialog :_dialogLoader.item

    Settings
    {
        id: viewerSettings
        property int viewType : Maui.AltBrowser.ViewType.Grid
    }

    Loader
    {
        id: _dialogLoader
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        Viewer
        {
            id: viewerView
            visible: StackView.status === StackView.Active
        }

        initialItem: LibraryView
        {
            id: libraryView
            showCSDControls: true
        }
    }

    Connections
    {
        target: Shelf.Library

        ignoreUnknownSignals: true

        onRequestedFiles:
        {
            viewerView.open(files[0])
        }
    }

    Component.onCompleted:
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor(headBar.Kirigami.Theme.backgroundColor, false)
            Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, false)
        }
    }
}
