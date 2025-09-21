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
        {
          # Keep system (24.05) separate from HM pkgs
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
        
          # 1) Provide args (pkgs from unstable + extras) to ALL HM modules safely
          home-manager.sharedModules = [
            {
              _module.args = {
                pkgs          = pkgsUnstable;  # ← HM's `pkgs` will be nixpkgs-unstable
                pkgsUnstable  = pkgsUnstable;  # pass separately if you use it by name
                dotfiles      = dotfiles;
                sopsNix       = sops-nix;      # rename is fine; no hyphen in identifiers here
              };
            }
          ];
        
          # 2) Import your user’s HM config (no more _module.args here)
          home-manager.users.dusts = import ./home/dusts.nix;
        }
      ];
    };
  };
}
