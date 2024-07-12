{
  description = "My flakes configuration";

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-24.05";
    # nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    {
      self,
      nixpkgs,
      # nixpkgs-unstable,
      home-manager,
      nur,
    }:
    let
      system = "x86_64-linux";

      piper_overlay = (
        self: super: {
          piper = super.piper.overrideAttrs (prev: {
            version = "git";
            src = super.fetchFromGitHub {
              owner = "libratbag";
              repo = "piper";
              rev = "efa2712fcbc4ac1e9e9d1a7a85334c2a5dc9bab4";
              sha256 = "uC7BEKVPQz42rdutX4ft3W1MoUVlkFHq2RgQGKVhV2o=";
            };
            # Remove "-Dtests=false" flag that doesn't exist in the new version
            # https://github.com/libratbag/piper/commit/a8ba2124318cc12477ffee932c7ae9c3614926c2
            mesonFlags = nixpkgs.lib.lists.remove "-Dtests=false" prev.mesonFlags;
          });
          libratbag = super.libratbag.overrideAttrs (prev: {
            version = "git";
            src = super.fetchFromGitHub {
              owner = "libratbag";
              repo = "libratbag";
              rev = "1c9662043f4a11af26537e394bbd90e38994066a";
              sha256 = "IpN97PPn9p1y+cAh9qJAi5f4zzOlm6bjCxRrUTSXNqM=";
            };
          });
        }
      );
    in
    # overlay-unstable = final: prev: {
    #   # use this variant if unfree packages are needed:
    #   unstable = import nixpkgs-unstable {
    #     inherit system;
    #     config.allowUnfree = true;
    #   };
    # };
    {
      nixosConfigurations = {
        pancake-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # (
            #   { config, pkgs, ... }:
            #   {
            #     nixpkgs.overlays = [ overlay-unstable ];
            #   }
            # )
            nur.nixosModules.nur
            ./hosts/laptop/configuration.nix
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/wayland.nix
            ./modules/hardware/laptop.nix
            # ./modules/xdg-compliance.nix # TODO another day
            ./modules/desktops/pancake-gnome.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.pancaek = import ./home/home.nix;
              };

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            }
          ];
        };

        pancake-pc = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # (
            #   { config, pkgs, ... }:
            #   {
            #     nixpkgs.overlays = [ overlay-unstable ];
            #   }
            # )
            { nixpkgs.overlays = [ piper_overlay ]; }
            nur.nixosModules.nur
            ./hosts/desktop/configuration.nix
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/wayland.nix
            ./modules/hardware/desktop.nix
            # ./modules/xdg-compliance.nix # TODO another day
            ./modules/desktops/pancake-gnome.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.pancaek = import ./home/home.nix;
              };

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            }
          ];
        };
      };
    };
}
