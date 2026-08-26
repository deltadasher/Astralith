# Astralith installer

The installer is a Rust application with a `ratatui` interface, a serializable
planner, and a journaled executor. It stages and verifies the runtime before
activation, backs up replaced user paths, and rolls Astralith-owned file
changes back when a later operation fails.

From the repository root:

```bash
./scripts/install
./scripts/install dry-run
./scripts/install dry-run --profile core
./scripts/install dry-run --profile full --niri replace --umbra greeter-preview
./scripts/install dry-run --format json > plan.json
./scripts/install report
./scripts/install apply --profile recommended
./scripts/install apply --profile full --niri replace --umbra greeter-preview
```

`dry-run` never invokes `pacman`, an AUR helper, `sudo`, `systemctl`, Niri,
Quickshell, or an Astralith mutation script. It reads machine state, constructs
typed operations, and renders the plan. Tests run the compiled CLI against an
absent fake home and assert that the directory remains absent.

`apply` renders the execution plan and requires typing `INSTALL`. Pass `--yes`
only after reviewing a saved dry run. Official packages are installed through
`sudo` or `doas` with `pacman -S --needed`; AUR-only capabilities use an
existing `paru` or `yay`. Package additions are journaled but deliberately not
removed by rollback, since another application may start using them.

The executor installs into `$XDG_DATA_HOME/astralith`, publishes the Quickshell
and `astralithctl` links only after staging passes integrity checks, validates
the installed machine with `scripts/doctor`, and records each run under
`$XDG_STATE_HOME/astralith/installer/transactions`.

The checkout is treated only as installation input. The planned user-local
runtime destination is `$XDG_DATA_HOME/astralith` (normally
`~/.local/share/astralith`), with entrypoint links under XDG config and
`~/.local/bin`. Development checkout paths must never become installed link
targets.

Current keyboard controls in the TUI:

- Enter or Tab: advance through Welcome, Preflight, Profile, Scope, and Review.
- Backspace or Shift-Tab: return to the previous screen.
- Up/Down or `j`/`k`: select a profile, integration, or review-plan row.
- Left/Right or `h`/`l`: change the selected profile or integration value.
- `1`, `2`, `3`: select Core, Recommended, or Full directly on the profile screen.
- `q` or Escape: exit without changing the machine.
- Enter on Review: leave the TUI, show the final plan, and request the exact
  `INSTALL` confirmation.

Preflight detects the current session, display manager, portable hardware,
connected DRM outputs, and known notification, bar, wallpaper, clipboard, and
lock processes. Detection is file and environment based; it does not start,
stop, enable, or query services.

Implementation and transaction requirements live in
[`docs/installer-design.md`](../docs/installer-design.md).
