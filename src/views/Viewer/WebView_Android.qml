import QtQuick 2.9
import QtWebView 1.1

WebView
{
    id: webView
    anchors.fill: parent
    visible: false
    clip: true
    onLoadingChanged:
    {
        if (loadRequest.errorString)
            console.error(loadRequest.errorString);
    }

//    onRecentlyAudibleChanged:
//    {
//        console.log("is playing", recentlyAudible)
//        if(recentlyAudible && isPlaying)
//            Player.pauseTrack()

//        if(!recentlyAudible && wasPlaying)
//            Player.resumeTrack()
//    }
}
