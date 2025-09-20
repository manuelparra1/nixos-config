{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.dusts = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "bluetooth" ];
    shell = pkgs.zsh;
  };

  # Wayland desktop
  programs.hyprland.enable = true;

  # Common services you use
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.flatpak.enable = true;

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

