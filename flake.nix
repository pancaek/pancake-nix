{
  description = "My flakes configuration";

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

      nltch-overlay = final: prev: {
        nltch = import nltch {
          # we need to explicitly pass pkgs since the repo is weird with flakes
          inherit (prev) pkgs;
        };
      };
      packages-dir = (
        final: prev:
        (nixpkgs.lib.packagesFromDirectoryRecursive {
          directory = ./pkgs/by-name;
          inherit (prev.pkgs) callPackage;
        })
        // import pkgs/all-packages.nix { inherit (prev) pkgs; }
      );
      extended-lib = nixpkgs.lib.extend (final: prev: import ./lib { lib = prev; });

      _2411-fixes = final: prev: {
        # There's a strange interaction between adw-gtk3 and praat 6.4.22
        praat = prev.praat.overrideAttrs (old: {
          version = "6.4.14";

          src = prev.pkgs.fetchFromGitHub {
            owner = "praat";
            repo = "praat";
            rev = "v${final.praat.version}";
            hash = "sha256-AY/OSoCWlWSjtLcve16nL72HidPlJqJgAOvUubMqvj0=";
          };
        });

        # While we wait for https://github.com/NixOS/nixpkgs/pull/358236 to backport
        gnome-extension-manager = (
          prev.gnome-extension-manager.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              (prev.pkgs.fetchpatch {
                url = "https://github.com/mjakeman/extension-manager/commit/91d1c42a30e12131dc3c5afd8a709e7db2a95b70.patch";
                hash = "sha256-NtsJeqclUx4L3wbyQ46ZCoo4IKSu4/HoT/FD20xriZ4=";
              })
            ];
          })
        );
      };
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
                nltch-overlay
                packages-dir
                _2411-fixes
              ];
            }
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
            ./modules/spotify.nix
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
                nltch-overlay
                packages-dir
                _2411-fixes
              ];
            }
            ./modules/quiet-boot.nix
            ./modules/audio.nix
            ./modules/printing.nix
            ./modules/ibus.nix
            ./modules/firefox.nix
            ./modules/spotify.nix
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
