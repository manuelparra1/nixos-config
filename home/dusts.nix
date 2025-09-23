# home/dusts.nix (keep it minimal)
{ config, pkgs, dotfiles, ... }:
{
  home.username = "dusts";
  home.homeDirectory = "/home/dusts";
  home.stateVersion = "25.05";

  # SOPS Key Location
  sops.age.keyFile = "/home/dusts/.config/sops/age/keys.txt";

  home.packages = with pkgs; [
    # Hyprland environment
    hyprland
    eww
    waybar
    wofi
    kitty
    ghostty
    typora
  
    # Gnome Utilities
    papers
    loupe

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

    # CLI Tools
    neovim eza ripgrep fd starship zsh fzf zoxide bat jq unzip tree

    # DEV Tools
    gnupg git coreutils gcc gnumake binutils pkg-config nodejs yarn 

    # languages
    python3

    # ADD YOUR FONTS FROM NIXPKGS HERE
    # Use the new nerd-fonts packages
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts._0xproto
    font-awesome
  ];

  # Make sure the SyncThing share exists
  home.file."aston/.keep".text = "";

  services.syncthing = {
    enable = true;
    tray.enable = false;
  };

  # Dotfile Settings
  # ================

  # ZSH
  programs.zsh = {
    enable = true;
    initContent = let
      # First, we define a list of all your secret names in Nix
      secretNames = [
        "OPENAI_API_KEY" "OPENROUTER_API_KEY" "CEREBRAS_API_KEY" "GROK_API_KEY"
        "GROQ_API_KEY" "MISTRAL_API_KEY" "CODESTRAL_API_KEY" "DEEPSEEK_API_KEY"
      ];
  
      # Then, we use Nix to loop over this list and generate an 'export' command for each secret
      exportCommands = pkgs.lib.concatStringsSep "\n" (
        map (name: ''
          f="${config.sops.secrets."${name}".path}"
          if [[ -f "$f" ]]; then
            export "${name}"="$(<"$f")"
          fi
        '') secretNames
      );
    in
    ''
      # This injects the block of commands we just generated
      ${exportCommands}
      
      # Source your custom .zshrc from your dotfiles repository
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


  # Load Home Dir Files
  home.file.".dir_colors".source = "${dotfiles}/.dir_colors";

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
