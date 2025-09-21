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

  # Serets Management
  # =================
  # make sops-nix available at HM level
  imports = [ sops-nix.homeManagerModules.sops ];

  # your normal HM config ...
  # example: put wallpapers/fonts you keep in dotfiles
  home.file."Pictures/Wallpapers".source = "${dotfiles}/Pictures/Wallpapers";

  # sops: point to your encrypted file inside dotfiles
  sops.defaultSopsFile = "${dotfiles}/secrets.yaml";
  # if your Age key is in the default path you can omit the next line
  sops.age.keyFile = "/home/dusts/.config/sops/age/keys.txt";

  # map individual keys
  sops.secrets.openai_api_key = { key = "OPENAI_API_KEY"; };
  sops.secrets.github_token   = { key = "GITHUB_TOKEN"; };

  # ZSH
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
