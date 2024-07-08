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
  cfg = config.modules.wayland;
in
{
  # Declare what settings a user of this module can set.
  options.modules.wayland = {
    enable = lib.mkEnableOption "Enable options to make Wayland play nice";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable { environment.sessionVariables.NIXOS_OZONE_WL = "1"; };
}
