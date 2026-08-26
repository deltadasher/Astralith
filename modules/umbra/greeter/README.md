# Umbra SDDM greeter

This directory is a standalone Qt 6 SDDM theme. It deliberately does not import
Astralith's Quickshell singletons: the greeter runs as the unprivileged `sddm`
user before a desktop session or user D-Bus exists.

The shared name describes a visual system, not a shared authentication process:

- the in-session Umbra veil uses Quickshell, PAM, and `ext-session-lock-v1`;
- this greeter uses SDDM's user, session, login, and power interfaces;
- neither component reads or transfers the other's password state.

## Safe preview

```sh
astralithctl greeter preview
```

SDDM test mode provides synthetic users and sessions and cannot start a real
desktop session. Close the preview with the compositor's ordinary close-window
binding.

## Install and activate

Install without changing the current greeter:

```sh
astralithctl greeter install
```

After previewing, select Umbra for the next SDDM screen:

```sh
astralithctl greeter activate
```

This writes only `/etc/sddm.conf.d/30-astralith-umbra.conf`; the existing lower
priority theme configuration remains available. Revert with:

```sh
astralithctl greeter deactivate
```

The installer derives `theme.conf` from Astralith's cached Matugen palette and
falls back to the built-in lavender spectrum when no cache exists. SDDM receives
only the rendered colors under `/usr/share/sddm/themes/astralith-umbra`; it does
not need permission to read a user's home directory.
