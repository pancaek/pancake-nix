{
  config,
  pkgs,
  lib,
  inputs,

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
    zsh-completions
    fastfetch
    # vscode-fhs
    (wrapApp {
      pkg = vesktop;
      flags = "--unset NIXOS_OZONE_WL";
    })
    gh
    (reaper.overrideAttrs (prev: {
      postInstall = (prev.postInstall or "") + ''
        rm $out/opt/REAPER/libSwell.so
        ln -s ${libswell}/lib/libSwell.so $out/opt/REAPER/libSwell.so
      '';
    }))
  ];

  xdg.configFile."REAPER" = {
    source = pkgs.symlinkJoin {
      name = "reaper-userplugins";
      paths = with pkgs; [
        reaper-sws-extension
        reaper-reapack-extension
      ];
    };
    recursive = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      nix-update = "sudo nixos-rebuild switch";
      nix-clean = "sudo nix-collect-garbage -d";
      cat = "bat";
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

    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/${config.programs.zsh.dotDir}/.p10k.zsh

      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

      bindkey '^[[3~' delete-char
      bindkey '^H' backward-delete-word

      setopt globdots # show dotfiles in autocomplete list

      # Color man pages

      # https://bbs.archlinux.org/viewtopic.php?id=287185
      export GROFF_NO_SGR=1

      export LESS_TERMCAP_mb=$'\E[01;32m'
      export LESS_TERMCAP_md=$'\E[01;32m'
      export LESS_TERMCAP_me=$'\E[0m'
      export LESS_TERMCAP_se=$'\E[0m'
      export LESS_TERMCAP_so=$'\E[01;47;34m'
      export LESS_TERMCAP_ue=$'\E[0m'
      export LESS_TERMCAP_us=$'\E[01;36m'
      export LESS=-R

      hx () {
        command hx "$@"
        print -n '\033[0 q'
      }

      mvbynix () {
        dir="$1" || return
        prefix=''${dir:0:2}
        dest=~/Documents/Git/nixpkgs/pkgs/by-name/$prefix/$dir
        mkdir -p "$(dirname "$dest")"
        mv "$dir" "$(dirname "$dest")"
        if [ -f "$dest/default.nix" ]; then
          mv "$dest/default.nix" "$dest/package.nix"
        fi

        hx $dest/package.nix
        hx ~/Documents/Git/nixpkgs/pkgs/top-level/all-packages.nix
        git add ~/Documents/Git/nixpkgs
        git commit -m "$dir: modernize, move to by-name/"
      }

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

  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.git = {
    enable = false;
    aliases = {
      amend = "commit --amend -C HEAD";
    };

    extraConfig = {
      core = {
        editor = "hx";
      };
      diff = {
        algorithm = "patience";
        compactionHeuristic = true;
      };
    };
  };

  services.mpris-proxy.enable = true;
  programs.helix = {
    enable = true;
    # package = inputs.helix.packages.${pkgs.hostPlatform.system}.default;
    package = pkgs.helix;
    extraPackages = with pkgs; [
      # system clipboard yank
      xclip
      # lsp
      nixd
      nil
      nixfmt-rfc-style
      texlab
    ];
    settings = {
      theme = "base16_terminal";
      editor.cursor-shape.insert = "bar";
      editor.lsp.display-inlay-hints = true;
      editor.end-of-line-diagnostics = "hint";
      editor.inline-diagnostics.cursor-line = "warning";
    };
    languages.language-server = {
      nixd = {
        command = "nixd";
      };
      rust-analyzer.config = {
        check.command = "clippy";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        block-comment-tokens = [
          {
            start = "/*";
            end = "*/";
          }
        ];
        formatter = {
          command = "nixfmt";
          args = [ ];
        };

        language-servers = [
          "nixd"
          "nil"
        ];
      }
      {
        name = "latex";
        auto-format = true;
      }
    ];
  };
  programs.obs-studio.enable = true;
}
