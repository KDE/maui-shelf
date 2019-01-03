import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.mauikit 1.0 as Maui

Maui.Editor
{
    id: _editor
    headBar.visible: false

    body.readOnly: true
    function open(filePath)
    {
        _editor.document.load("file://"+filePath)
    }
}
