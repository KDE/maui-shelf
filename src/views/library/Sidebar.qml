import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import QtQuick.Layouts 1.12

import org.maui.shelf 1.0 as Shelf

Loader
{
    id: control
    asynchronous: true
    sourceComponent: Maui.ListBrowser
    {
        id: _listBrowser

        model: Maui.BaseModel
        {
            list: Shelf.PlacesList
            {
                id: _placesList
            }
        }

        delegate: Maui.ListDelegate
        {
            isCurrentItem: sources.indexOf(model.path) >= 0
            width: ListView.view.width
            label: model.tag
            iconSize: Maui.Style.iconSize
            iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
            iconVisible: true
            template.isMask: iconSize <= Maui.Style.iconSizes.medium

            onClicked: openFolders([model.path])

        }

        section.property: "type"
        section.criteria: ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            width: ListView.view.width
            label: section
            isSection: true
            //                height: Maui.Style.toolBarHeightAlt
        }

        holder.visible: count === 0
        holder.title: i18n("Tags!")
        holder.body: i18n("Your tags will be listed here")

        flickable.topMargin: Maui.Style.contentMargins
        flickable.bottomMargin: Maui.Style.contentMargins
        flickable.header: Loader
        {
            asynchronous: true
            width: parent.width
            visible: active

            sourceComponent: Item
            {
                implicitHeight: _quickSection.implicitHeight

                GridLayout
                {
                    id: _quickSection
                    width: Math.min(parent.width, 180)
                    anchors.centerIn: parent
                    rows: 3
                    columns: 3
                    columnSpacing: Maui.Style.defaultPadding
                    rowSpacing: Maui.Style.defaultPadding

                    Repeater
                    {
                        model: _placesList.quickPlaces

                        delegate: Maui.GridBrowserDelegate
                        {
                            Layout.preferredHeight: Math.min(50, width)
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.columnSpan: (modelData.path === "collection:///" ? 3 : (modelData.path === "tags:///fav" ? 2 : 1))
                            isCurrentItem: sources.indexOf(modelData.path) >= 0
                            iconSource: modelData.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true
                            label1.text: modelData.label
                            labelsVisible: false
                            tooltipText: modelData.label
                            flat: false
                            onClicked:
                            {
                                //[".cbz", ".cbr"]
                                openFolders([modelData.path])
                                if(sideBar.collapsed)
                                    sideBar.close()
                            }
                        }

                    }
                }
            }
        }
    }
}
