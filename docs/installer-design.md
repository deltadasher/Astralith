# Astralith TUI installer design

This document defines the installer before implementation. Astralith has enough
independent system integrations that installation must be planned as a
transaction, not treated as one large shell command.

## Product goal

The installer should take a machine from an ordinary Wayland/Niri environment
to a working Astralith session while making every external change visible,
optional where possible, and reversible.

The source checkout is installation input, not the runtime destination. A
user-local installation owns `$XDG_DATA_HOME/astralith`; system packages may
instead own a distribution path such as `/usr/share/astralith`. Quickshell and
command entrypoints link to that installed runtime, never to a temporary clone
or development workspace.

It must:

- run from the repository before Astralith itself is installed;
- ship as one compiled Rust binary with no Python runtime dependency;
- work entirely from the keyboard and remain usable without Nerd Fonts;
- detect existing software and preserve compatible installations;
- distinguish required, recommended, optional, and unavailable features;
- show the exact action plan before changing the machine;
- request privilege only for the individual system operations that need it;
- validate each layer before activating it;
- leave a machine-readable journal and a human-readable summary;
- support repair, update, and uninstall as well as first installation;
- never require the full bundled Niri configuration or Umbra greeter.

## Interface direction

Use a Rust application built with `ratatui` and `crossterm`, rather than
`dialog`, `whiptail`, Python, or a shell menu. The release artifact is a single
binary, so the user does not need Rust installed unless they choose to build
directly from a source checkout. The TUI can still look like Astralith:

```text
 ASTRALITH // DEPLOYMENT ARRAY                         MACHINE: archlinux
 ─────────────────────────────────────────────────────────────────────────
  01  PREFLIGHT       ● ready       Selected flight profile
  02  COMPONENTS      ◐ 12 / 18     Core observatory
  03  NIRI            ◌ review      + Recommended integrations
  04  UMBRA            off          + Adaptive palette
  05  REVIEW                        - Native blob renderer

     Core shell             READY
     Networking             INSTALLED
     Clipboard history      WILL INSTALL
     Screen recording       SKIPPED

 [Space] toggle  [Enter] inspect  [B] back  [D] dry run  [Q] leave intact
```

The visual language should use solid lavender/cyan/rose state colors, restrained
motion, and plain Unicode fallbacks. `TERM=dumb`, tiny terminals, missing color
support, and accessibility/reduced-motion mode must fall back to a simple list.

## Install modes

The opening screen should offer:

| Mode | Purpose |
| --- | --- |
| Core | Astralith, required runtime, user links, and no optional integrations |
| Recommended | Core plus common desktop features detected as useful on this machine |
| Full | Every supported feature whose hardware/runtime requirements are met |
| Custom | Review every feature and system integration individually |
| Repair | Re-run validation and repair only missing or mismatched owned files |
| Update | Fast-forward source, validate, migrate settings, and restart if running |
| Uninstall | Remove selected Astralith-owned integrations while preserving user data by default |

Every preset is only a starting selection. The user can inspect and change it
before execution.

## Screen flow

### 1. Welcome and safety

- Show version, source checkout, branch, and whether the tree is dirty.
- Explain that packages, services, compositor configuration, and SDDM are four
  separate scopes.
- Refuse to run the full TUI as root. Escalate individual operations instead.
- Offer dry-run immediately.

### 2. Machine preflight

- Distribution, package manager, architecture, session type, compositor, and
  current display manager.
- Niri and Quickshell versions.
- Network reachability only when selected operations need downloads.
- Package-manager lock and available disk space.
- Battery, backlight, Bluetooth, network interfaces, power-profile support,
  and connected outputs.
- Existing Quickshell shells, bars, notification daemons, wallpaper daemons,
  session locks, and SDDM theme ownership.
- Existing Astralith links, source checkout, settings, and prior transaction
  journal.

Preflight should not mutate the machine.

### 3. Flight profile

Choose Core, Recommended, Full, Custom, Repair, Update, or Uninstall. Show the
resulting package and integration count before continuing.

### 4. Components

Feature selection is capability-based. Package names belong in distribution
adapters rather than presentation code.

