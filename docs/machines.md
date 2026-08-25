# Using Astralith on multiple machines

Astralith separates shared source from local machine state. The Git checkout is
portable; monitor names, hardware capabilities, personal settings, downloaded
wallpapers, and caches are not committed.

## What Git synchronizes

- QML source and motion behavior
- default settings and theme tokens
- original bundled assets
- helper scripts and validation
- the portable Niri starting configuration
- documentation and tests

## What stays local

| State | Default location |
| --- | --- |
| Astralith settings | `$XDG_CONFIG_HOME/astralith/settings.json` |
| Focus history | `$XDG_CONFIG_HOME/astralith/focus.json` |
| Palette and helper caches | `$XDG_CACHE_HOME/astralith/` |
| Downloaded wallpapers | `~/Pictures/Wallpapers/Astralith/` |
| Screenshots | `~/Pictures/Screenshots/` |
| Niri's active configuration | `$XDG_CONFIG_HOME/niri/config.kdl` |

The precise location falls back to `~/.config` or `~/.cache` when the matching
XDG variable is unset.

## First installation

```bash
git clone git@github.com:deltadasher/Astralith.git
cd Astralith
./scripts/doctor
./scripts/install-user
./scripts/sync-compositor-configs --check
```

Review the doctor output before installing optional packages. A desktop without
a backlight, battery, Bluetooth adapter, or power-profile service is valid; its
corresponding widgets simply remain unavailable.

Run Astralith from a terminal once before enabling Niri autostart:

```bash
astralithctl run
```

After the bar and widgets load cleanly, install the Niri configuration or add
this line to the machine's existing config:

```kdl
spawn-at-startup "~/.local/bin/astralithctl" "start"
```

Use the explicit installed path in Niri bindings too. Display-manager sessions
do not consistently inherit `~/.local/bin` in `PATH`; Niri expands a leading
`~` in the executable name without invoking a shell.

## Monitor configuration

The bundled Niri config has no explicit `output` blocks. Niri automatically
selects safe modes on unfamiliar hardware. If a machine needs rotation, scale,
or a fixed mode, obtain the exact connector and mode strings with:

```bash
niri msg outputs
```

Put those output blocks only in that machine's active Niri configuration unless
every Astralith machine shares the same hardware.

## Settings strategy

Use Observatory Settings for normal preferences. Keep `Settings.qml` defaults
conservative and portable; do not encode one monitor, hostname, username, or
home directory into source.

If you want identical preferences everywhere, copy
`~/.config/astralith/settings.json` between machines after Astralith has been
installed. Do not commit it: local application paths and future hardware flags
may diverge.

## Updating

```bash
astralithctl update
```

The updater requires a clean checkout, pulls with `--ff-only`, validates the new
source, and restarts only a running shell. This prevents a failed update from
silently replacing the working process.

Before a large visual or architectural change, create a branch and preserve the
known-good machine:

```bash
git switch -c experiment/name
```

Merge the branch into `main` only after `./scripts/check` and live testing pass.

## Removing the user install

```bash
./scripts/uninstall-user
```

The uninstaller removes only symlinks that point into the current checkout. It
preserves unrelated files, settings, caches, screenshots, and wallpapers.
