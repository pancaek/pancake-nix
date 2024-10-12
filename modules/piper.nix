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

  piperPackage = lib.overrideAttrsIf (cfg.experimental) (
    prev:
    let
      version = "0.8";
    in
    {
      inherit version;
      src = pkgs.fetchFromGitHub {
        inherit (prev.src) owner repo;
        rev = version;
        hash = "sha256-j58fL6jJAzeagy5/1FmygUhdBm+PAlIkw22Rl/fLff4=";
      };
      # Remove "-Dtests=false" flag that doesn't exist in the new version
      # https://github.com/libratbag/piper/commit/a8ba2124318cc12477ffee932c7ae9c3614926c2
      mesonFlags = lib.remove "-Dtests=false" prev.mesonFlags;
    }
  ) pkgs.piper;

  ratbagPackage = lib.overrideAttrsIf (cfg.experimental) (
    prev:
    let
      version = "0.18";
    in
    {
      inherit version;
      src = pkgs.fetchFromGitHub {
        inherit (prev.src) owner repo;
        rev = "v${version}";
        hash = "sha256-dAWKDF5hegvKhUZ4JW2J/P9uSs4xNrZLNinhAff6NSc=";
      };
    }
  ) pkgs.libratbag;
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
