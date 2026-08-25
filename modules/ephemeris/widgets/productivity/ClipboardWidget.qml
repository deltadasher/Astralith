import QtQuick
import "../../../transit"

Item {
    id: root
    function focusPrimary() { clipboardPane.focusSearch(); }
    ClipboardPane { id: clipboardPane; anchors.fill: parent }
}
