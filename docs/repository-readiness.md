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
machine-synchronization remote. The known provenance blockers are resolved;
keep it private until Astralith's own license and initial support policy are
chosen.

## Before making the repository public

1. Select Astralith's own license and add it at the repository root.
2. Choose the first supported distribution and verify exact package names.
3. Capture clean screenshots for Aperture, Ephemeris, Parallax, Resonance,
   Focus Orbit, and Observatory Settings.
4. Add continuous integration only after choosing a runner image that packages
   a compatible Quickshell/qmllint version.

Do not publish a source release until item 1 is complete.
