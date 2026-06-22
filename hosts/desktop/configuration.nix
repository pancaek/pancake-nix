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
      device = "nodev";
      timeoutStyle = "hidden";
    };
  };
  networking.hostName = "pancake-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  my.modules.pancake-hyprland.enable = false;
  my.modules.pancake-gnome.enable = true;
  my.programs.piper.enable = true;

  # NOTE: QMK udev rules
  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = (
    with pkgs;
    [
      qmk
      cameractrls-gtk4
      (wrapApp {
        pkg = (
          unstable.element-desktop.overrideAttrs (old: {
            desktopItems = [
              (makeDesktopItem {
                name = "element-desktop";
                exec = "element-desktop %u";
                icon = "element";
                desktopName = "Element";
                genericName = "Matrix Client";
                comment = old.meta.description;
                categories = [
                  "Network"
                  "InstantMessaging"
                  "Chat"
                ];
                startupWMClass = "element";
                mimeTypes = [
                  "x-scheme-handler/element"
                  "x-scheme-handler/io.element.desktop"
                ];
              })
            ];

          })
        );
        # flags = "--add-flags --wayland-text-input-version=3";
      })
      (wrapApp {
        pkg = foliate;
        flags = "--set WEBKIT_DISABLE_DMABUF_RENDERER=1";
      })
      zoom-us
      texliveFull
      prismlauncher
      # Workaround for:
      # https://github.com/praat/praat.github.io/issues/2209
      (wrapApp {
        pkg = praat;
        flags = "--set AUDIO_BACKED=pulseaudio";
      })
      unstable.r2modman
      signal-desktop
      cine
      ((unstable.cockatrice.override { qt5 = unstable.qt6; }).overrideAttrs (old: rec {
        version = "2026-05-08-Release-3.0.0";
        src = fetchFromGitHub {
          owner = "Cockatrice";
          repo = "Cockatrice";
          tag = version;
          hash = "sha256-jLHGWtHbJTQ5Gefrnd8aUq1K3f2QzyE4YU5bW//gH4Y=";
        };
      }))
      # fadein
      # open-scq30
      ((plugdata.override { copyDesktopItems = null; }).overrideAttrs {
        installPhase = ''
          runHook preInstall

          cd .. # build artifacts are placed inside the source directory for some reason
          mkdir -p $out/bin $out/lib/clap $out/lib/lv2 $out/lib/vst3
          cp    Plugins/Standalone/plugdata      $out/bin
          cp -r Plugins/CLAP/plugdata{,-fx}.clap $out/lib/clap
          cp -r Plugins/VST3/plugdata{,-fx}.vst3 $out/lib/vst3
          cp -r Plugins/LV2/plugdata{,-fx}.lv2   $out/lib/lv2

          install -Dm444 Resources/Icons/plugdata_logo_linux.png $out/share/icons/hicolor/512x512/apps/plugdata.png
          install -Dm444 Resources/Installer/plugdata.desktop -t $out/share/applications

          runHook postInstall
        '';
      })
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
  nixpkgs.config = {
    allowUnfree = true;
    allowAliases = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Only needed for the VM
  # services.spice-vdagentd.enable = true;

  my.modules.ibus.engines = [
    pkgs.ibus-viossa
    pkgs.ibus-engines.table
  ];
}
