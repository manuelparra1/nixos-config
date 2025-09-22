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
      # Export each API key by reading the sops-managed files at shell runtime.
      for k in OPENAI_API_KEY OPENROUTER_API_KEY CEREBRAS_API_KEY GROK_API_KEY GROQ_API_KEY MISTRAL_API_KEY CODESTRAL_API_KEY DEEPSEEK_API_KEY; do
        f="${config.sops.secrets[$k].path}"
        if [[ -f "$f" ]]; then
          # Shell-safe read (no trailing newline)
          export "$k"="$(<"$f")"
        fi
      done

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

  # 1. Define each secret you want to extract from the YAML file.
  #    The name of the secret here must match the key in secrets.yaml.
  sops.secrets = {
    OPENAI_API_KEY    = {};
    OPENROUTER_API_KEY= {};
    CEREBRAS_API_KEY  = {};
    GROK_API_KEY      = {};
    GROQ_API_KEY      = {};
    MISTRAL_API_KEY   = {};
    CODESTRAL_API_KEY = {};
    DEEPSEEK_API_KEY  = {};
  };
}
