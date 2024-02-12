# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable flake support
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Bootloader.
  # Use the systemd-boot EFI boot loader.
  #  boot.loader.systemd-boot.enable = true;
  #  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    grub = {
      efiSupport = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
    };
  };
  boot.plymouth.enable = true;
  boot.kernelParams = [ "quiet" "splash" "vga=current" "udev.log_priority=3" ];
  networking.hostName = "pancake-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = defaulLocale;
      LC_IDENTIFICATION = defaulLocale;
      LC_MEASUREMENT = defaulLocale;
      LC_MONETARY = defaulLocale;
      LC_NAME = defaulLocale;
      LC_NUMERIC = defaulLocale;
      LC_PAPER = defaulLocale;
      LC_TELEPHONE = defaulLocale;
      LC_TIME = defaultLocale;
    };
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus = { engines = with pkgs.ibus-engines; [ mozc ]; };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pancaek = {
    isNormalUser = true;
    description = "Devyn Boer";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    git
    firefox
    adw-gtk3
    papirus-icon-theme
    # papirus-folders # dunno why this is broken
    volantes-cursors
    gnome-extension-manager
    gnome.gnome-tweaks
    neofetch
    g4music
    endeavour
    qmk
    piper
    celluloid
    discord
    lutris
    obs-studio
    nixfmt
    vscode-fhs
    spotify
    gh
    reaper
  ]) ++ (with pkgs.gnomeExtensions; [ appindicator ddterm ]);
  # For piper
  services.ratbagd.enable = true;

  environment.gnome.excludePackages =
    (with pkgs; [ gnome-tour gnome-connections ]) ++ (with pkgs.gnome; [
      gnome-music
      epiphany # web browser
      geary # email reader
      totem # gnome video
      gnome-maps
    ]);
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };
  services.xserver.excludePackages = (with pkgs; [ xterm ]);

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Only needed for the VM
  services.spice-vdagentd.enable = true;
}
