{ config, pkgs, ... }:

{
  home.username = "pancaek";
  home.homeDirectory = "/home/pancaek";
  home.stateVersion =
    "23.11"; # To figure this out you can comment out the line and see what version it expected.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = { update = "sudo nixos-rebuild switch"; };
  };
}
