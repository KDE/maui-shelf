import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui

import CloudList 1.0
import LibraryModel 1.0

Maui.Page
{
    id: control

    Maui.GridBrowser
    {
        id: _gridGrowser

    }

    LibraryModel
    {
        id: _cloudModel
        list: _cloudList
    }

    CloudList
    {
        id: _cloudList
    }

}
