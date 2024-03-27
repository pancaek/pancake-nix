{ lib, pkgs, config, ... }:
with lib;
let
  # Shorter name to access final settings a
  # user HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.modules.pancake-gnome;
in
{
  # Declare what settings a user of this module can set.
  options.modules.pancake-gnome = {
    enable = mkEnableOption "My personal gnome defaults, very opinionated, proceed with caution";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this module ENABLED this module
  # by setting "modules.pancake-gnome.enable = true;".
  config = mkIf cfg.enable {

    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.systemPackages =
      (with pkgs;
      [
        gnome-extension-manager
        gnome.gnome-tweaks
        gnome.gnome-terminal
        g4music
        endeavour
        celluloid
      ]) ++ (with pkgs.gnomeExtensions; [
        appindicator
        ddterm
        rounded-corners
        vertical-workspaces
        caffeine
        clipboard-history
        user-themes
        # alphabetical-app-grid #! Busted for now?
        custom-accent-colors
      ]);


    environment.gnome.excludePackages =
      (with pkgs;
      [
        gnome-tour
        gnome-connections
        gnome-console
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        epiphany # web browser
        geary # email reader
        totem # gnome video
        gnome-maps
        gnome-characters
        gnome-shell-extensions
      ]);

    services.xserver.excludePackages = (with pkgs; [ xterm ]);

  };
}
