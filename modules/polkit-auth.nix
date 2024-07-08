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
  cfg = config.modules.polkit-auth;
  agents = {
    "gnome" = {
      package = pkgs.polkit_gnome;
      script = pkgs.writeShellScriptBin "start-gnome-polkit" ''
        exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      '';
    };
    "kde" = {
      package = pkgs.kdePackages.polkit-kde-agent-1;
      script = pkgs.writeShellScriptBin "start-kde-polkit" ''
        exec ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1
      '';
    };
  };
in
{
  # Declare what settings a user of this module can set.
  options.modules.polkit-auth = {
    enable = lib.mkEnableOption "Enable polkit";
    agent = lib.mkOption {
      description = "Auth agent to enable/make acessible on PATH";
      type =
        with lib.types;
        nullOr (enum [
          "gnome"
          "kde"
        ]);
      default = null;
    };
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {

    security.polkit.enable = true;

    environment.systemPackages = lib.mkIf (cfg.agent != null) [
      agents.${cfg.agent}.script
      agents.${cfg.agent}.package
    ];
  };
}
