import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.1 as Kirigami
import org.kde.okular 2.0 as Okular
import EPUB 1.0 as EPUB

Maui.Page
{
    id: root

    property string file;
   property int currentPage;
    property int pageCount;
    property var pagesModel;

     headBarTitle: documentItem.windowTitleForDocument;
 onFileChanged: documentItem.url = "file://"+file;
    Okular.DocumentItem
    {
        id: documentItem
        //         onWindowTitleForDocumentChanged: {
        //             fileBrowserRoot.title = windowTitleForDocument
        //         }
        onOpenedChanged: {
            if(opened === true) {
//                root.loadingCompleted(true);
//                initialPageChange.start();
            }
        }
        onCurrentPageChanged: {
            if(root.currentPage !== currentPage) {
                root.currentPage = currentPage;
            }
        }
    }

    ListView
    {
        id: imageBrowser
        anchors.fill: parent;
        model: documentItem.matchingPages;

        property int imageWidth: root.width + Kirigami.Units.largeSpacing;
        property int imageHeight: root.height;

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        // This ensures that the current index is always up to date, which we need to ensure we can track the current page
        // as required by the thumbnail navigator, and the resume-reading-from functionality
        onMovementEnded: {
            var indexHere = indexAt(contentX + width / 2, contentY + height / 2);
            if(currentIndex !== indexHere) {
                currentIndex = indexHere;
            }
        }

        delegate: Flickable
        {
            id: flick
            width: imageBrowser.imageWidth
            height: imageBrowser.imageHeight
            contentWidth: imageBrowser.imageWidth
            contentHeight: imageBrowser.imageHeight
            interactive: contentWidth > width || contentHeight > height
            onInteractiveChanged: imageBrowser.interactive = !interactive;
            z: interactive ? 1000 : 0
            PinchArea {
                width: Math.max(flick.contentWidth, flick.width)
                height: Math.max(flick.contentHeight, flick.height)

                property real initialWidth
                property real initialHeight

                onPinchStarted: {
                    initialWidth = flick.contentWidth
                    initialHeight = flick.contentHeight
                }

                onPinchUpdated: {
                    // adjust content pos due to drag
                    flick.contentX += pinch.previousCenter.x - pinch.center.x
                    flick.contentY += pinch.previousCenter.y - pinch.center.y

                    // resize content
                    flick.resizeContent(Math.max(imageBrowser.imageWidth, initialWidth * pinch.scale), Math.max(imageBrowser.imageHeight, initialHeight * pinch.scale), pinch.center)
                }

                onPinchFinished: {
                    // Move its content within bounds.
                    flick.returnToBounds();
                }

                Item {
                    Okular.PageItem {
                        id: page;
                        document: documentItem;
                        pageNumber: index;
                        anchors.centerIn: parent;
                        property real pageRatio: implicitWidth / implicitHeight
                        property bool sameOrientation: root.width / root.height > pageRatio
                        width: sameOrientation ? parent.height * pageRatio : parent.width
                        height: !sameOrientation ? parent.width / pageRatio : parent.height
                    }
                    implicitWidth: page.implicitWidth
                    implicitHeight: page.implicitHeight
                    width: flick.contentWidth
                    height: flick.contentHeight
                    MouseArea {
                        anchors.fill: parent
                        onClicked: startToggleControls();
                        onDoubleClicked: {
                            abortToggleControls();
                            if (flick.interactive) {
                                flick.resizeContent(imageBrowser.imageWidth, imageBrowser.imageHeight, {x: imageBrowser.imageWidth/2, y: imageBrowser.imageHeight/2});
                            } else {
                                flick.resizeContent(imageBrowser.imageWidth * 2, imageBrowser.imageHeight * 2, {x: mouse.x, y: mouse.y});
                            }
                        }
                    }
                }
            }
        }
    }

    function open(filePath)
    {
        root.file = filePath
    }
}
