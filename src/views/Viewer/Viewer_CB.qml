import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.mauikit.documents 1.0 as Peruse

Maui.Page
{
    id: control
    property string path

    title: _model.title
    property int imageWidth : control.width
    property int imageHeight : control.height

    property bool twoPagesMode : true
    property alias orientation : _listView.orientation

    headBar.visible: false

    footBar.leftContent: ToolButton
    {
        icon.name: "view-dual-symbolic"
        checked: control.twoPagesMode
        onClicked: control.twoPagesMode = !control.twoPagesMode
    }

    ListView
    {
        id: _listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: control.twoPagesMode ? ListView.SnapPosition : ListView.SnapOneItem
        cacheBuffer: 3000

        onMovementEnded:
        {
            var indexHere = indexAt(contentX + width / 2, contentY + height / 2);
            if(currentIndex !== indexHere) {
                currentIndex = indexHere;
            }
        }

        model: Peruse.ArchiveBookModel
        {
            id: _model
            qmlEngine: globalQmlEngine
            onLoadingCompleted: {
                //                root.loadingCompleted(success);
                //                if (success) {
                //                    initialPageChange.start();
                //                    for (var i = 0 ; i < root.languageCount; ++i) {
                //                        var language = imageBrowser.model.acbfData.metaData.bookInfo.languages[i];
                //                        var action = translationActionEntry.createObject(translationsAction, {language: language});
                //                        translationsAction.children.push(action);
                //                    }
                //                }
            }
        }

        delegate: Maui.ImageViewer
        {
            source: model.url
            height: ListView.view.height
            width: Math.floor(ListView.view.width / (control.twoPagesMode ? 2 : 1))
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            //                                            property bool shouldCheat: imageWidth * 2 > maxTextureSize || imageHeight * 2 > maxTextureSize;
            //                                                           property bool isTall: imageHeight < imageWidth;
            //                                                           property int fixedWidth: isTall ? maxTextureSize * (imageWidth / imageHeight) : maxTextureSize;
            //                                                           property int fixedHeight: isTall ? maxTextureSize : maxTextureSize * (imageHeight / imageWidth);
            //                                                           sourceSize.width: shouldCheat ? fixedWidth : imageWidth * 2;
            //                                                           sourceSize.height: shouldCheat ? fixedHeight : imageHeight * 2;
        }
    }

    Component.onCompleted:  _model.filename = control.path.replace("file://", "")

}
