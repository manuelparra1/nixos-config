{
  description = "NixOS + Home Manager for dusts";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Import your HM module from the dotfiles repo:
            # (adjust the relative path to your dotfiles)
            home-manager.users.dusts = import ../dotfiles/home/dusts.nix;

            # Make sops-nix available *inside* your HM module:
            home-manager.extraSpecialArgs = { inherit sops-nix; };
          }
        ];
      };
    };

}
