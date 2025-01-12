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
  cfg = config.my.modules.ibus;
in
{
  # Declare what settings a user of this module can set.
  options.my.modules.ibus = {
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
      enable = true;
      type = "ibus";
      ibus = {
        engines = cfg.engines;
      };
    };

    home-manager.sharedModules =
      let
        usesMozc = (lib.packageInList "mozc" cfg.engines) || (lib.packageInList "mozc-ut" cfg.engines);
      in
      lib.mkIf usesMozc [
        { xdg.configFile."mozc/ibus_config.textproto".source = ../home/mozc/ibus_config.textproto; }
      ];
  };
}
