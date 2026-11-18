{
  description = "qrencode (QR code generator CLI) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Single program upstream (`qrencode`). darwin re-adds `--disable-shared`
  # and Windows takes the binary-stdio patch (both below). The upstream suite
  # stays off: it only builds with `--with-tests`, which changes the
  # libqrencode that ships (nixpkgs runs it only in `passthru.tests`).
  #
  # darwin: mkStandaloneFlake's filterEnableStaticOnDarwin strips the Nix-level
  # `--disable-shared`, so libtool builds a `libqrencode.4.dylib` and the engine
  # linker chokes on the ELF `-soname`/`-platform_version` it emits. Re-add
  # `--disable-shared` via the bash configureFlagsArray (invisible to that filter)
  # so libtool stays static and the self-fold captures libqrencode.a. Same dodge
  # as xmllint/jq/tmux/file.
  outputs = { self, unpins-lib }:
    let ulib = unpins-lib.lib; in
    ulib.mkStandaloneFlake {
      inherit self;
      name = "qrencode";
      smoke = [ "--version" ];
      smokePattern = "^qrencode version [0-9]+\\.[0-9]+";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        # The `.exe` on the engine too, not the nixpkgs mingw-gcc cross.
        windows = true;
        programs = [{ name = "qrencode"; }];
      };
      build = pkgs:
        pkgs.pkgsStatic.qrencode.overrideAttrs (old:
          pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
            preConfigure = (old.preConfigure or "") + ''
              configureFlagsArray+=("--disable-shared")
            '';
          });
      # Windows: the CRT opens the standard streams in text mode, which mangled
      # both directions -- `-o -` wrote a PNG whose LF bytes had become CRLF
      # (not a PNG at all), and `-r FILE` / stdin dropped every CR and stopped
      # at the first 0x1A, so the same input file encoded to a different QR
      # code than on Linux. Both measured on Windows 10, both fixed by the
      # patch. (Thread safety stays off here -- upstream probes for `-lpthread`
      # and mingw names it winpthreads -- but the only lock is a lazy-init
      # guard inside libqrencode, and this artifact is a single-threaded CLI.)
      windowsBuild = pkgs:
        (ulib.mingwStaticCross pkgs).qrencode.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./qrencode-windows-binary-io.patch ];
        });
    };
}
