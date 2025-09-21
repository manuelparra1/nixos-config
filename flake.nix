{
  description = "NixOS + Home Manager for dusts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # keep your personal dotfiles repo (no flake)
    dotfiles = {
      url = "github:manuelparra1/dotfiles";
      flake = false;
    };

    # add sops-nix
    sops-nix.url = "github:Mic92/sops-nix";

    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, dotfiles, sops-nix, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/nixos.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;

          # Make HM use the unstable package set:
          home-manager.nixpkgs = {
            pkgs = pkgsUnstable;
          }

          home-manager.extraSpecialArgs = {
            inherit pkgsUnstable dotfiles;
            sopsNix = sops-nix;
          };

          home-manager.users.dusts = import ./home/dusts.nix;
        }
      ];
    };
  };
}
