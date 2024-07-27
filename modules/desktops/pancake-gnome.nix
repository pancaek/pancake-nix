{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.modules.pancake-gnome;
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
        celluloid
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
        custom-accent-colors
        # alphabetical-app-grid
        # hassleless-overview-search # TODO: Version bump
      ]);

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
