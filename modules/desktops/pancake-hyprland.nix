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
    ../kvantum.nix
    ../piper.nix
  ];

  options.my.modules.pancake-hyprland = {
    enable = lib.mkEnableOption "My personal gnome defaults, very opinionated, proceed with caution";
  };

  config = lib.mkIf cfg.enable {

    boot.kernelParams = lib.mkIf isNvidia [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

    hardware.nvidia.powerManagement.enable = lib.mkIf isNvidia true;

    # Making sure to use the proprietary drivers until the issue above is fixed upstream
    hardware.nvidia.open = lib.mkIf isNvidia (lib.mkForce false);

    services.xserver = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
        autoSuspend = false;
      };
      excludePackages = with pkgs; [ xterm ];
    };

    programs.hyprland.enable = true;
    programs.hyprlock.enable = true;
    programs.waybar.enable = true;

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
        kitty
        nwg-look
        gapless
        endeavour
        fragments
        papers
        gnome-epub-thumbnailer
        libheif
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
