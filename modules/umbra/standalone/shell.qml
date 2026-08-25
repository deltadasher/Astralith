//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../.."
import "../../../services"
import ".."

ShellRoot {
    id: root

    Component.onCompleted: stateDelay.start()

    Timer {
        id: stateDelay
        interval: 0
        onTriggered: {
            Umbra.lock();
            if (!sessionLock.locked) {
                Umbra.active = false;
                Umbra.failed = true;
                Umbra.statusText = "SESSION LOCK PROTOCOL UNAVAILABLE";
                Umbra.eventSerial++;
                Qt.quit();
            }
        }
    }

    Connections {
        target: Umbra
        function onUnlocked() {
            sessionLock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: sessionLock

        // This literal remains true across Quickshell hot reloads. Authentication
        // is the only code path that assigns false before the process exits.
        locked: true

        onSecureStateChanged: Umbra.secure = secure
        onLockStateChanged: {
            if (!locked && Umbra.active) {
                Umbra.active = false;
                Umbra.secure = false;
                Umbra.failed = true;
                Umbra.statusText = "SESSION LOCK PROTOCOL UNAVAILABLE";
                Umbra.eventSerial++;
                Qt.quit();
            }
        }

        WlSessionLockSurface {
            id: lockSurface
            color: Theme.void_

            UmbraSurface {
                anchors.fill: parent
                screenInfo: lockSurface.screen
            }
        }
    }
}
