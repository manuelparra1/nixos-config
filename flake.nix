{
  description = "NixOS + Home Manager for dusts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Your dotfiles (pinned via flake.lock)
    dotfiles.url = "github:manuelparra1/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/nixos.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.dusts = import ./home/dusts.nix {
            inherit pkgs dotfiles;
          };
        }
      ];
    };
  };
}

