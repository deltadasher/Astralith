# Ephemeris widgets

Widgets are grouped by responsibility while exposed to Ephemeris through the
single `qmldir` registry.

## Catalog

- `catalog/LauncherWidget.qml` — desktop application search and launch
- `catalog/ToolsWidget.qml` — feature and instrument directory
- `catalog/GuideWidget.qml` — Astralith flight manual

## Desktop

- `desktop/WallpaperWidget.qml` — Parallax local and online wallpaper archive
- `desktop/WorkspaceWidget.qml` — Niri workspace and window navigation
- `desktop/CaptureWidget.qml` — Optics screenshot and recording controls

## Media

- `media/MediaWidget.qml` — Resonance MPRIS, lyrics, spectrum, and equalizer

## Productivity

- `productivity/CalendarWidget.qml` — calendar and forecast composition
- `productivity/FocusWidget.qml` — Focus Orbit and seven-day telemetry
- `productivity/ClipboardWidget.qml` — Clipboard Orbit presentation
- `productivity/NotificationsWidget.qml` — Transit history and DND

## System

- `system/AudioWidget.qml` — Acoustic Array mixer
- `system/NetworkWidget.qml` — Link Array Wi-Fi, Ethernet, and Bluetooth
- `system/BatteryWidget.qml` — battery and power-profile telemetry
- `system/SystemWidget.qml` — Observatory hardware telemetry
- `system/SettingsWidget.qml` — categorized Observatory Settings host

## Shared instrument primitives

- `shared/AudioSlider.qml` — reusable optimistic 0–150% audio control
- `shared/OrbitalForecast.qml` — reusable hourly weather orbit

When moving or adding files, update `qmldir`; Ephemeris imports the registry
directory rather than every category separately.
