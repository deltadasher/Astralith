# Provenance and public-release audit

Status checked on 2026-08-24.

## Current blocker

Astralith was developed privately while referring to and, in a few places,
directly adapting code and behavior from `ilyamiro/imperative-dots`. The local
upstream checkout at commit `eefff2fadceb28b52198175914576fbb55f57695`
contains no `LICENSE` or `COPYING` file. The current public repository view also
does not expose a license file.

Without an explicit license or direct permission, the adapted expression must
not be published as though Astralith has the right to relicense it.

## Known adaptation points

- The original Celestial Calendar orbit began from Serpantinum's calendar
  composition before Astralith's responsive/Niri rewrite.
- Equalizer curve values were adapted from Serpantinum presets.
- Online wallpaper token flow was adapted from Serpantinum's search helper.
- Serpantinum supplied visual and behavioral reference material throughout the
  parity phase.

This list is intentionally conservative and should be expanded if later review
finds another directly copied implementation.

## Resolution paths

Before creating a public GitHub release, do one of the following:

1. Obtain written permission or an explicit compatible license from the upstream
   author, preserve required attribution, and document the licensed files.
2. Independently reimplement every directly adapted section from behavioral
   requirements, without copying upstream expression, assets, or constants.

Astralith's original generated wallpapers and project-local visual primitives
can remain, subject to the license selected for Astralith itself.

## Decisions still required

- Choose Astralith's own license only after the upstream issue is resolved.
- Decide whether the repository ships Niri configuration or treats it as an
  optional example.
- Choose supported distributions and package names for dependency documentation.
- Decide whether generated wallpapers ship in the main repository or a separate
  artwork package as the library grows.
