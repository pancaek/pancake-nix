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

  nix = {
    # package = pkgs.nixUnstable;
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Fix localectl
  services.xserver.exportConfiguration = true;

  modules.ibus = {
    enable = true;
    engines = with pkgs.ibus-engines; [ mozc ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "compose:menu";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pancaek = {
    isNormalUser = true;
    description = "Pancake";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # ZSH
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  # NOTE: Enabled by default in programs.zsh.enable (needed for completions from home-manager)
  # environment.pathsToLink = [ "/share/zsh" ];

  modules.quiet-boot.enable = true;
  modules.audio.enable = true;
  modules.printing.enable = true;

  modules.pancake-gnome.enable = true;

  # XXX: Home manager extensions / ui tweaks (tabmanager)
  modules.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = (
    with pkgs;
    [
      git
      adw-gtk3
      (papirus-icon-theme.override { color = "indigo"; })
      volantes-cursors
      neofetch
      gh
      (mpv.override { scripts = [ mpvScripts.uosc ]; })
    ]
    ++ [
      nixd
      nixfmt-rfc-style
    ]
    ++ [ nltch.spotify-adblock ]
  );

  fonts.packages = (
    with pkgs;
    [
      meslo-lgs-nf
      noto-fonts
      noto-fonts-cjk
      komika-fonts
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
  # system.stateVersion = "24.05"; # Did you read the comment?

  # Only needed for the VM
  # services.spice-vdagentd.enable = true;
}