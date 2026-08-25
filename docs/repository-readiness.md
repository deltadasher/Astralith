# Repository readiness

## Technical state

- Source tree contains no user-specific absolute paths.
- `scripts/check` validates Python syntax, shell syntax, QML diagnostics, and the
  bundled Niri configuration.
- `astralithctl` provides a stable command surface for lifecycle and shell IPC.
- `scripts/install-user` creates user-local symlinks and refuses to overwrite
  existing paths.
- Runtime settings, caches, downloads, recordings, and captures stay outside the
  source tree; `.gitignore` covers accidental local artifacts.
- Bundled wallpapers are indexed before the bounded user library and malformed
  image downloads are rejected.

The private `deltadasher/Astralith` repository is the current collaboration and
machine-synchronization remote. Keep it private until the provenance and license
decisions below are complete.

## Before making the repository public

1. Resolve the upstream licensing/provenance blocker described in
   `provenance-audit.md`.
2. Select Astralith's license after that resolution.
3. Choose the first supported distribution and verify exact package names.
4. Capture clean screenshots for Aperture, Ephemeris, Parallax, Resonance,
   Focus Orbit, and Observatory Settings.
5. Add continuous integration only after choosing a runner image that packages
   a compatible Quickshell/qmllint version.

Do not publish a source release until items 1 and 2 are complete.
