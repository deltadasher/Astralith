# Caelestia.Blobs runtime dependency

Astralith can optionally use the native `Caelestia.Blobs` QML module from
[caelestia-dots/shell](https://github.com/caelestia-dots/shell).

The build helper checks out the unmodified upstream source at commit
`1d0e5a588c61f1d905eba5fe8446ec222d37f50c` into the user's cache and builds
only `plugin/src/Caelestia/Blobs`. Upstream source is not copied into this
repository.

Caelestia Shell and this native module are licensed under GPL-3.0. The upstream
checkout retains Caelestia's complete `LICENSE`, history, and authorship. This
optional integration must remain disabled for any Astralith distribution whose
licensing is not GPL-3.0-compatible.

Build it with:

```bash
./scripts/astralithctl build-native-blobs
./scripts/astralithctl restart
```

On Arch Linux, building requires `qt6-shadertools` in addition to the normal
Qt 6 development files.