| Group | Capabilities |
| --- | --- |
| Core runtime | Niri, Quickshell/Qt 6/Wayland, Python 3 service adapters, PipeWire `wpctl`, `pactl` |
| Typography | JetBrains Mono, Iosevka Nerd Font, Fontconfig diagnostics |
| Network | NetworkManager/`nmcli`, BlueZ/`bluetoothctl`, optional connection editor |
| Clipboard | `wl-clipboard`, `cliphist`, text and image history watchers |
| Optics | `grim`, `slurp`, `wl-copy`, Satty, GPU Screen Recorder |
| Parallax | `awww`, fallback image backends, `mpvpaper`, online wallpaper access |
| Adaptive color | Matugen and FFmpeg video-frame sampling |
| Resonance | CAVA, EasyEffects, PipeWire/Pulse tooling |
| Portable hardware | `brightnessctl`, power-profiles daemon, battery integration |
| Default applications | Terminal, browser, file manager selected by the user |
| Native morph renderer | CMake, Ninja, C++ compiler, Qt Shader Tools, pinned GPL integration |
| Umbra lock | Quickshell PAM support, `ext-session-lock-v1`, selected PAM service |
| Umbra greeter | SDDM plus the standalone Astralith theme |

Each feature row should show:

- installed, missing, incompatible, or unknown;
- why it is useful;
- packages/actions it introduces;
- whether it adds a persistent process or service;
- license or network implications where relevant;
- which Astralith control becomes unavailable when skipped.

Hardware-inapplicable features should default off instead of being described as
errors.

### 5. Application and shell defaults

- Terminal, browser, and file manager.
- Weather enabled/location/unit.
- Wallpaper directory and image/video support.
- Typography profile and reduced-motion/debloat profile.
- Optional settings import from another Astralith machine.

Write these to Astralith's XDG settings, never into repository source.

### 6. Niri integration

Offer three explicit choices:

1. keep the existing Niri configuration and show the Astralith bindings to add;
2. install only a generated Astralith include/binding fragment when supported;
3. replace with the bundled portable configuration after backup and validation.

The installer must:

- show the target path and diff;
- never copy monitor modes or connector names from another machine;
- validate the candidate before replacing anything;
- create a timestamped backup and record its checksum;
- verify required executable paths such as `~/.local/bin/astralithctl`;
- preserve the old config automatically if validation fails;
- explain that Niri may hot-reload the result.

### 7. Desktop ownership conflicts

Detect rather than silently fight:

- Mako, Dunst, SwayNC, or another owner of
  `org.freedesktop.Notifications`;
- another Quickshell shell or bar autostart;
- another clipboard watcher;
- conflicting wallpaper daemons;
- an existing lock utility;
- existing SDDM theme overrides.

For every conflict offer **keep existing**, **disable for Astralith**, or **skip
the Astralith feature**. Disabling a user service requires an individual
confirmation and must be journaled for rollback.

### 8. Umbra

Treat the two Umbra systems separately:

- in-session secure lock: verify protocol and PAM support, then run a safe
  preview before exposing the lock binding;
- SDDM greeter: preview, install without activation, or install and activate.

Activating the greeter must show the exact `/etc/sddm.conf.d` file, retain the
previous lower-priority theme, and provide a visible rollback command. The TUI
must never enable or replace a display manager merely because the theme was
selected; that is a separate confirmation.

### 9. Review

Before execution show a categorized plan:

- packages to install;
- user files and symlinks to create;
- existing files to back up;
- services to enable, disable, start, or stop;
- Niri changes;
- Umbra/PAM/SDDM changes;
- downloads and third-party license boundaries;
- estimated disk use;
- operations requiring `sudo`;
- items intentionally skipped.

The review screen must support exporting the plan without executing it.

### 10. Execution and verification

- Execute small named operations, not one opaque shell pipeline.
- Display the active operation and a scrollable log.
- Write the transaction journal after every completed operation.
- Stop safely on failure and offer rollback or retry.
- Run Astralith checks, Niri validation, doctor, QML loading, and optional
  feature probes at the end.
- Start Astralith only after validation passes.
- Never reboot, log out, activate SDDM, or replace a running compositor without
  explicit confirmation.

### 11. Result

Show what works now, what was skipped, what requires a logout, and where the
backup/journal live. Include commands for start, restart, doctor, rollback, and
opening the first settings screen.

## Transaction and rollback model

Store one manifest per run under:

```text
$XDG_STATE_HOME/astralith/installer/transactions/<timestamp>.json
```

The manifest should record:

- installer/source version and selected profile;
- completed, skipped, failed, and rolled-back operation IDs;
- created paths and their ownership;
- previous symlink targets;
- backup path, permissions, and checksum for replaced files;
- service state before and after;
- package requests made by Astralith;
- SDDM override state;
- generated settings and user decisions.

Rollback should remove only files proven to be owned by that transaction and
restore recorded backups/service states. Packages should not be automatically
removed by default because another application may have begun using them.

