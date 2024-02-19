{ lib, pkgs, config, ... }:
with lib;
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.modules.wayland;
in
{
  # Declare what settings a user of this module can set.
  options.modules.quiet-boot = {
    enable = mkEnableOption "Enable options to make Wayland play nice";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config = mkIf cfg.enable {
    # Enable Ozone Wayland support in Chromium and Electron based applications
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      # XCURSOR_SIZE = "24";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };
}
