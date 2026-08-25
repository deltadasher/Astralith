# Changelog

## Unreleased

- Established the first known-working Git checkpoint.
- Organized Ephemeris widgets by catalog, desktop, media, productivity, and
  system responsibilities.
- Added multi-machine installation, update, uninstall, and dependency doctor
  workflows.
- Rewrote repository documentation around safe Niri deployment and architectural
  ownership.
- Made detailed mixer, network, clipboard, spectrum, lyrics, recording, device,
  and folder telemetry follow their owning surfaces instead of polling at idle.
- Replaced repeated system-telemetry Python startups with one streaming helper,
  made wallpaper restoration idempotent, and added `astralithctl profile`.
- Reassigned `Meta+Up/Down` to workspace travel, retired wheel-based workspace
  switching, and enlarged notification dismissal into a full-height close rail.
- Routed `Meta+Shift+S` through Niri's native interactive screenshot UI after
  the detached Slurp handoff began exiting before presenting its selector.
- Made Niri autostart and every Astralith hotkey invoke the explicit
  `~/.local/bin/astralithctl` installation instead of assuming the display
  manager imported that directory into `PATH`.
