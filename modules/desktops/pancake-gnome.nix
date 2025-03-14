{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.my.modules.pancake-gnome;
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports = [
    ../kvantum.nix
    ../piper.nix
  ];

  options.my.modules.pancake-gnome = {
    enable = lib.mkEnableOption "My personal gnome defaults, very opinionated, proceed with caution";
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = 1;
    services.xserver = {
      displayManager.gdm = {
        enable = true;
        wayland = false;
        autoSuspend = false;
      };
      desktopManager.gnome.enable = true;
      excludePackages = with pkgs; [ xterm ];
    };

    # NOTE: https://gitlab.gnome.org/GNOME/gnome-control-center/-/issues/2570
    # I don't actually care about functionality this but I want the panel to load
    services.fwupd.enable = true;

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

    fonts.fontconfig.localConf = ''
      <match target="pattern">
          <test name="family" qual="any">
              <string>Cantarell</string>
          </test>
          <edit name="family" mode="append">
              # <string>Yuji Syuku Std</string>
              <string>Noto Sans CJK JP</string>
          </edit>
      </match>
    '';

    environment.systemPackages =
      (with pkgs; [
        gnome-extension-manager
        refine
        gnome-terminal
        dynamic-wallpaper
        gapless
        endeavour
        fragments
        papers
        xmousepasteblock
        gnome-epub-thumbnailer
        libheif
        (makeDesktopItem {
          desktopName = "Caffeine-ng";
          name = "caffeine";
          noDisplay = true;
        })
      ])
      ++ (with pkgs.gnomeExtensions; [
        appindicator
        clipboard-history
        rounded-window-corners-reborn
        legacy-gtk3-theme-scheme-auto-switcher
        primary-input-on-lockscreen
        privacy-indicators-accent-color
        bluetooth-battery-meter
        better-ibus
      ])
      ++
        lib.optionals
          (
            # Can't use config.environment.systemPackages here or we get infinite recursion
            isNvidia && !lib.packageInList "yelp" config.environment.gnome.excludePackages
          )
          [
            # NOTE: This is a webkit2gtk issue
            # related https://github.com/NixOS/nixpkgs/issues/32580
            # not everything is broken so I'm just wrapping broken stuff

            # gnome-help looks to be a symlink to yelp already so I think this is fine,
            (pkgs.runCommand "gnome-help" { buildInputs = [ pkgs.makeWrapper ]; } ''
              makeWrapper ${pkgs.yelp}/bin/yelp $out/bin/gnome-help \
              --set WEBKIT_DISABLE_COMPOSITING_MODE 1
            '')
            # yelp itself can have a cleaner link because its a proper package
            (pkgs.runCommand "yelp" { buildInputs = [ pkgs.makeWrapper ]; } ''
              mkdir $out
              # Link every top-level folder from yelp to our new target
              ln -s ${pkgs.yelp}/* $out
              # Except the bin folder
              rm $out/bin
              mkdir $out/bin
              # We create the bin folder ourselves and link every binary in it
              ln -s ${pkgs.yelp}/bin/* $out/bin
              # Except the main binary
              rm $out/bin/yelp
              # Because we create this ourself, by creating a wrapper
              makeWrapper ${pkgs.yelp}/bin/yelp $out/bin/yelp \
              --set WEBKIT_DISABLE_COMPOSITING_MODE 1
            '')
          ];

    environment.gnome.excludePackages = (
      with pkgs;
      [
        gnome-tour
        gnome-connections
        gnome-console
        gnome-text-editor
        gnome-music
        epiphany # web browser
        geary # email reader
        # totem # gnome video
        gnome-maps
        gnome-characters
        gnome-shell-extensions
        gnome-calculator
        gnome-contacts
        gnome-system-monitor
      ]
    );

    programs.evince.enable = false;

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
        (autostartItem "xmousepasteblock" [ "xmousepasteblock &" ])
        (autostartItem "discord" [ "vesktop --start-minimized" ])
        (autostartItem "element" [ "element-desktop --hidden" ])
        { services.caffeine.enable = true; }
      ];
  };
}
