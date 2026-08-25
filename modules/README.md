# Modules

Complete Astralith surfaces are organized by ownership:

- `aperture/` — always-visible bar and compact instrumentation
- `ephemeris/` — animated host, layout registry, and expanding widgets
- `osd/` — volume, microphone, and luminance feedback
- `quickactions/` — Chronos and compact telemetry edge deck
- `transit/` — notification and clipboard presentation
- `umbra/` — preview and secure session lock

Reusable visual primitives belong in `components/`; long-lived system state
belongs in `services/`. Avoid creating a second service or poller inside a
module merely because one widget needs the data.
