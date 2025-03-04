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
  cfg = config.my.xdg;
in
{
  # Declare what settings a user of this module can set.
  options.my.xdg = {
    enable = lib.mkEnableOption "Enable options for xdg compliance";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {
    nix.settings.use-xdg-base-directories = true;
    environment = {
      shellAliases = {
        wget = ''wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'';
        nvidia-settings = ''nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings'';
      };
      etc.npmrc.text = ''
        prefix=''${XDG_DATA_HOME}/npm
        cache=''${XDG_CACHE_HOME}/npm
        init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
      '';
      sessionVariables = {
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_STATE_HOME = "$HOME/.local/state";
        CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
        XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
        XCOMPOSEFILE = "$XDG_CONFIG_HOME/X11/XCompose";
        NPM_CONFIG_CACHE = "$XDG_CACHE_HOME/npm";
        NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
        HISTFILE = "$XDG_STATE_HOME/bash/history";
      };
    };
  };
}
