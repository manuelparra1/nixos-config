{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Unfree Packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Themes
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Boot loader (EFI typical)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # File System
  boot.supportedFilesystems = [ "exfat" ];

  users.users.dusts = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "bluetooth" ];
    shell = pkgs.zsh;
  };

  # SSH
  services.openssh.enable = true;
  programs.zsh.enable = true;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Wayland desktop
  programs.hyprland.enable = true;

  # Common services you use
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.flatpak.enable = true;

  # Mason Neovim Fix
  programs.nix-ld.enable = true;

  # Optional but helpful: add common libs Mason binaries expect.
  # (You can start without this; add libs only if a tool still fails.)
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    libgcc
  ];

  # Time
  time.timeZone = "America/Chicago";

  # PipeWire (recommended on NixOS)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # XDG portals (Flatpak & Wayland file pickers)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Fonts (example)
  fonts.packages = with pkgs; [ noto-fonts noto-fonts-emoji ];

  # Some X bits are handy even on Wayland
  services.xserver.enable = true;
}

