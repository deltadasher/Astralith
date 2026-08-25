# Serpantinum to Astralith parity map

This is the working inventory for porting the local Serpantinum shell into a
Niri-native Astralith suite. The goal is behavioral and visual parity without
carrying Hyprland-only control paths into Astralith.

Status vocabulary:

- `native`: Astralith already implements the capability with its own backend.
- `ported`: adapted from the local Serpantinum implementation.
- `partial`: useful coverage exists, but the Serpantinum surface is richer.
- `queued`: inventoried and scheduled for a later batch.
- `blocked`: depends on a prerequisite that does not exist yet.

## Foundation

| Serpantinum subsystem | Astralith counterpart | Status | Next work |
| --- | --- | --- | --- |
| `Shell.qml`, `Main.qml`, `WindowRegistry.js` | Ephemeris host, registry, `ShellState` | native | Shared module-colored orbital atmosphere, restrained global chrome, and morphing Niri placement landed |
| `TopBar.qml` | Aperture bar | ported | Serpantinum geometry, workspace motion, media, weather, and telemetry are present; Astralith uses quieter state-led chrome |
| `MatugenColors.qml` | Adaptive Nebula palette | native | Shell-wide cached image/video sampling and preview landed; external app templates remain opt-in future work |
| `Scaler.qml` | Responsive registry geometry | native | Output-aware clamping intentionally replaces Serpantinum's fixed 1920x1080 scale assumption |
| Font recipe | Theme, Settings font roles, and `FontState` | native | Installed faces, aliases, and silent Fontconfig fallbacks are reported live |
| Cache and watcher helpers | Quickshell services and scripts | native | Persistent state and bounded caches are owned per service; a common cache API is an internal refactor, not a feature gap |

The local Serpantinum source uses JetBrains Mono for most textual UI, Iosevka
Nerd Font for symbolic glyphs, and Inter in a smaller number of body-copy
locations. Astralith defaults to the two installed primary faces and exposes
all four roles in Settings.

## Interactive surfaces

| Serpantinum surface | Astralith surface | Status | Notes |
| --- | --- | --- | --- |
| App launcher | Application catalog | native | DesktopEntries-powered fuzzy search |
| Calendar and weather | Celestial calendar | ported | Orbit composition adapted to responsive Niri geometry |
| Music popup | Resonance console | ported | Cached embedded/LRCLIB lyrics, synchronized seeking, player selection, shuffle, loop, rate, volume, CAVA, and EasyEffects landed |
| Volume popup | Acoustic array | ported | Liquid master orb, 150% overdrive ring, live/ambient spectrum field, and full PipeWire node mixer landed |
| Network popup | Link array | native | Wi-Fi, Bluetooth, Ethernet, password entry |
| Battery popup | Reactor telemetry | native | Segmented reactor core, health, energy flow, charge rate, and power profiles landed; laptop history is optional hardware-specific expansion |
| Wallpaper picker | Parallax archive | ported | Online search, video walls, source/color filters, AWWW transitions, and Niri output targeting landed |
| Clipboard manager | Clipboard orbit | native | Search and image/text restore |
| Notifications | Transit signals | native | History, DND, actions, animated local toasts |
| FocusTime | Focus orbit | native | Persistent Pomodoro phases, automatic short/long drifts, daily and seven-day totals, streaks, and restore-after-reload landed |
| Settings popup | Observatory settings | native | Bar presets and per-channel controls, live built-in extension readiness, typography profiles, and Fontconfig validation landed |
| Guide popup | Flight manual | ported | Module launcher, Niri controls, live parity view |
| System usage quick action | Observatory telemetry | native | Already broader than the upstream compact card |
| Timer quick action | Chronos array and Focus orbit | ported | Countdown, lap stopwatch, focus state, rail status, and local completion signals |
| Screenshot overlay | Optics bay and snipping backend | native | Region/output copy, save, Satty editing, portal recording, and live REC state cover the desktop core; QR scan and persistent resizable regions are optional tools |
| Lock screen | Umbra session veil | native | Multi-output session lock, PAM authentication, safe preview, fluid field, and restrained lock telemetry landed |
| Updater | None | blocked | Requires Astralith repository and release manifest |
| Stewart | None | queued | Upstream is presently a visual assistant core |
| Movies | None | queued | External metadata/playback surface; lowest core priority |

## Services and command dependencies

| Capability | Serpantinum path | Astralith policy |
| --- | --- | --- |
| Compositor control | `hyprctl` | Replace with `niri msg` or avoid compositor dependency |
| Audio | `wpctl`, PipeWire scripts | Keep direct PipeWire service and throttled writes |
| Network | `nmcli`, BlueZ helpers | Keep NetworkManager/BlueZ backend |
| Media | `playerctl`, scripts | Prefer Quickshell MPRIS; scripts only for missing features |
| Wallpaper | `awww`, Matugen | Keep per-session `awww`; persist through Settings |
| Screenshot | Grim, Slurp, wl-copy | Keep Wayland-native tools; build UI around them |
| Notifications | shared D-Bus server | Keep Astralith-local preview path until it owns the bus |
| Power | `systemctl`, `powerprofilesctl` | Expose deliberate actions with confirmation |

## Port order

1. Typography roles, Flight Manual, and Parallax archive. *(landed)*
2. Adaptive Nebula shell theming and video sampling. *(landed)*
3. Floating quick-action deck: timer/stopwatch and compact telemetry. *(landed)*
4. Featherweight Aperture pass: neutral glass, state-only color, live bar weather,
   and Niri telemetry launch points. *(landed)*
5. Screenshot capture, Satty editor, and recording controls. *(landed; QR and persistent region remain)*
6. Battery health and power profiles. *(landed; historical graphs remain)*
7. Resonance lyrics and extended per-player controls. *(landed)*
8. Umbra session lock with safe visual preview. *(landed; greeter remains separate)*
9. Repository-aware updater after the project is published.
10. Stewart and movies after the desktop core is complete.

## Parity closure

The Serpantinum-derived desktop core is complete enough to begin Astralith's
own visual-identity phase. This is a deliberate `GO`, not a claim that the suite
will never gain another module.

Release-gate capabilities now present:

- Niri-native shell hosting, workspaces, window navigation, and output-aware geometry.
- A quiet capsule bar with state-led color, media, weather, devices, tray, and telemetry.
- Independent expanding widgets with consistent arrival motion and a shared,
  module-colored orbital atmosphere.
- Persistent wallpaper, Matugen palette, settings, focus, timer, and capture state.
- Full media, audio, network, notification, clipboard, system, weather, focus,
  wallpaper, application, capture, battery, guide, and settings surfaces.
- Live dependency and extension reporting, including explicit font fallback visibility.

Deferred work is outside the parity gate:

- **Display-manager greeter styling** — the in-session Umbra lock has landed;
  pre-session authentication remains a separate security boundary.
- **Repository updater** — blocked until Astralith has a repository, release
  channel, and signed/verified update policy.
- **QR recognition and a persistent resizable capture region** — useful Optics
  extras, but not gamer-desktop essentials.
- **Battery history** — useful on portable hardware, irrelevant to the current
  desktop target.
- **Stewart and Movies** — novelty/external-content surfaces, intentionally below
  core shell quality and identity work.

Hyprland configuration and the running Serpantinum installation are reference
inputs only and must remain untouched.
