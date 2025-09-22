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

  # Enable the OpenSSH server
  services.openssh.enable = true;
 
  # This is the sops config from the previous step
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Dotfile Settings
  # ================
  # ZSH
  # ADD THIS CORRECT BLOCK
  programs.zsh = {
    enable = true;
    # This tells Home Manager's zsh module to add the following
    # text to the top of the .zshrc it generates.
    initContent = ''
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

  # ADD these blocks to home/dusts.nix
  
  # 1. Tell sops-nix to create a single file in ".env" format
  #    from your secrets.yaml. It will contain all the keys.
  sops.secrets."api-keys" = {
    format = "dotenv";
    sopsFile = "${dotfiles}/secrets.yaml";
  };
  
  # 2. Tell Home Manager to source that file to create session variables.
  home.sessionVariablesFrom = [
    config.sops.secrets."api-keys".path
  ];
}
