import QtQuick
import "../.."

Item {
    id: root

    property string module: "apps"
    property real presentation: 1
    property real phase: 0
    readonly property color primary: Theme.moduleAccent(module)
    readonly property color secondary: Theme.moduleSecondary(module)
    readonly property real density: Settings.atmosphereStyle === "quiet" ? 0.62
        : Settings.atmosphereStyle === "cinematic" ? 1.42 : 1
    readonly property int starCount: Settings.atmosphereStyle === "quiet" ? 8
        : Settings.atmosphereStyle === "cinematic" ? 18 : 12

    clip: true
    opacity: Settings.animateStars ? Math.min(0.72, 0.48 * density) * presentation : 0
    visible: opacity > 0.001

    Timer {
        interval: 50
        repeat: true
        running: Settings.motion && root.visible
        onTriggered: root.phase = (root.phase + 0.0035) % 1
    }

    Rectangle {
        width: Math.min(parent.width * 0.72, 760)
        height: width
        radius: width / 2
        x: -width * 0.34 + Math.sin(root.phase * Math.PI * 2) * 14
        y: parent.height * 0.20 - height * 0.48
        color: root.primary
        opacity: 0.035 * root.density
        Behavior on color { ColorAnimation { duration: 420 } }
    }

    Rectangle {
        width: Math.min(parent.width * 0.58, 620)
        height: width
        radius: width / 2
        x: parent.width - width * 0.62 + Math.cos(root.phase * Math.PI * 2) * 12
        y: parent.height - height * 0.56
        color: root.secondary
        opacity: 0.026 * root.density
        Behavior on color { ColorAnimation { duration: 420 } }
    }

    Canvas {
        id: orbitalCanvas
        anchors.fill: parent

        Connections {
            target: root
            function onPhaseChanged() { orbitalCanvas.requestPaint(); }
            function onPrimaryChanged() { orbitalCanvas.requestPaint(); }
            function onSecondaryChanged() { orbitalCanvas.requestPaint(); }
            function onWidthChanged() { orbitalCanvas.requestPaint(); }
            function onHeightChanged() { orbitalCanvas.requestPaint(); }
        }

        function traceEllipse(ctx, centerX, centerY, radiusX, radiusY, rotation) {
            ctx.save();
            ctx.translate(centerX, centerY);
            ctx.rotate(rotation);
            ctx.scale(radiusX, radiusY);
            ctx.beginPath();
            ctx.arc(0, 0, 1, 0, Math.PI * 2);
            ctx.restore();
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const centerX = width * 0.53;
            const centerY = height * 0.55;
            const rotation = -0.12;

            ctx.save();
            ctx.lineWidth = root.density > 1 ? 1.25 : 1;
            ctx.setLineDash([5, 11]);
            ctx.strokeStyle = Qt.rgba(root.primary.r, root.primary.g,
                root.primary.b, 0.20 + root.density * 0.04).toString();
            traceEllipse(ctx, centerX, centerY, width * 0.36, height * 0.27, rotation);
            ctx.stroke();

            ctx.setLineDash([2, 15]);
            ctx.strokeStyle = Qt.rgba(root.secondary.r, root.secondary.g,
                root.secondary.b, 0.13 + root.density * 0.04).toString();
            traceEllipse(ctx, centerX, centerY, width * 0.27, height * 0.38, rotation + 0.46);
            ctx.stroke();
            ctx.restore();

            for (let index = 0; index < 9; index++) {
                const angle = root.phase * Math.PI * 2 + index * Math.PI * 2 / 9;
                const x = centerX + Math.cos(angle + rotation) * width * 0.36;
                const y = centerY + Math.sin(angle + rotation) * height * 0.27;
                ctx.beginPath();
                ctx.arc(x, y, index % 3 === 0 ? 2.2 : 1.25, 0, Math.PI * 2);
                ctx.fillStyle = (index % 2 === 0 ? root.primary : root.secondary).toString();
                ctx.globalAlpha = index % 3 === 0 ? 0.45 : 0.24;
                ctx.fill();
            }
            ctx.globalAlpha = 1;
        }
    }

    Item {
        id: comet
        visible: Settings.atmosphereStyle !== "quiet"
        readonly property real travel: root.phase * Math.PI * 2
        readonly property real headX: -20 + root.phase * (root.width + 40)
        readonly property real headY: root.height * 0.20
            + Math.sin(travel) * root.height * 0.08
        readonly property real velocityX: root.width + 40
        readonly property real velocityY: Math.cos(travel) * Math.PI * 2
            * root.height * 0.08
        width: Settings.atmosphereStyle === "cinematic" ? 138 : 88
        height: Settings.atmosphereStyle === "cinematic" ? 8 : 5
        x: headX - width
        y: headY - height / 2
        transformOrigin: Item.Right
        rotation: Math.atan2(velocityY, velocityX) * 180 / Math.PI
        opacity: Settings.atmosphereStyle === "cinematic" ? 0.42 : 0.22

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.76; color: root.primary }
                GradientStop { position: 1; color: Theme.moon }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height
            height: width
            radius: width / 2
            color: Theme.moon
            opacity: 0.9

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 2.8
                height: width
                radius: width / 2
                color: root.primary
                opacity: 0.18
            }
        }
    }

    Repeater {
        model: root.starCount
        Rectangle {
            required property int index
            x: ((index * 211 + 67) % Math.max(1, root.width - 12))
            y: 36 + ((index * 127 + 43) % Math.max(1, root.height - 72))
            width: index % 4 === 0 ? 3 : 2
            height: width
            radius: width / 2
            color: index % 3 === 0 ? root.primary : Theme.moon
            opacity: 0.14 + (index % 3) * 0.045
            SequentialAnimation on scale {
                running: Settings.motion && root.visible
                loops: Animation.Infinite
                PauseAnimation { duration: index * 90 }
                NumberAnimation { to: 1.8; duration: 900 + index * 45; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 1100 + index * 39; easing.type: Easing.InOutSine }
            }
        }
    }
}
