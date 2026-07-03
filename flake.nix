{
  description = "qrencode (QR code generator CLI) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Single CLI upstream (`qrencode`). `pkgsStatic.qrencode` cross-builds
  # cleanly on linux / darwin / mingw; only override is the shared
  # `nativeFixes.qrencode` (drop `doCheck`, which otherwise drags SDL2 →
  # libglvnd through nativeCheckInputs — libglvnd is `badPlatforms.isStatic`
  # on pkgsStatic). See nix-lib/native-overlay/qrencode.nix.
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

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        programs = [{ name = "qrencode"; }];
      };
      build = pkgs:
        (ulib.nativeFixes.qrencode pkgs.pkgsStatic).overrideAttrs (old:
          pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
            preConfigure = (old.preConfigure or "") + ''
              configureFlagsArray+=("--disable-shared")
            '';
          });
      windowsBuild  = pkgs: ulib.nativeFixes.qrencode (ulib.mingwStaticCross pkgs);
    };
}
