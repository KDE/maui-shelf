import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control

    property alias webView : _viewerLoader.item
    readonly property string pdfjs : "/views/Viewer/pdfjs/web/viewer.html"

    Loader
    {
        id: _viewerLoader
        anchors.fill: parent
        source: isAndroid ? "qrc:/views/Viewer/WebView_Android.qml" :
                            "qrc:/views/Viewer/WebView.qml"
    }

    function open(url)
    {
        webView.url = pdfjs+"?file="+url;
    }
}
