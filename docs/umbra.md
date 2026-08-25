# Umbra session veil

Umbra is Astralith's Niri-native lock screen. It runs as a dedicated Quickshell
instance, uses the Wayland session-lock protocol to cover every output, and uses
PAM to authenticate the current user. The password remains in memory only for
the active prompt and is cleared after every result.

## Safe first test

Preview the complete visual surface without locking the compositor or invoking
PAM:

```sh
astralithctl preview-lock
```

Press `Escape` to leave the preview. The same preview is available under
Observatory Settings -> Lock.

## Locking

After the preview looks correct, lock with either:

```sh
astralithctl lock
```

or `Super+Alt+L` when using Astralith's example Niri configuration. Enter
submits the password; `Ctrl+U` clears it.

The default PAM service is `login`, resolved from `/etc/pam.d/login`. It can be
changed under Observatory Settings -> Lock for distributions that provide a
dedicated lock profile.

## Surface behavior

- One secure `WlSessionLockSurface` is created for every active output.
- The lock target remains engaged across QML hot reloads; the ordinary desktop
  shell and the non-locking preview are separate from the secure lock process.
- Wallpaper diffusion falls back to the bundled Umbra sky when the current wall
  is a video or unavailable.
- The authentication rail fills continuously as the passphrase is entered and
  changes state during verification or rejection.
- Cached weather, battery, network, and safe MPRIS controls remain available
  without exposing desktop windows.
- Motion, wallpaper diffusion, media, and weather are independently configurable.

## Recovery note

A conforming Wayland compositor intentionally remains locked if the lock client
crashes. Validate the preview and PAM service before the first real lock. If a
development build fails while locked, switch to a TTY, repair or stop the broken
instance, and start a known-good locker before returning to the graphical session.

Display-manager greeter styling is a separate phase: it runs before Astralith's
user session and must not reuse the in-session PAM state directly.
