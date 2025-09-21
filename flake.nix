{
  description = "NixOS + Home Manager (Rolling Release) for dusts";

  inputs = {
    # 1. The Foundation: NixOS Unstable (your rolling release)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 2. Home Manager, using the main branch for compatibility
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # <-- Makes HM use nixos-unstable

    # 3. Sops-nix, using the main branch for compatibility
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs"; # <-- Makes sops-nix use nixos-unstable

    # 4. Your dotfiles, unchanged
    dotfiles = {
      url = "github:manuelparra1/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, dotfiles, ... }@inputs:
  let
    system = "x86_64-linux";
    # Only one pkgs is needed now, and it's from nixos-unstable
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs; };

      modules = [
        # Your host configuration
        ./hosts/nixos.nix

        # Import sops-nix for system-wide secrets
        sops-nix.nixosModules.sops

        # Home Manager module
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            # This is the key: HM uses the system's pkgs (which is now unstable)
            useGlobalPkgs = true;
            useUserPackages = true;

            # Your user configuration
            users.dusts = {
              imports = [ ./home/dusts.nix ];
            };

            # Pass dotfiles to your Home Manager config
            extraSpecialArgs = {
              inherit dotfiles;
            };
          };
        }
      ];
    };
  };
}
