{
  description = "My flakes configuration";

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nltch = {
      url = "github:NL-TCH/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      # nixpkgs-unstable,
      home-manager,
      nltch,
    }:
    let
      system = "x86_64-linux";

      nltch_overlay = final: prev: {
        nltch = import nltch {
          # we need to explicitly pass pkgs since the repo is weird with flakes
          pkgs = prev.pkgs;
        };
      };
      packages-dir = (
        final: prev:
        (nixpkgs.lib.packagesFromDirectoryRecursive {
          directory = ./pkgs;
          inherit (prev.pkgs) callPackage;
        })
        // import pkgs/all-packages.nix_ { inherit (prev) pkgs; }
        # XXX: This .nix_ extension is needed to get around the file extension check
        # which would otherwise cause a `callPackage all-packages.nix`
      );
      extended-lib = nixpkgs.lib.extend (final: prev: import ./lib { lib = prev; });

    in
    {
      nixosConfigurations = {
        pancake-pc = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            lib = extended-lib;
          };

          modules = [
            {
              nixpkgs.overlays = [
                nltch_overlay
                packages-dir
              ];
            }
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
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
              };

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            }
          ];
        };

        pancake-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [
                nltch_overlay
                packages-dir
              ];
            }
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
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
              };

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            }
          ];
        };
      };
    };
}
