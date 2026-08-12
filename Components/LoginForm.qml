// Dotsequences
// Based on https://github.com/Keyitdev/sddm-astronaut-theme
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects 1.15
import SddmComponents 2.0 as SDDM

ColumnLayout {
    id: formContainer
    SDDM.TextConstants { id: textConstants }

	Clock {
        id: clock

        Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: 20
        Layout.bottomMargin: 20
    }
	
	Item {
	    id: profileContainer
	    Layout.alignment: Qt.AlignHCenter
	    Layout.topMargin: 15
	    Layout.preferredHeight: root.height / 4
	    Layout.preferredWidth: root.height / 4
	
	    // ── 1. Base circular que genera el glow ──────────────────────────────
	    Rectangle {
	        id: glowSource
	        anchors.centerIn: parent
	        width: parent.width
	        height: parent.height
	        radius: width / 2          // círculo perfecto
	        color: "#ffffff"           // color del glow (cámbialo a tu gusto)
	        visible: false             // solo existe como fuente del efecto
	    }
	
	    // ── 2. El glow en sí ─────────────────────────────────────────────────
	    Glow {
	        anchors.fill: glowSource
	        source: glowSource
	        radius: 28                 // qué tan grande/difuso es el halo
	        samples: 32                // calidad (potencia de 2 + 1, o múltiplo)
	        color: config.ProfileGlowColor          // color del halo — ajusta a tu paleta
	        spread: 0.15               // 0 = muy difuso, 1 = borde duro
	        transparentBorder: true

	    }
	
	    // ── 3. La imagen rotatoria (encima del glow) ─────────────────────────
	    Image {
	        id: rotatingProfile
	        anchors.centerIn: parent
	        width: parent.width
	        height: parent.height
	
	        source: config.ProfileImage
	        fillMode: Image.PreserveAspectFit
	        antialiasing: true
	
            // Giro lento normal
            RotationAnimator {
                target: rotatingProfile
                from: 0
                to: 360
                duration: 15000
                loops: Animation.Infinite
                running: true
            }
	    }
	}
	
    Input {
        id: input
        Layout.preferredHeight: root.height / 100  // era /10 → ×0.8
        Layout.topMargin: 0
        Layout.bottomMargin: 35
    }
    SystemButtons {
        id: systemButtons
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: root.height / 5
        Layout.maximumHeight: root.height / 5
        Layout.topMargin: 10
        exposedSession: input.exposeSession
    }
    SessionButton {
        id: sessionSelect
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 8
        implicitHeight: root.height / 27
        height: root.height / 27
    }
}
