{
  description = "My flakes configuration";

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-24.05";
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
      home-manager,
      nur,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        pancake-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nur.nixosModules.nur
            ./configuration.nix
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
      };
    };
}
