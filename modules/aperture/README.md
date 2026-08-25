# Aperture

Aperture is Astralith's always-visible top bar. `ApertureBar.qml` composes the
launcher, workspaces, focused media, clock, compact system telemetry, device
state, tray, notifications, quick actions, and settings entry points.

It consumes shared components and services but does not own their polling. Bar
controls should route expanded experiences into Ephemeris rather than embedding
large menus directly in Aperture.
