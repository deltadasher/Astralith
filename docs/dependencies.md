# Dependencies

Astralith is modular: missing optional tools disable their related controls
rather than preventing the shell from starting.

Run `./scripts/doctor` (or `astralithctl doctor` after installation) to inspect
the current machine without installing or changing anything.

## Core

- Niri
- Quickshell with Qt 6 and Wayland support
- A compositor implementing `ext-session-lock-v1` and a working PAM `login`
  profile for Umbra
- Bash and Python 3
- PipeWire tools (`wpctl`) and PulseAudio compatibility utilities (`pactl`)

The default typography uses JetBrains Mono and Iosevka Nerd Font. Other faces
can be selected in Observatory Settings, which reports Fontconfig fallbacks.

## Feature backends

| Feature | Recommended tools |
| --- | --- |
| Wi-Fi and Ethernet | NetworkManager and `nmcli` |
| Bluetooth | BlueZ and `bluetoothctl` |
| Clipboard history | `wl-clipboard` and `cliphist` |
| Screenshots | `grim`, `slurp`, and `wl-copy` |
| Screenshot editing | `satty` |
| Screen recording | `gpu-screen-recorder` |
| Image wallpapers | `awww` plus `awww-daemon`; `swaybg` or `swww` are fallbacks |
| Video wallpapers | `mpvpaper` |
| Adaptive palette | `matugen`; `ffmpeg` is used to sample video walls |
| Media spectrum | `cava` |
| Equalizer presets | EasyEffects |
| Brightness | `brightnessctl` |
| Power profiles | `powerprofilesctl` |
| Session lock | Quickshell PAM module and `/etc/pam.d/login` |

Weather and synchronized lyric lookup use ordinary HTTPS requests and retain
local caches when their services are temporarily unavailable.

## Default applications

Terminology, Firefox, and Nautilus are defaults rather than hard dependencies.
They can be changed under Observatory Settings -> System.
