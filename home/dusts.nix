# home/dusts.nix (keep it minimal)
{ pkgs, pkgsUnstable, dotfiles, ... }:
{
  home.username = "dusts";
  home.homeDirectory = "/home/dusts";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # Hyprland environment
    hyprland
    eww
    waybar
    wofi
    kitty
    (pkgsUnstable.ghostty)
  
    # XFCE utilities (no full XFCE session)
    xfce.thunar
    xfce.xfce4-settings
    xfce.xfce4-power-manager
  
    # Other helpers
    pavucontrol
    blueman
    wl-clipboard
  
    # CLI/dev tools
    neovim git ripgrep fd starship zsh fzf zoxide bat jq unzip
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
