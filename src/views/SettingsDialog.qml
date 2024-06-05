/*
 *   Copyright 2020 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts 
import org.maui.shelf 
import org.mauikit.controls as Maui

Maui.SettingsDialog
{
    id: control

    Maui.InfoDialog
    {
        id: confirmationDialog
        property string url : ""

        title : "Remove source"
        message : "Are you sure you want to remove the source: \n "+url
        template.iconSource: "emblem-warning"

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted:
        {
            if(url.length>0)
                Library.removeSource(url)
            confirmationDialog.close()
        }

        onRejected: confirmationDialog.close()
    }

    Maui.SectionGroup
    {
        title: i18n("General")
//        description: i18n("Configure the app plugins and behavior.")

//        Maui.SectionItem
//        {
//            label1.text: i18n("Thumbnails")
//            label2.text: i18n("Show thumbnail previews")

//            Switch
//            {
//                checkable: true
//                checked: viewerSettings.fetchArtwork
//                onToggled:  viewerSettings.fetchArtwork = !viewerSettings.fetchArtwork
//            }
//        }

        Maui.SectionItem
        {
            label1.text: i18n("Auto Scan")
            label2.text: i18n("Scan all the document sources on startup to keep your collection up to date.")

            Switch
            {
                checkable: true
                checked: viewerSettings.autoScan
                onToggled: viewerSettings.autoScan = !viewerSettings.autoScan
            }
        }


        Maui.SectionItem
        {
            label1.text: i18n("Previews")
            label2.text: i18n("Display thumbnail previews.")

            Switch
            {
                checkable: true
                checked: viewerSettings.showThumbnails
                onToggled: viewerSettings.showThumbnails = !viewerSettings.showThumbnails
            }
        }

        Maui.SectionItem
        {
            visible: Maui.Handy.isAndroid

            label1.text: i18n("Dark Mode")
            label2.text: i18n("Switch between light and dark colorscheme.")

            Switch
            {
                Layout.fillHeight: true
                checked: viewerSettings.darkMode
                onToggled:
                {
                     viewerSettings.darkMode = !viewerSettings.darkMode
                    setAndroidStatusBarColor()
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Sources")
//        description: i18n("Add or remove sources")

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: Maui.Style.space.medium

            Repeater
            {

                id: _sourcesList

                model: Library.sources

                delegate: Maui.ListDelegate
                {
                    Layout.fillWidth: true
                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path

                    template.content: ToolButton
                    {
                        icon.name: "edit-clear"
                        flat: true
                        onClicked:
                        {
                            confirmationDialog.url = modelData.path
                            confirmationDialog.open()
                        }
                    }
                }
            }

            Button
            {
                Layout.fillWidth: true
                text: i18n("Add")
                //                flat: true
                onClicked:
                {
                    _dialogLoader.sourceComponent = _fileDialog
                    _dialogLoader.item.settings.onlyDirs = true
                    _dialogLoader.item.callback = function(urls)
                    {
                        Library.addSources(urls)
                    }
                    _dialogLoader.item.open()
                }
            }

            Button
            {
                Layout.fillWidth: true
                text: i18n("Scan now")
                onClicked: Library.rescan()

            }
        }
    }

}
