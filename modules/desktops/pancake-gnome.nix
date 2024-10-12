{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.modules.pancake-gnome;
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports = [
    ../kvantum.nix
    ../piper.nix
    ../polkit-auth.nix
  ];

  options.modules.pancake-gnome = {
    enable = lib.mkEnableOption "My personal gnome defaults, very opinionated, proceed with caution";
  };

  config = lib.mkIf cfg.enable {

    services.xserver = {
      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
      desktopManager.gnome.enable = true;
      excludePackages = (with pkgs; [ xterm ]);
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

    environment.systemPackages =
      (with pkgs; [
        gnome-extension-manager
        gnome.gnome-tweaks
        gnome.gnome-terminal
        dynamic-wallpaper
        g4music
        endeavour
        mpv
        gradience
        xmousepasteblock

        gnome-epub-thumbnailer

        (runCommand "caffeine" { } ''
          shopt -s extglob
          mkdir -p $out

          # Copy share/ separately so I can exclude the icon
          cp -r ${caffeine-ng}/!(share) $out
          mkdir -p $out/share
          cp -r ${caffeine-ng}/share/!(applications) $out/share
        '')
      ])
      ++ (with pkgs.gnomeExtensions; [
        appindicator
        ddterm
        # rounded-corners # TODO: somethings up with this one, watch git
        clipboard-history
        user-themes
        legacy-gtk3-theme-scheme-auto-switcher
        custom-accent-colors
        primary-input-on-lockscreen
        # hassleless-overview-search # TODO: Version bump
        sleep-through-notifications

        # NOTE: V-shell for some reason doesn't load properly system-wide
        # I just installed manually for now
        # vertical-workspaces
      ])
      ++
        lib.optionals
          (
            # Can't use config.environment.systemPackages here or we get infinite recursion
            lib.elem "nvidia" config.services.xserver.videoDrivers
            && !lib.packageInList "yelp" config.environment.gnome.excludePackages
          )
          [
            # NOTE: This is a webkit2gtk issue
            # related https://github.com/NixOS/nixpkgs/issues/32580
            # not everything is broken so I'm just wrapping broken stuff

            # gnome-help looks to be a symlink to yelp already so I think this is fine,
            (pkgs.runCommand "gnome-help" { buildInputs = [ pkgs.makeWrapper ]; } ''
              makeWrapper ${pkgs.gnome.yelp}/bin/yelp $out/bin/gnome-help \
              --set WEBKIT_DISABLE_COMPOSITING_MODE 1
            '')
            # yelp itself can have a cleaner link because its a proper package
            (pkgs.runCommand "yelp" { buildInputs = [ pkgs.makeWrapper ]; } ''
              mkdir $out
              # Link every top-level folder from yelp to our new target
              ln -s ${pkgs.gnome.yelp}/* $out
              # Except the bin folder
              rm $out/bin
              mkdir $out/bin
              # We create the bin folder ourselves and link every binary in it
              ln -s ${pkgs.gnome.yelp}/bin/* $out/bin
              # Except the main binary
              rm $out/bin/yelp
              # Because we create this ourself, by creating a wrapper
              makeWrapper ${pkgs.gnome.yelp}/bin/yelp $out/bin/yelp \
              --set WEBKIT_DISABLE_COMPOSITING_MODE 1
            '')
          ];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
        gnome-connections
        gnome-console
        gnome-text-editor
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        epiphany # web browser
        geary # email reader
        totem # gnome video
        gnome-maps
        gnome-characters
        gnome-shell-extensions
        gnome-calculator
        gnome-contacts
        gnome-system-monitor
      ]);

    programs.kvantum.enable = true;

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
      ];

    systemd.services.gdm-monitors = {
      description = "Copy monitors.xml to GDM config at boot";

      # Run after fs is ready
      after = [ "local-fs.target" ];

      # Run at boot
      wantedBy = [ "multi-user.target" ];

      # Service configuration
      serviceConfig =
        let
          sourcePath = "/home/pancaek/.config/monitors.xml";
          destPath = "/run/gdm/.config/monitors.xml";
        in
        {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/install -o gdm -g gdm \"${sourcePath}\" \"${destPath}\""; # Do the thing
        };
    };
  };
}
