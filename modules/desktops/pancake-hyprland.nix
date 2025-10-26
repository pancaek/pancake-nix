{
  lib,
  pkgs,
  config,
  self,
  ...
}:

let
  cfg = config.my.modules.pancake-hyprland;
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports = [
    # ../kvantum.nix
    # ../piper.nix
  ];

  options.my.modules.pancake-hyprland = {
    enable = lib.mkEnableOption "My personal gnome defaults, very opinionated, proceed with caution";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.gdm.enableGnomeKeyring = true;
    boot = {

      kernelParams = lib.mkIf isNvidia [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      ];
      extraModprobeConfig = lib.mkIf isNvidia "options nvidia NVreg_UsePageAttributeTable=1";
    };

    services = {

      xserver = {
        displayManager.gdm = {
          enable = true;
          wayland = true;
          autoSuspend = false;
        };
        excludePackages = with pkgs; [ xterm ];
      };
      gnome = {
        gnome-online-accounts.enable = true;
        evolution-data-server.enable = true;
        gnome-keyring.enable = true;
      };
      accounts-daemon.enable = true;

      udisks2.enable = true;
      gvfs.enable = true;
      geoclue2.enable = true;
    };
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };
      hyprlock.enable = true;
      waybar.enable = true;
      dconf.enable = true;
      nm-applet.enable = true;
    };
    systemd = {
      user.services = {
        polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        hyprland-session = {
          description = "Hyprland compositor session";
          bindsTo = [ "graphical-session.target" ];
          wants = [
            "graphical-session-pre.target"
            "xdg-desktop-autostart.target"
          ];
          after = [ "graphical-session-pre.target" ];
          before = [ "xdg-desktop-autostart.target" ];
        };
      };
    };
    environment.sessionVariables.NIXOS_OZONE_WL = 1;

    # NOTE: https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1366902737
    # AND: https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1366902737
    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
        (
          with pkgs.gst_all_1;
          [
            gst-plugins-good
            gst-plugins-bad
            gst-plugins-ugly
            gst-libav
          ]
        );
    environment.systemPackages = (
      with pkgs;
      [
        caffeine-ng
        anyrun
        hyprshot
        glib
        gnome-online-accounts-gtk
        gsettings-desktop-schemas
        networkmanagerapplet
        swaynotificationcenter
        playerctl
        nwg-look
        wezterm
        nwg-displays
        gapless
        endeavour
        fragments
        papers
        gnome-epub-thumbnailer
        libheif
        gnome-calendar
        gnome-weather
        gnome-clocks

        (makeDesktopItem {
          desktopName = "Caffeine-ng";
          name = "caffeine";
          noDisplay = true;
        })
        nautilus
      ]
    );

    my.programs.kvantum.enable = true;

    systemd.tmpfiles.rules =
      let
        sourcePath = "/home/pancaek/.config/monitors.xml";
        destPath = "/run/gdm/.config/monitors.xml";
      in
      [
        "C ${destPath} 644 gdm gdm - ${sourcePath}"
      ];

    home-manager.sharedModules =
      let
        autostartItem = title: commandList: {
          xdg.configFile."autostart/${title}.desktop".text =
            (pkgs.makeDesktopItem {
              desktopName = title;
              name = title;
              exec =
                if builtins.length commandList == 1 then
                  builtins.elemAt commandList 0
                else
                  "sh -c '${lib.concatStringsSep " && " commandList}'";
            }).text;
        };
      in
      [
        (autostartItem "discord" [ "vesktop --start-minimized" ])
        (autostartItem "element" [ "element-desktop --hidden" ])
        { services.caffeine.enable = true; }
      ];
  };
}
