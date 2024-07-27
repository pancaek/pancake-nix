{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.programs.piper;

  piperPackage =
    if !cfg.experimental then
      pkgs.piper
    else
      pkgs.piper.overrideAttrs (prev: {
        src = pkgs.fetchFromGitHub {
          owner = "libratbag";
          repo = "piper";
          rev = "efa2712fcbc4ac1e9e9d1a7a85334c2a5dc9bab4";
          sha256 = "uC7BEKVPQz42rdutX4ft3W1MoUVlkFHq2RgQGKVhV2o=";
        };
        # Remove "-Dtests=false" flag that doesn't exist in the new version
        # https://github.com/libratbag/piper/commit/a8ba2124318cc12477ffee932c7ae9c3614926c2
        mesonFlags = lib.lists.remove "-Dtests=false" prev.mesonFlags;
      });

  ratbagPackage =
    if !cfg.experimental then
      pkgs.libratbag
    else
      pkgs.libratbag.overrideAttrs (prev: {
        src = pkgs.fetchFromGitHub {
          owner = "libratbag";
          repo = "libratbag";
          rev = "1c9662043f4a11af26537e394bbd90e38994066a";
          sha256 = "IpN97PPn9p1y+cAh9qJAi5f4zzOlm6bjCxRrUTSXNqM=";
        };
      });
in
{
  # Declare what settings a user of this module can set.
  options.programs.piper = {
    enable = lib.mkEnableOption "piper";
    experimental = lib.mkOption {
      description = "Use git piper";
      type = lib.types.bool;
      default = false;
    };

  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {
    services.ratbagd = {
      enable = true;
      package = ratbagPackage;
    };

    environment.systemPackages = [ piperPackage ];

  };
}