The current executor implements the first-install/update transaction: Arch
packages, staged user-local runtime activation, Quickshell and control-command
links, optional validated Niri replacement, per-operation JSON journaling, and
automatic rollback of Astralith-owned user files. Service ownership choices,
SDDM activation, repair, uninstall, and journal-driven rollback commands remain
future scopes; the executor does not silently mutate those systems.

The installer must be idempotent: rerunning the same plan should produce
`already satisfied`, not duplicate services, links, backups, or config blocks.

## Proposed code layout

```text
installer/
├── Cargo.toml
├── Cargo.lock               committed for reproducible application builds
├── features.toml            capability and feature relationships
└── src/
    ├── main.rs              CLI entry point and terminal lifecycle
    ├── app.rs               navigation, state, and event loop
    ├── cli.rs               dry-run, plan, replay, repair, and uninstall flags
    ├── model.rs             detected machine state and immutable install plan
    ├── journal.rs           transaction persistence and rollback
    ├── operation.rs         typed, reversible operations
    ├── manifest.rs          feature graph and preset resolution
    ├── terminal.rs          raw mode, panic cleanup, and fallback rendering
    ├── screens/             preflight, components, Niri, Umbra, review, log
    ├── platform/
    │   ├── mod.rs           package-manager capability trait
    │   └── arch.rs          pacman and supported AUR-helper mappings
    └── probe/               commands, hardware, services, SDDM, Niri, conflicts
scripts/
└── install                  POSIX shell bootstrap for release binary or Cargo
```

The first supported distribution should be Arch Linux. Platform boundaries
should exist from day one so another distribution can be added without
scattering package names throughout the UI.

Backend operations should also support `--dry-run`, `--plan FILE`, and a
non-interactive replay mode. The `ratatui` interface is one client of the
planning engine, not the only way to use it. UI modules must never directly run
system commands; they produce decisions for the same planner used by the CLI.

### Rust and bootstrap policy

- Pin the stable Rust toolchain used for releases and commit `Cargo.lock`.
- Publish an `x86_64-unknown-linux-musl` binary first, then add AArch64 when a
  supported Astralith machine needs it.
- `scripts/install` detects a matching local release binary before offering a
  verified download or `cargo build --release` from source.
- Downloaded binaries require a published SHA-256 checksum before execution.
- Building from source may require Cargo; using a release must not.
- Python is not part of the installer architecture. Astralith itself currently
  uses Python service adapters, so the Arch plan still installs Python as a
  shell runtime dependency until those helpers are independently migrated.
- Keep the dependency set deliberately small: `ratatui`, `crossterm`,
  `serde`, `serde_json`, `toml`, `clap`, and `anyhow` are the expected
  baseline. Add crates only when they replace meaningful custom code.

## Test requirements

- Temporary `HOME`, XDG directories, and fake command `PATH` for every test.
- Fake package manager, `systemctl`, `sudo`, SDDM, and Niri adapters.
- Core, Recommended, Full, and Custom plan snapshots.
- Existing-file, unrelated-symlink, dirty-checkout, package-lock, offline, and
  missing-hardware fixtures.
- Niri validation failure proves the active config remains untouched.
- SDDM preview/install/activation are tested as independent operations.
- Conflict handling proves an existing notification daemon is preserved by
  default.
- Interrupted execution can resume or roll back from its journal.
- Re-running a completed transaction is idempotent.
- Live validation in a clean Arch VM and on a second physical machine before
  calling the installer stable.

## Implementation sequence

1. Build read-only probes and a serializable machine report.
2. Define feature manifest, dependency graph, presets, and Arch package map.
3. Build the operation planner and dry-run output.
4. Wrap current user-link, doctor, Niri, blob, and greeter scripts as typed
   operations without changing their proven implementations yet.
5. Add journaled execution and rollback.
6. Build the `ratatui` screen framework and review flow.
7. Add package installation and service-conflict handling.
8. Add settings generation, Niri choices, and Umbra screens.
9. Add repair, update, and uninstall flows.
10. Validate in an Arch VM and then on another Astralith machine.

## Decisions still needed

- Whether AUR packages may be installed automatically or only surfaced as
  copyable/manual commands.
- Whether Recommended should include SDDM installation when no display manager
  exists (activation should remain opt-in regardless).
- Whether the native GPL blob renderer belongs in Full or remains an explicit
  advanced selection.
- Whether user settings import should merge individual keys or replace the
  complete settings file after backup.
- Which additional distributions are worth supporting after Arch.
