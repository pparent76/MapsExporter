import QtQuick 2.9
import QtQuick.Controls 2.9
import QtWebEngine 1.9

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Google Maps Navigator"

    Column {
        anchors.fill: parent
        spacing: 0

        WebEngineView {
            id: mapView
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: navigateButton.top
            width: parent.width
            height: parent.height - 50
            url: "https://www.google.com/maps"
            
          profile:  WebEngineProfile {
          id: webContext
          httpUserAgent: "Mozilla/5.0 ( Linux; Mobile; Ubuntu 20.04 Like Android 9 ) Firefox/140.0.2-1"
          storageName: "Storage"
          persistentStoragePath: "/home/phablet/.cache/mapsexporter.pparent/QtWebEngine";  
        
        }//End WebEngineProfile
        
        onFeaturePermissionRequested: function(securityOrigin, feature) {
            grantFeaturePermission(securityOrigin, feature, false); 
        }
        }

        Button {
            text: "Navigate with Ubuntu Touch!"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height:100
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
            var t = mapView.title
            var parts = t.split("–")
            console.log(t);
            overlayText.text = "Taking you to\n"+ (parts.length ? parts[0].trim() : t.trim())
            mapView.reload();
            overlayPanel.visible=true;
            delayedTimer.start();
            }
            
            
          // Personnalisation du contenu
        contentItem: Row {
          anchors.centerIn: parent
          anchors.verticalCenter: parent.verticalCenter 
          spacing: 8

          Text {
              text: "Navigate with Ubuntu Touch! "
              color: "black"
              font.pixelSize: 16
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter 
          }

          Image {
              source: "img/Ubports-robot.png"
              width: 50
              height: 50
              fillMode: Image.PreserveAspectFit
              anchors.verticalCenter: parent.verticalCenter
          }
          }
          
        }
        
        
        
        Timer {
        id: delayedTimer
        interval: 1500 // 3 secondes
        repeat: true
        onTriggered: {
            // Récupère l'URL réelle de la WebView
            mapView.runJavaScript("window.location.href;", function(result) {
                var urlStr = result;
                var latMatch = urlStr.match(/!3d([-0-9.]+)/);
                var lonMatch = urlStr.match(/!4d([-0-9.]+)/);
                if (latMatch && lonMatch) {
                    var geoUri = "geo:" + latMatch[1] + "," + lonMatch[1];
                    console.log("Geo URI: " + geoUri);

                    Qt.openUrlExternally(geoUri);
                    repeat=false
                    quitTimer.start();
                } else {
                    console.log("Coordonnées introuvables dans l'URL: "+urlStr);
                }
            });
        }
            }
            
            
            
            
            
        Timer {
        id: quitTimer
        interval: 300 // 3 secondes
        repeat: true
        onTriggered: {
                    Qt.quit(); // quitte l'application après ouverture
                }
        }
            
            
// Ce composant peut être ajouté dans ton ApplicationWindow existant
Rectangle {
    id: overlayPanel
    anchors.fill: parent
    color: "#ffffff" // fond semi-transparent noir
    visible: false               // invisible par défaut
    z: 1000                      // au-dessus de tout
    opacity:0.82

    Column {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width

        // 1°) Image pleine largeur
        Image {
            id: overlayImage
            source: "img/takingYouThere.png"
            width: parent.width*0.7
             anchors.horizontalCenter: parent.horizontalCenter 
            fillMode: Image.PreserveAspectFit
        }

        // 2°) Indicateur circulaire
        BusyIndicator {
            id: loadingIndicator
            running: true
            width: 60
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // 3°) Texte sur deux lignes
        Text {
            id: overlayText
            text: "Taking you to\nLa tour eiffel"
            color: "black"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}


            
            
            
    }
}
