{ lib, pkgs, config, ... }:
with lib;
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.modules.quiet-boot;
in
{
  # Declare what settings a user of this module can set.
  options.modules.quiet-boot = {
    enable = mkEnableOption "Enable ptions to achieve a quiet boot";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config = mkIf cfg.enable {
    boot.plymouth.enable = true;
    boot.kernelParams = [ "quiet" "splash" "vga=current" "udev.log_priority=3" ];
  };
}
