import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.shelf 1.0 as Shelf


Maui.ContextualMenu
{
    id: control
    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null
    readonly property var item : control.model.get(index)

    onOpened: isFav = FB.Tagging.isFav(item.url)

    title: control.item.title
    subtitle: Maui.Handy.formatSize(control.item.size)
    titleImageSource: control.item.url
    titleIconSource: control.item.icon


    Maui.MenuItemActionRow
    {
        Action
        {
            text: i18n(isFav ? "UnFav it": "Fav it")
            checked: isFav
            checkable: true
            icon.name: "love"
            onTriggered: FB.Tagging.toggleFav(item.url)
        }

        Action
        {
            text: i18n("Tags")
            icon.name: "tag"
            onTriggered:
            {
                _dialogLoader.sourceComponent = tagsDialogComponent
                dialog.composerList.urls = filterSelection(item.url)
                dialog.open()
            }
        }

        Action
        {
            text: i18n("Info")
            icon.name: "documentinfo"
            onTriggered:
            {
                getFileInfo(item.url)
            }
        }

        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered:
            {
                Maui.Platform.shareFiles(filterSelection(item.url))
            }
        }

    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Maui.Handy.isTouch)
                root.selectionMode = true

            _selectionbar.append(item.path, item)
        }
    }

    MenuSeparator{}


    MenuItem
    {
        text: i18n("Export")
        icon.name: "document-save-as"
        onTriggered:
        {
            var pic = item.url
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.mode = dialog.modes.SAVE
            dialog.suggestedFileName= FB.FM.getFileInfo(item.url).label
            dialog.show(function(paths)
            {
                for(var i in paths)
                    FB.FM.copy(pic, paths[i])
            });
        }
    }

    MenuItem
    {
        text: i18n("Open with")
        icon.name: "document-open"
        onTriggered:
        {
            _openWithDialog.urls = filterSelection(item.url)
            _openWithDialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Go to Folder")
        icon.name: "folder-open"
        onTriggered:
        {
            var url = FB.FM.fileDir(item.url)
           openFolders([url])
        }
    }

    MenuItem
    {
        visible: !Maui.Handy.isAndroid
        text: i18n("Open Location")
        icon.name: "folder-open"
        onTriggered:
        {
            Qt.openUrlExternally(filterSelection(item.url))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Maui.Theme.textColor: Maui.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
        }
    }
}

