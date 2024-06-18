{ lib, pkgs, config, ... }:
with lib;
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.programs.piper;
in
{
  # Declare what settings a user of this module can set.
  options.programs.piper = {
    enable = mkEnableOption "piper";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config = mkIf cfg.enable {
    services.ratbagd.enable = true;
    environment.systemPackages = [ pkgs.piper ];
  };
}
