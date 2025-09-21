# home/dusts.nix (keep it minimal)
{ config, pkgs, dotfiles, ... }:
{
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
    # Use the new nerd-fonts packages
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts._0xproto
    font-awesome
  ];


  # Dotfile Settings
  # ================
  # ZSH
  # ADD THIS CORRECT BLOCK
  programs.zsh = {
    enable = true;
    # This tells Home Manager's zsh module to add the following
    # text to the top of the .zshrc it generates.
    initExtra = ''
      # Source the .zshrc from your dotfiles repository
      if [[ -f "${dotfiles}/.zshrc" ]]; then
        source "${dotfiles}/.zshrc"
      fi
    '';
  };
  programs.starship.enable = true;

  # your normal HM config ...
  # example: put wallpapers/fonts you keep in dotfiles
  home.file."Pictures/Wallpapers".source = "${dotfiles}/Pictures/Wallpapers";

  # Pull your actual configs from the repo (no escaping headaches)
  xdg.configFile."zsh".source         = "${dotfiles}/.config/zsh";     # plugins etc.
  xdg.configFile."nvim".source        = "${dotfiles}/.config/nvim";
  xdg.configFile."hypr".source        = "${dotfiles}/.config/hypr";
  xdg.configFile."eww".source         = "${dotfiles}/.config/eww";
  xdg.configFile."kitty".source       = "${dotfiles}/.config/kitty";

  # Scripts + PATH (if you keep scripts)
  home.file.".bin".source = "${dotfiles}/.bin";
  home.file.".bin".recursive = true;
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.bin" "/mnt/c/bin" ];

  # Serets Management
  # =================
  # sops: point to your encrypted file inside dotfiles
  sops.defaultSopsFile = "${dotfiles}/secrets.yaml";
  # if your Age key is in the default path you can omit the next line
  sops.age.keyFile = "/home/dusts/.config/sops/age/keys.txt";

  # map individual keys
  sops.secrets.openai_api_key = { key = "OPENAI_API_KEY"; };
  sops.secrets.github_token   = { key = "GITHUB_TOKEN"; };
}
