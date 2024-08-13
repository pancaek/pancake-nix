{
  lib,
  pkgs,
  config,
  ...
}:
# with lib;
let
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.modules.quiet-boot;
in
{
  # Declare what settings a user of this module can set.
  options.modules.quiet-boot = {
    enable = lib.mkEnableOption "Enable ptions to achieve a quiet boot";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {
    boot.plymouth.enable = true;
    boot.initrd.verbose = false;
    boot.kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };
}
