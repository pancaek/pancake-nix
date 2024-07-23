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
  cfg = config.modules.ibus;
in
{
  # Declare what settings a user of this module can set.
  options.modules.ibus = {
    enable = lib.mkEnableOption "Enable ibus and ime tweaks";
    engines = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
    };
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {

    # Enable sound with pipewire.
    # Wonky in Wayland
    i18n.inputMethod = {
      enabled = "ibus";
      ibus = {
        engines = cfg.engines;
      };
    };
  };
}
