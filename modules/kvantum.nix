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
  cfg = config.my.programs.kvantum;
in
{
  # Declare what settings a user of this module can set.
  options.my.programs.kvantum = {
    enable = lib.mkEnableOption "kvantum";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {
    qt.enable = true;
    qt.platformTheme = "qt5ct";
    qt.style = "kvantum";
    environment.extraInit = "unset QT_STYLE_OVERRIDE";
  };
}
