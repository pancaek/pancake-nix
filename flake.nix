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
      cameractrls_backport = (
        final: prev: {
          cameractrls = prev.callPackage ./pkgs/cameractrls.nix { };
          cameractrls-gtk3 = final.cameractrls.override { withGtk = 3; };
          cameractrls-gtk4 = final.cameractrls.override { withGtk = 4; };
        }
      );
      komika-fonts_overlay = (
        final: prev: { komika-fonts = prev.callPackage ./pkgs/komika-fonts.nix { }; }
      );
    in
    {
      nixosConfigurations = {
        pancake-pc = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [
                cameractrls_backport
                komika-fonts_overlay
              ];
            }
            nur.nixosModules.nur
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
            # (
            #   { config, pkgs, ... }:
            #   {
            #     nixpkgs.overlays = [ overlay-unstable ];
            #   }
            # )
            nur.nixosModules.nur
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
