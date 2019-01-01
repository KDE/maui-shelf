import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui
import PdfViewing 1.0

Maui.Page
{
    id: control
    headBarTitle: pdf.info.title
height: 500
width: 200

Rectangle
{
    anchors.fill: parent
    color: "yellow"
}

    PdfViewer {
           id: pdf

           Rectangle
           {
               anchors.fill: parent
               color: "yellow"
           }

           anchors.top: parent.top
           anchors.bottom: buttons.top
           anchors.right: parent.right
           anchors.left: parent.left
           backgroundColor: "#eee"
           renderImageAntiAliased: true
           renderTextAntiAliased: true

           onZoomChanged: zoomSlider.value = (zoom - pdf.fitZoom) / (maxZoom - 1)

           Keys.onPressed: {

                   switch(event.key)
                   {
                   case Qt.Key_W:
                       pdf.pan.y += 10
                       break

                   case Qt.Key_S:
                       pdf.pan.y -= 10
                       break

                   case Qt.Key_A:
                       pdf.pan.x += 10
                       break

                   case Qt.Key_D:
                       pdf.pan.x -= 10
                       break

                   case Qt.Key_E:
                       pdf.rotatePageClockwise()
                       break

                   case Qt.Key_Q:
                       pdf.rotatePageCounterClockwise()
                       break

                   case Qt.Key_Plus:
                       pdf.zoomIn(1.1)
                       break

                   case Qt.Key_Minus:
                       pdf.zoomOut(1.1)
                       break

                   case Qt.Key_Y:
                       pdf.pageNumber--
                       break

                   case Qt.Key_X:
                       pdf.pageNumber++
                       break

                   case Qt.Key_R:
                       pdf.zoom = pdf.fitZoom
                       pdf.pan = pdf.fitPan
                       break

                   case Qt.Key_F:
                       pdf.zoom = pdf.coverZoom
                       pdf.pan = pdf.coverPan
                       break

                   default:
                       break
                   }
               }
       }
}
