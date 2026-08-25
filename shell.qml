//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import "modules/aperture"
import "modules/ephemeris"
import "modules/osd"
import "modules/quickactions"
import "modules/transit"
import "modules/umbra"
import "services"

ShellRoot {
    IpcHandler {
        target: "ephemeris"

        function close(): void {
            ShellState.closeEphemeris();
        }

        function open(tab: string): void {
            ShellState.openEphemeris(tab);
        }

        function toggle(tab: string): void {
            ShellState.toggleEphemeris(tab);
        }
    }

    IpcHandler {
        target: "transit"

        function preview(summary: string, body: string): void {
            Notifications.preview(summary, body);
        }
    }

    IpcHandler {
        target: "quickactions"

        function open(tab: string): void {
            ShellState.openQuickActions(tab);
        }

        function toggle(tab: string): void {
            ShellState.toggleQuickActions(tab);
        }

        function hide(): void {
            ShellState.hideQuickActions();
        }
    }

    IpcHandler {
        target: "umbra"

        function lock(): void {
            ShellState.closeEphemeris();
            ShellState.hideQuickActions();
            Umbra.launchLock();
        }

        function preview(): void {
            ShellState.closeEphemeris();
            ShellState.hideQuickActions();
            Umbra.preview();
        }

        function closePreview(): void {
            Umbra.closePreview();
        }
    }

    Variants {
        model: Quickshell.screens
        ApertureBar {}
    }

    Variants {
        model: Quickshell.screens
        EphemerisSurface {}
    }

    Variants {
        model: Quickshell.screens
        OsdPopup {}
    }

    Variants {
        model: Quickshell.screens
        QuickActionsRail {}
    }

    Variants {
        model: Quickshell.screens
        UmbraPreview {}
    }

    NotificationPopups {}
}
