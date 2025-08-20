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
  cfg = config.my.programs.spotify;
in
{
  # Declare what settings a user of this module can set.
  options.my.programs.spotify = {
    enable = lib.mkEnableOption "Enable options for spotify";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.spotify;
    };
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      (cfg.package.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            sed -i "s:^Exec=spotify %U:Exec=spotify --uri=\'%U\':" "$out/share/applications/spotify.desktop"
          '';
      }))
    ];
    # Local file discovery
    networking.firewall = {
      allowedUDPPorts = [ 5353 ];
      allowedTCPPorts = [ 57621 ];
    };
  };
}
