// Dotsequences
// Based on https://github.com/Keyitdev/sddm-astronaut-theme
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html

import QtQuick 2.15
import QtQuick.Controls 2.15

import "../phrases.js" as PhrasesData

Item {
    id: clock
    width: parent.width / 4
    height: typeLabel.height

    // ── Frases personalizadas ────
    property var fallbackPhrases: [
        "The cake is a lie",
        "Password will be always with you"
    ]
    property var customPhrases: PhrasesData.list && PhrasesData.list.length > 0 ? PhrasesData.list : fallbackPhrases

    // ── Configuración ──────────────────────────────────────────
    property int  typingSpeed:  50    // ms por letra al escribir
    property int  deletingSpeed: 10   // ms por letra al borrar
    property int  pauseAfterType: 2000 // ms de pausa tras escribir completo

	// ── Estados del ciclo ──────────────────────────────────────
	// 0 → frase aleatoria
	// 1 → hora
	// 2 → frase aleatoria
	// 3 → fecha
	property int phraseIndex: 0

    // ── Estado interno ─────────────────────────────────────────
    property int  charIndex:     0    // cuántas letras visibles ahora
    property bool isDeleting:    false
    property string currentFull: ""  // texto completo de la fase actual
    property int lastCustomIndex: -1  // evita repetir la misma dos veces seguidas

    // ── Etiqueta única ─────────────────────────────────────────
    Label {
        id: typeLabel
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: root.font.pointSize * 2.75
        font.bold: true
        color: config.TimeTextColor
        renderType: Text.QtRendering
        text: ""
    }

    // ── Cursor parpadeante ─────────────────────────────────────
    Label {
        id: cursor
        anchors.left: typeLabel.right
        anchors.verticalCenter: typeLabel.verticalCenter
        font.pointSize: typeLabel.font.pointSize
        color: config.TimeTextColor
        text: "|"
        Timer {
            interval: 500
            repeat: true
            running: true
            onTriggered: cursor.visible = !cursor.visible
        }
    }

    // ── Timer de typing (letra a letra) ───────────────────────
    Timer {
        id: typingTimer
        interval: clock.isDeleting ? clock.deletingSpeed : clock.typingSpeed
        repeat: true
        running: false

        onTriggered: {
            if (!clock.isDeleting) {
                // Escribiendo
                clock.charIndex++
                typeLabel.text = clock.currentFull.substring(0, clock.charIndex)
                if (clock.charIndex >= clock.currentFull.length) {
                    typingTimer.stop()
                    pauseTimer.start()
                }
            } else {
                // Borrando
                clock.charIndex--
                typeLabel.text = clock.currentFull.substring(0, clock.charIndex)
                if (clock.charIndex <= 0) {
                    typingTimer.stop()
                    // Pasar a la siguiente frase
                    clock.phraseIndex = (clock.phraseIndex + 1) % 4
                    clock.isDeleting = false
                    loadCurrentPhrase()
                    typingTimer.start()
                }
            }
        }
    }

    // ── Timer de pausa (tras escribir completo) ────────────────
    Timer {
        id: pauseTimer
        interval: clock.pauseAfterType
        repeat: false
        onTriggered: {
            clock.isDeleting = true
            typingTimer.start()
        }
    }

    // ── Función: carga la frase actual ─────────────────────────
    function loadCurrentPhrase() {
        switch (clock.phraseIndex) {
            case 0:
            case 2:
                clock.currentFull = getRandomPhrase()
                break
            case 1:
                clock.currentFull = new Date().toLocaleTimeString(
                    Qt.locale(),
                    config.HourFormat == "long" ? Locale.LongFormat :
                    config.HourFormat !== "" ? config.HourFormat : Locale.ShortFormat
                )
                break
            case 3:
                clock.currentFull = new Date().toLocaleDateString(
                    Qt.locale(),
                    config.DateFormat == "short" ? Locale.ShortFormat :
                    config.DateFormat !== "" ? config.DateFormat : Locale.LongFormat
                )
                break
        }
        clock.charIndex = 0
    }

    // ── Frase aleatoria sin repetir la anterior ────────────────
    function getRandomPhrase() {
        if (clock.customPhrases.length === 0)
            return ""

        if (clock.customPhrases.length === 1)
            return clock.customPhrases[0]

        var idx
        do {
            idx = Math.floor(Math.random() * clock.customPhrases.length)
        } while (idx === clock.lastCustomIndex)

        clock.lastCustomIndex = idx
        return clock.customPhrases[idx]
    }

    // ── Arranque ───────────────────────────────────────────────
    Component.onCompleted: {
        loadCurrentPhrase()
        typingTimer.start()
    }
}
