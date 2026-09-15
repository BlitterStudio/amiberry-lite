# Amiberry-Lite

[![C/C++ CI](https://github.com/BlitterStudio/amiberry-lite/actions/workflows/c-cpp.yml/badge.svg)](https://github.com/BlitterStudio/amiberry-lite/actions/workflows/c-cpp.yml)
[![Development Builds](https://img.shields.io/badge/Dev%20Builds-nightly.link-orange)](https://nightly.link/BlitterStudio/amiberry-lite/workflows/c-cpp.yml/master)
[![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?logo=discord&logoColor=white)](https://discord.gg/wWndKTGpGV)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/X8X4FHDY4)

**Optimized Amiga emulator for Linux and macOS.**

Built on the WinUAE emulation core, Amiberry-Lite runs the full Amiga range —
from the A500 to the A4000 — on ARM, ARM64, x86-64 and RISC-V hardware, from a
Raspberry Pi to a desktop workstation.

Amiberry-Lite is the streamlined sibling of [Amiberry](https://github.com/BlitterStudio/amiberry).
It is based on an older version of the WinUAE core and has fewer features than
the full emulator — in return it is leaner and faster, particularly on
low-end hardware. Compatibility with demanding software is somewhat lower than
full Amiberry; if you need maximum accuracy, Android, Windows, libretro or the
ImGui GUI, use [Amiberry](https://github.com/BlitterStudio/amiberry) instead.

## Features

- **Amiga compatibility** — Built on the WinUAE core: OCS/ECS/AGA chipsets, expanded memory, Picasso96 RTG
- **WHDLoad Support** — Launch WHDLoad titles directly with automatic configuration
- **Custom Controls** — Per-game input mapping, RetroArch-compatible controller support
- **Virtual Keyboard** — On-screen keyboard for gamepad-only setups
- **Multiple disk formats** — ADF, ADZ, DMS, IPF (CAPSImage), RP9 and hard disk images

## Downloads

Prebuilt packages are published on the
[Releases](https://github.com/BlitterStudio/amiberry-lite/releases) page:

- **Linux**: `.deb` packages (Debian bullseye/bookworm/trixie — amd64, arm64, armhf)
- **macOS**: DMG for Apple Silicon (arm64)

## Building from Source

### Linux (Debian/Ubuntu)

```bash
sudo apt install cmake ninja-build build-essential \
  libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
  libflac-dev libmpg123-dev libpng-dev zlib1g-dev \
  libserialport-dev libportmidi-dev libenet-dev libmpeg2-dev libzstd-dev
```

### macOS

```bash
brew bundle   # uses the Brewfile in this repository
```

### Configure and build

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## Contributing

Contributions are welcome — bug reports, feature suggestions, and pull requests
all help make Amiberry-Lite better. See the
[Amiberry wiki](https://github.com/BlitterStudio/amiberry/wiki) for documentation
that applies to both projects.

## Support the Project

Amiberry-Lite is maintained by the same developer as Amiberry, as a free and
open source project under the [GPL v3 license](LICENSE). If it's useful to you,
consider supporting development on [Ko-fi](https://ko-fi.com/midwan) — or
[sponsor Amiberry](https://amiberry.com#sponsors) if you ship it in a
commercial product.

## Community

[![Discord](https://img.shields.io/badge/Discord-Join%20Chat-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/wWndKTGpGV)
[![Mastodon](https://img.shields.io/badge/Mastodon-Follow-6364FF?style=for-the-badge&logo=mastodon&logoColor=white)](https://mastodon.social/@midwan)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/X8X4FHDY4)

## License

Amiberry-Lite is licensed under the [GNU General Public License v3.0](LICENSE).
