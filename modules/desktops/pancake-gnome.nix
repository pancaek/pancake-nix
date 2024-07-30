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
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = (with pkgs; [ xterm ]);
    };

    environment.systemPackages =
      (with pkgs; [
        gnome-extension-manager
        gnome.gnome-tweaks
        gnome.gnome-terminal
        g4music
        endeavour
        mpv
        gradience
        xmousepasteblock
      ])
      ++ (with pkgs.gnomeExtensions; [
        appindicator
        ddterm
        # rounded-corners # TODO: somethings up with this one, watch git
        vertical-workspaces
        caffeine
        clipboard-history
        user-themes
        legacy-gtk3-theme-scheme-auto-switcher # NOTE: Makes themes fully consistent
        custom-accent-colors
        # alphabetical-app-grid
        # hassleless-overview-search # TODO: Version bump
      ])
      ++ lib.optionals isNvidia [
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
          # Link every top-level folder from pkgs.hello to our new target
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
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        epiphany # web browser
        geary # email reader
        totem # gnome video
        gnome-maps
        gnome-characters
        gnome-shell-extensions
      ]);

    programs.kvantum.enable = true;
    # modules.polkit-auth = {
    #   enable = true;
    #   agent = "gnome";
    # };

    home-manager.sharedModules =
      let
        autostartItem = title: commandList: {
          home.file.".config/autostart/${title}.desktop".text =
            (pkgs.makeDesktopItem {
              desktopName = title;
              name = title;
              exec =
                if builtins.length commandList == 1 then
                  builtins.elemAt commandList 0
                else
                  "sh -c '${lib.concatStringsSep " ; " commandList}'";
            }).text;
        };
      in
      [
        (autostartItem "v-shell-fix" [
          "sleep 2"
          "gnome-extensions disable vertical-workspaces@G-dH.github.com"
          "gnome-extensions enable vertical-workspaces@G-dH.github.com"
        ])
        (autostartItem "xmousepasteblock" [ "xmousepasteblock &" ])
      ];
  };
}
