# qrencode

Standalone build of [qrencode](https://fukuchi.org/works/qrencode/) — Kentaro Fukuchi's QR code generator CLI.

[![CI](https://github.com/unpins/qrencode/actions/workflows/qrencode.yml/badge.svg)](https://github.com/unpins/qrencode/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Generates QR codes from text input as PNG, SVG, EPS, ANSI, ASCII, or UTF-8 output.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin qrencode
```

Or run without installing:

```bash
unpin run qrencode
```

## Build locally

```bash
nix build github:unpins/qrencode
./result/bin/qrencode --version
```

Or run directly:

```bash
nix run github:unpins/qrencode -- 'hello' -o hello.png
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/qrencode/releases) page has standalone binaries for manual download.

## Build notes

- **Windows:** `mingw` cross, single `.exe`, no companion DLLs.
- **No upstream features disabled** on any platform.

Platform fixes live in [`nix-lib/native-overlay/qrencode.nix`](https://github.com/unpins/nix-lib/blob/main/native-overlay/qrencode.nix).
