# flake.nix

{
  description = "NixOS + Home Manager for dusts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    dotfiles = {
      url = "github:manuelparra1/dotfiles";
      flake = false;
    };

    # Pin sops-nix to the branch compatible with nixos-24.05
    sops-nix.url = "github:Mic92/sops-nix/release-24.05";
    # Make it follow your stable nixpkgs, not unstable
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";


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
          # HM should NOT reuse the system pkgs (we want unstable for HM)
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;

          # Give HM its own user configuration
          home-manager.users.dusts = {
            imports = [ ./home/dusts.nix ];
          };

          # Pass extra args your HM config expects
          home-manager.extraSpecialArgs = {
            pkgsUnstable = pkgsUnstable;
            dotfiles     = dotfiles;
            sopsNix      = sops-nix;
          };
        }
      ];
    };
  };
}
