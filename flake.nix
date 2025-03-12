{
  description = "My flakes configuration";

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      helix,
    }@inputs:
    let
      extended-lib = nixpkgs.lib.extend (final: prev: import ./lib { lib = prev; });
    in
    {
      pkgs = import ./pkgs {
        prev = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      nixosConfigurations = {
        pancake-pc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            lib = extended-lib;
            inherit self inputs;
          };

          modules = [
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
            ./modules/spotify.nix
            ./modules/xdg.nix
            ./modules/desktops/pancake-gnome.nix
            ./modules/desktops/pancake-hyprland.nix
            ./hosts/desktop/nvidia.nix
            ./hosts/desktop/configuration.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.pancaek = import ./home/home.nix;
                extraSpecialArgs = { inherit self inputs; };
              };
            }
          ];
        };

        pancake-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit self inputs;
            lib = extended-lib;
          };

          modules = [
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
            ./modules/spotify.nix
            ./modules/xdg.nix
            ./modules/desktops/pancake-gnome.nix
            ./hosts/laptop/nvidia.nix
            ./hosts/laptop/configuration.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.pancaek = import ./home/home.nix;
                extraSpecialArgs = { inherit self inputs; };
              };
            }
          ];
        };
      };
    };
}
