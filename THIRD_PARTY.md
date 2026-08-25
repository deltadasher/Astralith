# Third-party material

Astralith's core QML, helper scripts, generated wallpaper pack, and generated
Flight Manual illustration are project-local work. The following third-party
material is intentionally present or optionally integrated.

## GNOME AdwaitaLegacy icons

The PNG files under `assets/icons/` are unmodified 22 px icons from GNOME's
AdwaitaLegacy icon theme. Copyright belongs to the GNOME Project and individual
contributors.

Astralith redistributes these files under the **Creative Commons
Attribution-ShareAlike 3.0 Unported** option offered by the upstream package:

- Source: <https://gitlab.gnome.org/GNOME/adwaita-icon-theme-legacy>
- License: <https://creativecommons.org/licenses/by-sa/3.0/>
- Local package version used for this set: `adwaita-icon-theme-legacy 46.2`

| Astralith file | Upstream icon |
| --- | --- |
| `audio.png` | `audio-volume-high.png` |
| `battery.png` | `battery-good.png` |
| `calendar.png` | `x-office-calendar.png` |
| `clipboard.png` | `edit-paste.png` |
| `focus.png` | `appointment-soon.png` |
| `media.png` | `multimedia-player.png` |
| `network.png` | `network-wireless.png` |
| `notifications.png` | `preferences-system-notifications.png` |
| `search.png` | `system-search.png` |
| `settings.png` | `preferences-system.png` |
| `tools.png` | `applications-utilities.png` |
| `wallpaper.png` | `preferences-desktop-wallpaper.png` |
| `workspaces.png` | `preferences-desktop.png` |

They are a separately identified part of this collection; their CC BY-SA terms
do not describe Astralith's independently written source code.

## Optional Caelestia.Blobs runtime

`astralithctl build-native-blobs` can fetch and locally build the unmodified
`Caelestia.Blobs` module from Caelestia Shell. No Caelestia C++, QML, or shader
source is stored in this repository. The fetched checkout retains its GPL-3.0
license and attribution.

- Source: <https://github.com/caelestia-dots/shell>
- License: <https://github.com/caelestia-dots/shell/blob/main/LICENSE>
- Pinned revision and build boundary: [`vendor/caelestia-blobs/README.md`](vendor/caelestia-blobs/README.md)

Distributors enabling or bundling that optional renderer must satisfy the
GPL-3.0 terms for the resulting distribution.
