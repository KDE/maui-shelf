import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui

import LibraryModel 1.0
import LibraryList 1.0

Maui.Page
{
id: control

Maui.GridBrowser
{
    id: _gridBrowser
    anchors.fill: parent
itemSize : iconSizes.huge + fontSizes.default
model: _libraryModel

}

LibraryModel
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
