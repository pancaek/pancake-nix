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
  cfg = config.modules.pancake-bspwm;
in
{

  imports = [
    ../kvantum.nix
    ../piper.nix
    ../polkit-auth.nix
  ];
  # Declare what settings a user of this module can set.
  options.modules.pancake-bspwm = {
    enable = lib.mkEnableOption "Sway and stuff!";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {
    services.xserver.windowManager.bspwm.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    modules.polkit-auth = {
      enable = true;
      agent = "gnome";
    };
    environment.systemPackages = with pkgs; [
      dunst
      kitty
      rofi
      copyq
      dex
      flameshot
      playerctl
      networkmanagerapplet
      polybar
      xss-lock
      betterlockscreen
      feh
      picom
      polybar-pulseaudio-control
      pavucontrol
    ];
  };

  programs.kvantum.enable = true;
}
