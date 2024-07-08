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
  cfg = config.modules.printing;
in
{
  # Declare what settings a user of this module can set.
  options.modules.printing = {
    enable = lib.mkEnableOption "Enable options for printing";
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module
  # by setting "services.hello.enable = true;".
  config = lib.mkIf cfg.enable {
    # Enable printing
    services.printing.enable = true;
    # Network discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
