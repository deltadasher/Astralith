import QtQuick
import Caelestia.Blobs
import "../.."
import "../../services"

// Optional GPL-3.0 Caelestia.Blobs-backed silhouette.  This component is only
// loaded after astralithctl has found a built native module, so the ordinary
// QML surface remains a complete fallback.
Item {
    id: root

    readonly property var layout: parent.layout
    readonly property real reveal: parent.reveal
    readonly property color tone: parent.tone
    readonly property string tab: parent.tab
    readonly property int clearance: parent.clearance

    readonly property real sourceWidth: tab === "media" ? 132
        : tab === "calendar" ? 154 : 48
    readonly property real sourceX: {
        if (tab === "calendar")
            return Math.round((width - sourceWidth) / 2);
        if (tab === "notifications" || tab === "network" || tab === "audio"
                || tab === "battery" || tab === "settings" || tab === "tools")
            return width - sourceWidth - Math.max(10, Settings.barMargin);
        if (tab === "media")
            return 248;
        if (tab === "workspaces")
            return 160;
        if (tab === "walls")
            return 72;
        if (tab === "apps")
            return 42;
        return Math.max(10, Settings.barMargin);
    }
    readonly property real sourceY: Settings.barMode === "docked"
        ? 2 : Math.max(4, Settings.barMargin)
    readonly property real sourceHeight: Settings.compact ? 34 : Theme.barHeight

    BlobGroup {
        id: shellGroup
        color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.985)
        smoothing: 20
        cornerFill: false
    }

    // One shape moves out of Aperture and becomes the final surface.  A former
    // implementation retained a second source capsule; the SDF union then
    // bridged that capsule to the popup and painted large dark lobes over the
    // bar.  With a single traveling body there is nothing left behind.
    BlobRect {
        id: body
        x: root.sourceX + (root.layout.x - root.sourceX) * root.reveal
        y: root.sourceY + (root.layout.y - root.sourceY) * root.reveal
        width: root.sourceWidth + (root.layout.width - root.sourceWidth) * root.reveal
        height: root.sourceHeight + (root.layout.height - root.sourceHeight) * root.reveal
        radius: root.sourceHeight / 2
            + (26 - root.sourceHeight / 2) * root.reveal
        group: shellGroup
        stiffness: 205
        damping: 22
        deformScale: 0.000012
        opacity: root.tab === "walls" ? 0 : 1
    }

    // A low-energy spectral seam supplies depth without returning to the old
    // outline-heavy card.  It is clipped to the popup body's final geometry.
    Rectangle {
        x: root.layout.x + 12
        y: root.layout.y
        width: Math.max(0, root.layout.width - 24)
        height: 1
        opacity: root.tab === "walls" ? 0 : root.reveal * 0.68
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.32; color: root.tone }
            GradientStop { position: 0.74; color: Theme.cyan }
            GradientStop { position: 1; color: "transparent" }
        }
    }
}
