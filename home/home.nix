{
  config,
  pkgs,
  lib,
  ...
}:

{
  home = {
    username = "pancaek";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.05"; # To figure this out you can comment out the line and see what version it expected.
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    obs-studio
    vscode-fhs
    reaper
    #   vesktop
    # (spotify.overrideAttrs (oldAttrs: rec {
    #   installPhase = let
    #     patchContext = ''
    #       cp "$out/share/spotify/spotify.desktop" "$out/share/applications/"
    #     '';
    #     patchString = ''
    #       sed -i "s:^Exec=:Exec=env -u WAYLAND_DISPLAY :" "$out/share/spotify/spotify.desktop"
    #     '';
    #   in builtins.replaceStrings [ patchContext ]
    #   [ (patchString + patchContext) ] oldAttrs.installPhase;
    # }))
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      nix-update = "sudo nixos-rebuild switch";
      nix-clean = "sudo nix-collect-garbage -d";
      cat = "bat";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      refresh = "source $HOME/${config.programs.zsh.dotDir}/.zshrc";
    };
    history.path = "$HOME/${config.programs.zsh.dotDir}/zsh_history";
    historySubstringSearch = {
      enable = true;
      searchUpKey = "$terminfo[kcuu1]";
      searchDownKey = "$terminfo[kcud1]";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/${config.programs.zsh.dotDir}/.p10k.zsh

      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

      bindkey '^[[3~' delete-char
      bindkey '^H' backward-delete-word
    '';

    initExtraBeforeCompInit = ''
      # p10k instant prompt
      P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
      [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"

      zstyle ':completion:*' rehash true                              # automatically find new exec>
      zstyle ':completion:*' menu select                              # Highlight menu selection
      zstyle ':completion::complete:*' gain-privileges 1              # sudo completions
      zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' # case insensitive
    '';
  };

  home.file."${config.programs.zsh.dotDir}/.p10k.zsh".source = ./p10k/p10k.zsh;

  programs.dircolors.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      style = "plain";
    };
  };
  programs.git = {
    enable = true;
    ***REMOVED***
    ***REMOVED***
    aliases = {
      amend = "commit --amend -C HEAD";
    };

    extraConfig = {
      core = {
        editor = "code --wait";
      };
      diff = {
        algorithm = "patience";
        compactionHeuristic = true;
      };
    };
  };

  services.mpris-proxy.enable = true;
}
