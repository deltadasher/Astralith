import QtQuick
import "../.."

Item {
    id: root

    property color primary: Theme.accent
    property color secondary: Theme.cyan
    property real energy: 0
    property real phase: 0

    NumberAnimation on phase {
        from: 0
        to: 1
        duration: Settings.motion && Settings.umbraMotion ? 120000 : 1
        loops: Animation.Infinite
        running: Settings.motion && Settings.umbraMotion && root.visible
    }

    Canvas {
        id: field
        anchors.fill: parent
        opacity: 0.78

        Connections {
            target: root
            function onPhaseChanged() { field.requestPaint(); }
            function onEnergyChanged() { field.requestPaint(); }
            function onPrimaryChanged() { field.requestPaint(); }
            function onSecondaryChanged() { field.requestPaint(); }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        function rgba(color, alpha) {
            return "rgba(" + Math.round(color.r * 255) + ","
                + Math.round(color.g * 255) + ","
                + Math.round(color.b * 255) + "," + alpha + ")";
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const shortSide = Math.min(width, height);
            const rotation = root.phase * Math.PI * 2;
            const cx = width * 0.5 + Math.sin(rotation * 0.43) * shortSide
                * (0.008 + root.energy * 0.006);
            const cy = height * 0.48 + Math.cos(rotation * 0.37) * shortSide
                * (0.005 + root.energy * 0.004);

            ctx.lineWidth = Math.max(1, shortSide / 1400);
            for (let ring = 0; ring < 5; ring++) {
                const breathe = 1 + Math.sin(rotation * 0.62 + ring * 0.7)
                    * (0.004 + root.energy * 0.005);
                const radiusX = shortSide * (0.19 + ring * 0.09) * breathe;
                const radiusY = radiusX * (0.34 + ring * 0.025);
                ctx.save();
                ctx.translate(cx, cy);
                ctx.rotate(-0.17 + ring * 0.035);
                ctx.setLineDash([5 + ring * 2, 16 + ring * 3]);
                ctx.lineDashOffset = rotation * (ring % 2 === 0 ? 18 : -14);
                ctx.strokeStyle = rgba(ring % 2 === 0 ? root.primary : root.secondary,
                    0.12 + root.energy * 0.08);
                ctx.beginPath();
                ctx.ellipse(0, 0, radiusX, radiusY, 0, 0, Math.PI * 2);
                ctx.stroke();
                ctx.restore();
            }

            for (let i = 0; i < 96; i++) {
                const seed = Math.sin(i * 91.317) * 43758.5453;
                const seed2 = Math.sin((i + 17) * 47.11) * 12973.22;
                const px = (seed - Math.floor(seed)) * width;
                const py = (seed2 - Math.floor(seed2)) * height;
                const pulse = 0.38 + 0.62 * Math.abs(Math.sin(rotation * (0.35 + i % 5 * 0.08) + i));
                const size = 0.55 + (i % 7 === 0 ? 1.25 : i % 3 === 0 ? 0.65 : 0.25);
                ctx.fillStyle = rgba(i % 9 === 0 ? root.secondary : Theme.moon,
                    0.16 + pulse * 0.34);
                ctx.beginPath();
                ctx.arc(px, py, size, 0, Math.PI * 2);
                ctx.fill();
            }

            for (let satellite = 0; satellite < 4; satellite++) {
                const angle = rotation * (satellite % 2 === 0 ? 0.42 : -0.31)
                    + satellite * Math.PI * 0.5;
                const orbitX = shortSide * (0.27 + satellite * 0.055);
                const orbitY = orbitX * 0.38;
                const x = cx + Math.cos(angle) * orbitX;
                const y = cy + Math.sin(angle) * orbitY;
                const glow = 3 + root.energy * 4 + satellite;
                const gradient = ctx.createRadialGradient(x, y, 0, x, y, glow * 3.2);
                gradient.addColorStop(0, rgba(satellite % 2 ? root.secondary : root.primary, 0.72));
                gradient.addColorStop(1, rgba(root.primary, 0));
                ctx.fillStyle = gradient;
                ctx.beginPath();
                ctx.arc(x, y, glow * 3.2, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = rgba(Theme.moon, 0.9);
                ctx.beginPath();
                ctx.arc(x, y, 1.4 + root.energy, 0, Math.PI * 2);
                ctx.fill();
            }
        }
    }
}
