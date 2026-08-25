# Services

Services expose stable QML state to every Astralith module:

| Service | Backend |
| --- | --- |
| `Niri.qml` | Niri socket and `niri msg` state |
| `Media.qml` | Quickshell MPRIS |
| `Audio.qml` | PipeWire/Pulse helpers |
| `NetState.qml` | NetworkManager and BlueZ helper |
| `DeviceState.qml` | UPower, brightness, and power profiles |
| `Notifications.qml` | notification server and in-session history |
| `Clipboard.qml` | wl-clipboard and cliphist |
| `Environment.qml` | wallpapers, screenshots, recording, and tools |
| `Weather.qml` | cached Open-Meteo adapter |
| `Lyrics.qml` | MPRIS, local cache, and LRCLIB adapter |
| `Spectrum.qml` | CAVA stream |
| `Equalizer.qml` | EasyEffects preset adapter |
| `SysStats.qml` | host telemetry helper |
| `Focus.qml` | persistent focus-cycle state |
| `Umbra.qml` | PAM/session-lock state and power actions |

Keep presentation out of services. Missing optional backends must leave a clear
availability value and must not make the QML singleton unavailable.

Detailed mixer, network, clipboard, spectrum, lyrics, recording, power-profile,
and folder telemetry follows the visibility of its owning Ephemeris surface.
Only small values consumed by Aperture or an active task may poll while every
expanded instrument is closed.
