# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common.nix
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    grub = {
      efiSupport = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
      # useOSProber = true;
    };
  };
  networking.hostName = "pancake-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  my.modules.pancake-hyprland.enable = false;
  my.modules.pancake-gnome.enable = true;

  my.modules.ibus = {
    enable = true;
    engines = with pkgs.ibus-engines; [ mozc-ut ];
  };
  my.programs.piper = {
    enable = true;
    experimental = true;
  };

  # NOTE: QMK udev rules
  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = (
    with pkgs;
    [
      qmk
      cameractrls-gtk4
      element-desktop
      (runCommand "foliate" { buildInputs = [ makeWrapper ]; } ''
        mkdir $out
        # Link every top-level folder from foliate to our new target
        ln -s ${foliate}/* $out
        # Except the bin folder
        rm $out/bin
        mkdir $out/bin
        # We create the bin folder ourselves and link every binary in it
        ln -s ${foliate}/bin/* $out/bin
        # Except the main binary
        rm $out/bin/foliate
        # Because we create this ourself, by creating a wrapper
        makeWrapper ${lib.getExe foliate} $out/bin/foliate \
        --set WEBKIT_DISABLE_DMABUF_RENDERER=1
      '')
      zoom-us
      texliveFull
      prismlauncher
      praat
    ]
  );

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Only needed for the VM
  # services.spice-vdagentd.enable = true;
}
