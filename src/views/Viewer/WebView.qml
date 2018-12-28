import QtQuick 2.9

import QtWebEngine 1.5

WebEngineView
{
    id: webView
    anchors.fill: parent
    visible: true   

    onLoadingChanged:
    {
        if (loadRequest.errorString)
            console.error(loadRequest.errorString);
    }  
}
