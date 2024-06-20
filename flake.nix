{
  description = "My flakes configuration";

  inputs = {

    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        pancake-laptop = nixpkgs.lib.nixosSystem
          {
            inherit system;
            modules = [
              ./configuration.nix
              ./modules/quiet-boot.nix
              ./modules/wayland.nix
              ./modules/nvidia/laptop.nix
              # ./modules/xdg-compliance.nix # TODO another day
              ./modules/desktops/pancake-gnome.nix

              # make home-manager as a module of nixos
              # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.pancaek = import ./home/home.nix;

                # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              }
            ];
          };
      };
    };
}

