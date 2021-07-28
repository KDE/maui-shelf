import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import "views/library/"
import "views/Viewer/"

Maui.ApplicationWindow
{
    id: root
    title: viewerView.title

    headBar.visible: false

    property bool selectionMode: false

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
