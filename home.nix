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
      nix-update = "sudo nixos-rebuild switch";
      nix-clean = "sudo nix-collect-garbage -d";
      cat = "bat";
    };
    dotDir = ".config/zsh";
    history.path = "${config.xdg.configHome}/zsh/zsh_history";
    historySubstringSearch = {
      enable = true;
      searchUpKey = "$terminfo[kcuu1]";
      searchDownKey = "$terminfo[kcud1]";
    };
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

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
