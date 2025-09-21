# home/dusts.nix (keep it minimal)
{ config, pkgs, inputs, ... }:
{

  # SOPS Secret Management
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.username = "dusts";
  home.homeDirectory = "/home/dusts";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Hyprland environment
    hyprland
    eww
    waybar
    wofi
    kitty
    ghostty
  
    # XFCE utilities (no full XFCE session)
    xfce.thunar
    xfce.xfce4-settings
    xfce.xfce4-power-manager

    # Browser
    firefox
  
    # Other helpers
    pavucontrol
    blueman
    wl-clipboard

    # Keys
    sops
    age

    # optional helpers
    gnupg coreutils 

    # CLI/dev tools
    neovim git ripgrep fd starship zsh fzf zoxide bat jq unzip tree

    # ADD YOUR FONTS FROM NIXPKGS HERE
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "0xProto" ]; })
    font-awesome
  ];


  # Dotfile Settings
  # ================
  # ZSH
  programs.zsh.enable = true;
  programs.starship.enable = true;

  # your normal HM config ...
  # example: put wallpapers/fonts you keep in dotfiles
  home.file."Pictures/Wallpapers".source = "${inputs.dotfiles}/Pictures/Wallpapers";

  # Pull your actual configs from the repo (no escaping headaches)
  home.file.".zshrc".source           = "${inputs.dotfiles}/.zshrc";
  xdg.configFile."zsh".source         = "${inputs.dotfiles}/.config/zsh";     # plugins etc.
  xdg.configFile."nvim".source        = "${inputs.dotfiles}/.config/nvim";
  xdg.configFile."hypr".source        = "${inputs.dotfiles}/.config/hypr";
  xdg.configFile."eww".source         = "${inputs.dotfiles}/.config/eww";
  xdg.configFile."kitty".source       = "${inputs.dotfiles}/.config/kitty";

  # Scripts + PATH (if you keep scripts)
  home.file.".bin".source = "${inputs.dotfiles}/.bin";
  home.file.".bin".recursive = true;
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.bin" "/mnt/c/bin" ];

  # Serets Management
  # =================
  # sops: point to your encrypted file inside dotfiles
  sops.defaultSopsFile = "${inputs.dotfiles}/secrets.yaml";
  # if your Age key is in the default path you can omit the next line
  sops.age.keyFile = "/home/dusts/.config/sops/age/keys.txt";

  # map individual keys
  sops.secrets.openai_api_key = { key = "OPENAI_API_KEY"; };
  sops.secrets.github_token   = { key = "GITHUB_TOKEN"; };
}
