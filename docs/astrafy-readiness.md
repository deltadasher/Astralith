# Astrafy readiness gate

**Decision: GO.** Astralith has enough behavioral and interaction parity to stop
chasing Serpantinum feature-for-feature and begin establishing its own visual
identity.

## Flight build 01 — landed

- Semantic instrument channels now give audio, media, networking, power,
  telemetry, focus, and utility surfaces stable spectral identities.
- Ephemeris, the quick-action rail, and OSD share angular corner telemetry and
  restrained animated instrument framing.
- Expanded widgets gained a mission header with an orbital module badge, live
  output link, and module-colored signal rail.
- The shared atmosphere gained drifting orbital nodes, a comet transit, and
  quiet, nominal, and cinematic density presets.
- Aperture gained subtle hover acquisition marks and a live minute-progress
  trace under the mission clock.

## What is locked in

- Aperture is a light, modular, state-colored bar rather than a permanent dashboard.
- Ephemeris is the common expanding-widget host, with output-aware sizing,
  consistent motion, and a shared orbital atmosphere.
- Astralith is Niri-first. Hyprland and the installed Serpantinum tree are reference
  material only and are not runtime dependencies or synchronization targets.
- Adaptive Nebula, persisted wallpaper state, system services, and font validation
  give the visual layer stable data to build on.
- The core gamer-facing surfaces are functional: launch, workspaces, media, mixer,
  network, capture, notifications, clipboard, performance, focus, wallpaper, and settings.

## Astrafy objectives

1. Replace remaining borrowed visual conventions with a coherent Astralith shape,
   icon, typography, and motion language.
2. Give every module a distinct astronomical instrument identity while retaining
   shared controls and predictable placement.
3. Reduce incidental outlines and reserve strong spectral color for live state,
   selection, warnings, progress, and deliberate focal points.
4. Add user-facing configuration commands and a stable configuration schema before
   publishing the first repository.
5. Umbra's lock/session surface has landed. Build the greeter/display-manager
   theme later as a separate security-sensitive phase.

## Explicit non-blockers

- Repository-aware updates cannot be completed before a repository and release
  policy exist.
- QR capture, persistent crop regions, laptop battery history, Stewart, and Movies
  can be evaluated later without holding up the identity pass.
- Fixed-reference-resolution scaling is intentionally not copied; Ephemeris already
  clamps each widget to the actual Niri output and available vertical space.

## Exit criteria for the Astrafy phase

- A recognizable Astralith visual language is consistent across Aperture,
  Ephemeris, OSD, Transit, and quick actions.
- No essential control depends on Serpantinum assets or a Hyprland command path.
- Text remains legible at the current output scale and missing fonts are visible
  rather than silently accepted.
- The shell survives reloads with persisted settings, focus state, wallpaper, and
  palette intact.
- A cleanup pass removes dead experiments and documents the public command surface.
