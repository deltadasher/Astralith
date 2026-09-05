# Architecture

Tonantzintla is one Quickshell application with a small number of deliberately
separated layers. Keep those boundaries intact: most past regressions came from
mixing layer-shell window ownership, UI presentation, and service lifetime.

## Runtime flow

```text
src/quickshell/shell.qml
├── core singletons: Settings, Theme, ShellState, AdaptivePalette
├── src/quickshell/services/: long-lived system and compositor state
├── src/quickshell/modules/aperture/: always-visible bar
├── src/quickshell/modules/ephemeris/: on-demand expanding instruments
├── src/quickshell/modules/osd/: short-lived feedback surfaces
├── src/quickshell/modules/quickactions/: on-demand edge deck
├── src/quickshell/modules/transit/: notifications and clipboard presentation
└── src/quickshell/modules/umbra/: preview and isolated secure lock instance
```

`shell.qml` is composition only. It should not accumulate feature behavior.

## Core

- `Settings.qml` owns user-editable defaults and JSON persistence.
- `Theme.qml` maps settings and adaptive palette values into shared visual
  tokens. Components should consume tokens instead of inventing local palettes.
- `ShellState.qml` owns transient surface visibility and routing.
- `AdaptivePalette.qml` owns the wallpaper-derived palette cache.

These files live at the Quickshell source root because every QML layer imports
them. Repository-level packaging and compositor files stay outside the runtime.

## Services

Services translate external state into stable QML properties. They may invoke a
helper from `src/libexec/`, but should not own presentation. Examples include compositor,
MPRIS, PipeWire, NetworkManager, weather, clipboard, focus history, and system
telemetry.

Rules:

1. Missing optional commands must produce an unavailable state, not prevent the
   shell from loading.
2. A service should poll once for all consumers; widgets must not create a
   second poller for the same information. Expensive detail polling must follow
   the visibility of its owning surface and settle when that surface closes.
3. Runtime files belong in XDG config/cache/state directories, never the source
   checkout.
4. Machine-specific paths must come from environment variables or resolved
   project URLs.

## Platform boundary

UI code consumes `services/Compositor.qml`; it must not speak a compositor IPC
protocol directly. The 1.0 implementation uses Niri's socket. Later releases can
add backends under `compositors/` while keeping modules, components, and most
services unchanged.

`compositors/` contains only adapters that are actually supported. Do not add
placeholder Hyprland, Sway, labwc, X11, or other trees before they can be run and
maintained.

## Components

`src/quickshell/components/` contains reusable visual primitives. A component should be
independent of one complete surface and preferably consume service state through
properties. Complete screens and instrument layouts belong in `src/quickshell/modules/`.

## Modules

Modules own Wayland surfaces or complete instrument families:

- **Aperture** owns the always-visible top bar.
- **Ephemeris** owns the full-screen transparent layer-shell host and animates
  an internal deck. Do not animate the layer-shell window geometry itself.
- **OSD** owns volume, microphone, and brightness feedback.
- **Quick Actions** owns Chronos and compact telemetry.
- **Transit** owns notification and clipboard presentation.
- **Umbra** owns the preview plus a separate secure Quickshell lock process.

## Ephemeris geometry rule

The reliable model is:

1. keep a stable transparent fullscreen `PanelWindow`;
2. map the host before beginning the transition;
3. animate the internal deck's position, scale, opacity, and clipped contents;
4. keep the loaded widget alive through its exit transition;
5. unmap only after the close animation finishes.

Resizing a layer-shell window to imitate a growing popup maps the final geometry
immediately on several compositors and removes the perceived animation. Any new
attached-boundary experiment must first live in an isolated preview harness and
remain behind a feature switch until it is proven.

## Adding a widget

1. Choose a category under `src/quickshell/modules/ephemeris/widgets/`.
2. Add the component to that directory.
3. Register its path in `src/quickshell/modules/ephemeris/widgets/qmldir`.
4. Add its unique id, relative source path, dimensions, placement, title, and
   code to `EphemerisRegistry.js`. This is the local widget contract, version 1.
5. The host loads that source asynchronously and the command palette discovers
   the same entry. Do not add a second routing table to the host.
6. Optionally add an entry point in Aperture or Field Tools.
7. Run `./tools/check` and test both open and close transitions in the live
   shell.

Widget roots are `Item`s, never their own layer-shell window. They may expose
`focusPrimary()` to receive keyboard focus and `beginDeployment()` to begin an
internal entrance. Both hooks are optional. Keep data in services; a widget must
survive being unloaded between visits. This is a local source-level contract,
not an installer for untrusted third-party extensions.

`SurfaceTransition.qml` owns displayed-tab state separately from the requested
tab. Content leaves before a source swap, the new component must finish loading
before entrance, and rapid requests coalesce. Closing cancels outstanding
entrances. Loader failures show an actionable state without taking down the bar.

`ApertureContents.qml` is shared by the real bar and its read-only settings
miniature. The preview must not create a second `PanelWindow` or fake telemetry.

## Safe change sequence

1. Commit a known-working checkpoint.
2. Change one architectural layer at a time.
3. Run the offline validation suite.
4. Inspect the live Quickshell log for `Configuration Loaded` and new warnings.
5. Test the affected surface manually.
6. Commit the focused change before beginning another risky pass.
