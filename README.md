# Astralith

An astronomy-forward desktop suite for **Niri**, built with **Quickshell**.

![Astralith orbital cartography](assets/wallpapers/orbital-cartography.png)

Astralith is my Wayland desktop environment project: a quiet instrument bar
when left alone, and a complete observatory console when opened. It includes
an application launcher, media and lyrics, audio routing, networking, clipboard
history, notifications, wallpapers, weather, focus cycles, system telemetry,
screenshots, quick actions, and the Umbra session lock.

> [!IMPORTANT]
> This is currently a private development repository. It does not have a
> redistribution license yet because a few early implementations were adapted
> while studying an unlicensed upstream project. See
> [the provenance audit](docs/provenance-audit.md) before making the repository
> public or redistributing its source.

## The suite

| System | Purpose |
| --- | --- |
| **Aperture** | Top bar, workspaces, media, tray, and compact telemetry |
| **Ephemeris** | Animated host for Astralith's expanding desktop instruments |
| **Parallax** | Wallpaper archive and Niri workspace navigation |
| **Resonance** | MPRIS media, lyrics, spectrum, and equalizer controls |
| **Transit** | Notifications, history, and clipboard state |
| **Chronos** | Countdown, stopwatch, focus cycles, and quick telemetry |
| **Optics** | Screenshots, editing, recording, and capture history |
| **Umbra** | Multi-output session lock and safe lock-screen preview |

## Install on a new machine

Astralith installs with reversible user-local symlinks. It will not overwrite
an existing Quickshell configuration or command.

```bash
git clone git@github.com:deltadasher/Astralith.git
cd Astralith

./scripts/doctor
./scripts/install-user
astralithctl check
astralithctl start
```

If `~/.local/bin` is not already in your `PATH`, add it to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

The installer creates only these links:

- `~/.config/quickshell/astralith` → this checkout
- `~/.local/bin/astralithctl` → Astralith's control command

Runtime settings, caches, downloaded wallpapers, screenshots, and state remain
outside the repository. Removing the checkout does not remove those files.

### Install the Niri configuration

Inspect and validate the bundled configuration first:

```bash
./scripts/sync-compositor-configs --check
```

Install it only when you are ready:

```bash
./scripts/sync-compositor-configs --niri
```

The installer creates a timestamped backup of an existing
`~/.config/niri/config.kdl` before replacing it. Output blocks are deliberately
left to Niri's automatic detection so the same configuration can boot on a
desktop, laptop, or dock without stale connector names blanking a display.

## Everyday commands

```text
astralithctl start                 Start the shell
astralithctl stop                  Stop the shell
astralithctl restart               Reload the shell cleanly
astralithctl status                Show the matching Quickshell instance
astralithctl doctor                Check this machine's integrations
astralithctl update                Pull, validate, and restart safely

astralithctl open apps             Open an Ephemeris instrument
astralithctl toggle settings       Toggle an instrument
astralithctl close                 Close Ephemeris
astralithctl quick timer           Open Chronos
astralithctl preview-lock          Preview Umbra without locking
astralithctl lock                  Engage the real session lock
astralithctl capture region-copy   Copy a selected region to the clipboard
```

Run `astralithctl help` for the complete command surface.

## Default controls

| Binding | Action |
| --- | --- |
| `Mod+Enter` | Terminology |
| `Mod+D` | Application catalog |
| `Mod+Shift+N` | Observatory settings |
| `Mod+Shift+Q` | Chronos quick actions |
| `Mod+Shift+W` | Parallax wallpaper archive |
| `Mod+Shift+C` | Clipboard Orbit |
| `Mod+Shift+A` | Transit notification history |
| `Mod+Shift+S` | Select a region and copy the PNG |
| `Super+Alt+L` | Lock with Umbra |

The default terminal is Terminology. Applications, formats, bar channels,
wallpaper behavior, fonts, weather, and other preferences are editable in
Observatory Settings and persist to:

```text
${XDG_CONFIG_HOME:-~/.config}/astralith/settings.json
```

Per-machine setup and safe synchronization are covered in
[docs/machines.md](docs/machines.md).

## Dependencies

Core runtime:

- Niri
- Quickshell with Qt 6 and Wayland support
- Bash and Python 3
- PipeWire tools (`wpctl`) and PulseAudio compatibility tools (`pactl`)
- JetBrains Mono and Iosevka Nerd Font

Astralith degrades gracefully when optional integrations are missing. Run
`./scripts/doctor` for a readable report. Networking, clipboard, screenshots,
recording, wallpapers, Matugen palettes, media spectrum, equalization,
brightness, and power profiles are documented in
[docs/dependencies.md](docs/dependencies.md).

## Repository map

```text
Astralith/
├── shell.qml                     Quickshell entrypoint
├── Settings.qml                  Persistent behavior and application defaults
├── Theme.qml                     Shared visual and motion tokens
├── components/                   Reusable QML primitives
├── services/                     System and compositor state adapters
├── modules/
│   ├── aperture/                 Bar and compact instrumentation
│   ├── ephemeris/                Expanding instrument host and registry
│   │   └── widgets/
│   │       ├── catalog/          Launcher, tools, and flight manual
│   │       ├── desktop/          Wallpapers, capture, and workspaces
│   │       ├── media/            Resonance
│   │       ├── productivity/     Calendar, focus, clipboard, notifications
│   │       ├── shared/           Reusable instrument-local primitives
│   │       └── system/           Audio, network, power, settings, telemetry
│   ├── osd/                      Volume, microphone, brightness feedback
│   ├── quickactions/             Chronos and compact telemetry
│   ├── transit/                  Notification and clipboard presentation
│   └── umbra/                    Preview and secure lock surfaces
├── assets/                       Original icons and wallpaper flight packs
├── config/                       Runtime backend configuration
├── niri/                         Portable compositor configuration
├── scripts/                      CLI, installers, adapters, and validation
├── tests/                        Offline helper and command tests
└── docs/                         Architecture, setup, provenance, and design notes
```

Read [docs/architecture.md](docs/architecture.md) before moving QML files or
adding a new surface. Ephemeris widget categories are indexed in
[modules/ephemeris/widgets/README.md](modules/ephemeris/widgets/README.md).

## Updating

The checkout is the source of truth; the installed Quickshell path is a symlink
to it. On another machine, update with:

```bash
astralithctl update
```

The updater refuses to pull over local modifications, uses a fast-forward-only
Git pull, runs the full validation suite, and restarts Astralith only after the
checks pass.

For development:

```bash
./scripts/check
./scripts/dev
```

`scripts/check` compiles Python helpers, validates shell scripts, runs tests,
checks the bundled Niri configuration when Niri is installed, and lints every
QML component. Keep changes in focused commits; the first repository commit is
the known-working rollback point.

## Project status

Astralith is usable on the author's Niri desktop and is being prepared for the
rest of the author's computers. The immediate priorities are:

1. prove clean installation on a second machine;
2. finish independently replacing the remaining unlicensed adaptation points;
3. select a license only after that provenance work is complete;
4. build a safe animation laboratory before changing Ephemeris geometry again;
5. package optional dependencies after the supported distributions are known.

This project is intentionally ambitious. Stability wins over visual rewrites:
prototype risky layer-shell behavior outside the live shell, then port it only
after it survives validation.
