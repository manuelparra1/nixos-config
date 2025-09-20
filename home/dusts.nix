# home/dusts.nix (keep it minimal)
{ pkgs, dotfiles, ... }:
{
  home.username = "dusts";
  home.homeDirectory = "/home/dusts";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    hyprland eza fd ripgrep bat fzf zoxide coreutils moreutils
    # tools your aliases/functions call
    neovim git jq wl-clipboard unzip
    # autostarted helpers:
    networkmanagerapplet    # nm-applet
    swaynotificationcenter  # swaync
    hypridle hyprpaper hyprlock hyprshot
    brightnessctl playerctl
    glib                   # for 'gsettings' binary
    xorg.xrandr            # for your force-detect bind
    wofi                   
    xfce4-power-manager
  ];

  programs.zsh.enable = true;
  programs.starship.enable = true;

  # Pull your actual configs from the repo (no escaping headaches)
  home.file.".zshrc".source           = "${dotfiles}/.zshrc";
  xdg.configFile."zsh".source         = "${dotfiles}/.config/zsh";     # plugins etc.
  xdg.configFile."nvim".source        = "${dotfiles}/.config/nvim";
  xdg.configFile."hypr".source        = "${dotfiles}/.config/hypr";
  xdg.configFile."eww".source         = "${dotfiles}/.config/eww";
  xdg.configFile."kitty".source       = "${dotfiles}/.config/kitty";

  # Scripts + PATH (if you keep scripts)
  home.file.".bin".source = "${dotfiles}/.bin";
  home.file.".bin".recursive = true;
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.bin" "/mnt/c/bin" ];
}
