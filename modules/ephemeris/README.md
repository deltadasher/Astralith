# Ephemeris

Ephemeris is Astralith's expanding instrument system.

- `EphemerisSurface.qml` owns mapping, focus, open/close choreography, and widget
  routing.
- `EphemerisRegistry.js` owns each instrument's size, placement, title, code,
  and icon.
- `EphemerisAtmosphere.qml` supplies shared orbital background language.
- `SettingsPane.qml`, `AppResult.qml`, and `ToolCard.qml` are Ephemeris-local
  building blocks.
- `widgets/` contains the independently loadable instruments.

The host deliberately remains a transparent fullscreen layer-shell window while
an internal deck animates. Do not replace it with a popup-sized layer-shell
window without proving the compositor behavior in a disposable harness first.

See [widgets/README.md](widgets/README.md) for the widget catalog and
[../../docs/architecture.md](../../docs/architecture.md) for change rules.
