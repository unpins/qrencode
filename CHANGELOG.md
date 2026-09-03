# Changelog

## [Unreleased]

### Changed

- The Windows binary is now built by the same compiler as the Linux and macOS
  ones, and is less than half the size: 426 KB to 200 KB. `--version` and
  writing a real PNG were checked on Windows 10.

  It now uses the Universal C Runtime, which is part of Windows 10 and later.
  On Windows 7 or 8.1 that runtime has to be installed first — it comes through
  Windows Update. The previous binary did not need it.
