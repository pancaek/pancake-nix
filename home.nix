{ config, pkgs, ... }:

{
  home = {
    username = "pancaek";
    homeDirectory = "/home/pancaek";
    stateVersion =
      "23.11"; # To figure this out you can comment out the line and see what version it expected.
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "sudo nixos-rebuild switch";
      cat = "bat";
    };
    dotDir = ".config/zsh";
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      style = "plain";
    };
  };
  programs.git = {
    enable = true;
    userName = "pancaek";
    userEmail = "devynrboer@gmail.com";
    aliases = { amend = "commit --amend"; };

    extraConfig = {
      diff = {
        algorithm = "patience";
        compactionHeuristic = true;
      };
    };
  };

  services.mpris-proxy.enable = true;
}
