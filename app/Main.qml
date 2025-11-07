import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import QtQuick 2.9
import QtQuick.Controls 2.9
import QtWebEngine 1.9

MainView {
    visible: true
    id: app
    applicationName: "mapsexporter.pparent"

    Component.onCompleted: {
        // Vérifie s'il y a au moins un argument
        if (Qt.application.arguments.length > 0) {
            var firstArg = Qt.application.arguments[1];
            
            // Charge l'URL si c'est un lien
            if (firstArg.startsWith("http://") || firstArg.startsWith("https://")) {
                mapView.url = firstArg;
            }
        }
    }
    
    Column {
        anchors.fill: parent
        spacing: 0

        WebEngineView {
            id: mapView
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: navigateButton.top
            width: parent.width
            height: parent.height - units.gu(11)
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
        onUrlChanged: {
            if ( url.toString().indexOf("/place/") !== -1)
                {
                navigate.enabled=true   
                }
            else
                {
                var urlStr = url.toString();
                var latMatch = urlStr.match(/!3d([-0-9.]+)/);
                var lonMatch = urlStr.match(/!4d([-0-9.]+)/);
                if (latMatch && lonMatch) {
                    navigate.enabled=true  
                }
                else
                {
                    navigate.enabled=false   
                }
            }
        }
        
        }

        Button {
            text: "Navigate with Ubuntu Touch!"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            enabled:false
            id:navigate
            height:units.gu(11)
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
            var t = mapView.title
            var parts = t.split("–")
            console.log(t);
            var str=parts.length ? parts[0].trim() : t.trim();
            var str2=str.replace(",", ",\n")
            overlayText.text = "Taking you to\n"+ str2;
            mapView.reload();
            overlayPanel.visible=true;
            delayedTimer.start();
            }
            
            
          // Personnalisation du contenu
        contentItem: Row {
          anchors.centerIn: parent
          anchors.verticalCenter: parent.verticalCenter 
          spacing: units.gu(1)

          Text {
              text: "Navigate with Ubuntu Touch! "
              color: "black"
              font.pixelSize: 16
              font.bold: true
              font.family: "Roboto"
              anchors.verticalCenter: parent.verticalCenter 
          }

          Image {
              source: "img/Ubports-robot.png"
              width: units.gu(6)
              height: units.gu(6)
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
                var n=5;
                while ( ! (latMatch && lonMatch) )
                {
                n=n+1;
                var urlres=urlStr.slice(-n);
                var latMatch = urlres.match(/!3d([-0-9.]+)/);
                var lonMatch = urlres.match(/!4d([-0-9.]+)/);
                }
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
            width: units.gu(6)
            height: units.gu(6)
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
