import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 20000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        Image {
            id: background1
            source: "miku-cosmic-night.jpg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.9
            color: "#66000000"
        }
        Text {
            anchors.centerIn: parent
            text: "MiKuOS"
            font.pixelSize: 48
            color: "#39c5bb"
            horizontalAlignment: Text.Center
            width: parent.width
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 10
            text: "A fresh COSMIC Linux, themed around the diva of the digital void."
            font.pixelSize: 18
            color: "#c3d4f2"
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.Center
        }
    }

    Slide {
        Image {
            id: background2
            source: "miku-space.jpg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.9
            color: "#66000000"
        }
        Text {
            anchors.top: parent.verticalCenter
            anchors.topMargin: -40
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Beautiful"
            font.pixelSize: 30
            color: "#8ffdff"
            horizontalAlignment: Text.Center
            width: parent.width
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 20
            text: "The COSMIC desktop feels fast and smooth,<br/>right out of the box."
            font.pixelSize: 18
            color: "#c3d4f2"
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.Center
        }
    }

    Slide {
        Image {
            id: background3
            source: "miku-starfield.jpg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.9
            color: "#66000000"
        }
        Text {
            anchors.top: parent.verticalCenter
            anchors.topMargin: -40
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Reliable"
            font.pixelSize: 30
            color: "#8ffdff"
            horizontalAlignment: Text.Center
            width: parent.width
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 20
            text: "Reproducible builds and atomic upgrades,<br/>driven by a single configuration file."
            font.pixelSize: 18
            color: "#c3d4f2"
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.Center
        }
    }

    function onActivate() {
        presentation.currentSlide = 0;
    }

    function onLeave() {
    }
}