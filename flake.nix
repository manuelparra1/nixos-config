{
  description = "NixOS + Home Manager for dusts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # personal dotfiles repo (no flake)
    dotfiles = {
      url = "github:manuelparra1/dotfiles";
      flake = false;
    };

    # sops-nix; make it follow unstable nixpkgs (needs buildGo124Module)
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
        # your host module
        ./hosts/nixos.nix

        # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager

        # HM configuration block
        {
          # Use a separate (unstable) package set for HM to satisfy sops-nix & newer Neovim
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;

          # Configure the HM user
          home-manager.users.dusts = {
            # Make HM itself use nixpkgs-unstable as pkgs
            _module.args = {
              pkgs = pkgsUnstable;
              pkgsUnstable = pkgsUnstable;
              dotfiles = dotfiles;
              sopsNix = sops-nix;  # pass sops-nix to your HM module as 'sopsNix'
            };

            # Import your HM config file
            imports = [ ./home/dusts.nix ];
          };
        }
      ];
    };
  };
}
