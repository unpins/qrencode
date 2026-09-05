# Changelog

## [Unreleased]

### Fixed

- On Windows, writing an image to standard output (`qrencode -o - ... > qr.png`)
  produced a file that was not a valid PNG. Output to standard output now
  matches what `-o FILENAME` writes, byte for byte.
- On Windows, reading input from a file (`-r`) or from a pipe altered the data
  before encoding it: carriage returns were dropped and everything after a
  `0x1A` byte was ignored, so the same input encoded to a different QR code
  than on Linux and macOS. Input is now taken exactly as given, which is what
  `-8` (8-bit mode) needs to encode arbitrary bytes.

  Note for Windows users: `echo text | qrencode` now encodes the carriage
  return that `cmd.exe` adds to the line. Use `qrencode text` to encode just
  the text.

### Changed

- The Windows binary is now built by the same compiler as the Linux and macOS
  ones, and is less than half the size: 426 KB to 200 KB. `--version` and
  writing a real PNG were checked on Windows 10.

  It now uses the Universal C Runtime, which is part of Windows 10 and later.
  On Windows 7 or 8.1 that runtime has to be installed first — it comes through
  Windows Update. The previous binary did not need it.
