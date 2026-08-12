// Dotsequences
// Based on https://github.com/Keyitdev/sddm-astronaut-theme
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Effects

import "Components"

Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.ScreenWidth
    padding: 0

    LayoutMirroring.enabled: config.RightToLeftLayout == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    palette.window: config.BackgroundColor
    palette.highlight: config.HighlightBackgroundColor
    palette.highlightedText: config.HighlightTextColor
    palette.buttonText: config.HoverSystemButtonsIconsColor

    font.family: config.Font
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80) || 13
    
    focus: true

    property bool leftleft: config.HaveFormBackground == "true" &&
                            config.FormPosition == "left" &&
                            config.BackgroundHorizontalAlignment == "left"

    property bool leftcenter: config.HaveFormBackground == "true" &&
                              config.FormPosition == "left" &&
                              config.BackgroundHorizontalAlignment == "center"

    property bool rightright: config.HaveFormBackground == "true" &&
                              config.FormPosition == "right" &&
                              config.BackgroundHorizontalAlignment == "right"

    property bool rightcenter: config.HaveFormBackground == "true" &&
                               config.FormPosition == "right" &&
                               config.BackgroundHorizontalAlignment == "center"

    Item {
        id: sizeHelper

        height: parent.height
        width: parent.width
        anchors.fill: parent
        
        Rectangle {
            id: tintLayer

            height: parent.height
            width: parent.width
            anchors.fill: parent
            z: 1
            color: config.DimBackgroundColor
            opacity: config.DimBackground
        }

        Rectangle {
            id: formBackground
        
            anchors.fill: form
            anchors.centerIn: form
            z: 1
        
            color: "#000000"
            radius: 16

			border.color: "#00f0ff"
			border.width: 2
            
            clip: true   // ← clave: corta todo lo que salga fuera
            visible: config.HaveFormBackground == "true" ? true : false
            antialiasing: true
        }

        LoginForm {
            id: form

            height: parent.height / 1.6
            width: parent.width / 2.75
            anchors.left: config.FormPosition == "left" ? parent.left : undefined
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined
            anchors.verticalCenter: config.FormPosition == "center" ? parent.verticalCenter : undefined
            anchors.right: config.FormPosition == "right" ? parent.right : undefined
            z: 1
        }

        AnimatedImage {
            id: backgroundImage

            source: config.Background

            height: parent.height
            width: config.HaveFormBackground == "true" && config.FormPosition != "center" ? parent.width - formBackground.width : parent.width
            anchors.left: leftleft || leftcenter ? formBackground.right : undefined
            anchors.right: rightright || rightcenter ? formBackground.left : undefined

            horizontalAlignment: config.BackgroundHorizontalAlignment == "left" ?
                                 Image.AlignLeft :
                                 config.BackgroundHorizontalAlignment == "right" ?
                                 Image.AlignRight : Image.AlignHCenter

            verticalAlignment: config.BackgroundVerticalAlignment == "top" ?
                               Image.AlignTop :
                               config.BackgroundVerticalAlignment == "bottom" ?
                               Image.AlignBottom : Image.AlignVCenter

            speed: 1.0
            paused: false
            fillMode: config.CropBackground == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            asynchronous: true
            cache: true
            clip: true
            mipmap: true
        }

        MouseArea {
            anchors.fill: backgroundImage
            onClicked: parent.forceActiveFocus()
        }

        MultiEffect {
            id: blur

            height: parent.height

            // This solves problem when FullBlur and HaveFormBackground is set to true but FormPosition isn't center.
            width: (config.FullBlur == "true" && config.FormPosition != "center" ) ? parent.width - formBackground.width : config.FullBlur == "true" ? parent.width : form.width
            anchors.centerIn: config.FullBlur == "true" ? backgroundImage : form

            source: backgroundImage
            blurEnabled: true
            autoPaddingEnabled: false
            blur: 2.0
            blurMax: config.BlurMax == "" ? 48 : config.BlurMax
            visible: config.FullBlur == "true" ? true : false
        }
    }
}
