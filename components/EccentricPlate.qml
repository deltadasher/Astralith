import QtQuick
import ".."

Canvas {
    id: root

    property color fillColor: Theme.glass
    property color lineColor: Theme.barHairlineHover
    property color tone: Theme.accent
    property real cut: 18
    property real energy: 0
    property real lineWidth: 1

    antialiasing: true

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onFillColorChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onToneChanged: requestPaint()
    onCutChanged: requestPaint()
    onEnergyChanged: requestPaint()
    onLineWidthChanged: requestPaint()

    function rgba(color, alpha) {
        return "rgba(" + Math.round(color.r * 255) + ","
            + Math.round(color.g * 255) + ","
            + Math.round(color.b * 255) + "," + alpha + ")";
    }

    function platePath(ctx, inset) {
        const x = inset;
        const y = inset;
        const w = Math.max(0, width - inset * 2);
        const h = Math.max(0, height - inset * 2);
        const c = Math.max(6, Math.min(root.cut - inset, Math.min(w, h) * 0.24));

        ctx.beginPath();
        ctx.moveTo(x + c, y);
        ctx.lineTo(x + w - c * 0.58, y);
        ctx.lineTo(x + w, y + c * 0.58);
        ctx.lineTo(x + w, y + h - c);
        ctx.lineTo(x + w - c, y + h);
        ctx.lineTo(x + c * 0.48, y + h);
        ctx.lineTo(x, y + h - c * 0.48);
        ctx.lineTo(x, y + c);
        ctx.closePath();
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        platePath(ctx, root.lineWidth * 0.5);
        ctx.fillStyle = root.fillColor.toString();
        ctx.fill();
        ctx.lineWidth = root.lineWidth;
        ctx.strokeStyle = root.lineColor.toString();
        ctx.lineJoin = "miter";
        ctx.stroke();

        const c = Math.max(8, root.cut);
        const wake = Math.max(0, Math.min(1, root.energy));
        ctx.lineWidth = 1;
        ctx.strokeStyle = rgba(root.tone, 0.28 + wake * 0.28);

        ctx.beginPath();
        ctx.moveTo(c + 11, 1.5);
        ctx.lineTo(Math.min(width * 0.28, c + 106 + wake * 32), 1.5);
        ctx.stroke();

        ctx.beginPath();
        ctx.moveTo(width - 1.5, height - c + 7);
        ctx.lineTo(width - c + 7, height - 1.5);
        ctx.lineTo(Math.max(width * 0.78, width - c - 62 - wake * 24), height - 1.5);
        ctx.stroke();

        ctx.fillStyle = rgba(root.tone, 0.62 + wake * 0.28);
        ctx.beginPath();
        ctx.arc(c + 5, 1.5, 1.5 + wake, 0, Math.PI * 2);
        ctx.fill();
    }
}
