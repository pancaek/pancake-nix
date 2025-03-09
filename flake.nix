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
      packages-dir = (final: prev: import ./pkgs { inherit prev; });
      extended-lib = nixpkgs.lib.extend (final: prev: import ./lib { lib = prev; });

    in
    {
      nixosConfigurations = {
        pancake-pc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            lib = extended-lib;
          };

          modules = [
            {
              nixpkgs.overlays = [
                packages-dir
              ];
            }
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
            ./modules/spotify.nix
            ./modules/xdg.nix
            ./modules/desktops/pancake-gnome.nix
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
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };

        pancake-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            lib = extended-lib;
          };

          modules = [
            {
              nixpkgs.overlays = [
                packages-dir
              ];
            }
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
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };
      };
    };
}
