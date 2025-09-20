{ pkgs, dotfiles, ... }:
{
  # Packages your zshrc references
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
  # Non-secret env vars (safe to declare)
  home.sessionVariables = {
    BAT_THEME = "Catppuccin Mocha";
    HYPRSHOT_DIR = "$HOME/Pictures/Screenshots/";
    CLICOLOR = "true";
  };

  # PATH additions
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Your aliases -> declare as shellAliases
    shellAliases = {
      ls = "eza -1rs oldest";
      ll = "eza -lhs newest";
      dictionary = "~/Scripts/dictionary.py";  # if that script exists
      chatgpt4o-mini = ''chatgpt.sh -i "respond in a simple and concise manner" --model gpt-4o-mini --max-tokens 500'';
      chatgpt4o = ''chatgpt.sh -i "respond in a simple and concise manner" --model chatgpt-4o-latest --max-tokens 250'';
      groq = "python ~/.bin/groq/scripts/run_groq.py short";
    };

    # Extra init: dircolors, plugins you source, keybinds, functions, conda widget
    initExtra = ''
      # dircolors
      if [ -f ~/.bliss_dircolors ]; then eval "$(dircolors ~/.bliss_dircolors)"; fi

      # fzf-tab needs compinit before sourcing plugins
      autoload -Uz compinit && compinit

      # Plugins from your dotfiles tree (symlinked via xdg.configFile)
      source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
      source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
      source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
      source ~/.config/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh
      source ~/.config/zsh/plugins/zsh-groq-llm/zsh-llm-suggestions.zsh
      fpath=(~/.config/zsh/plugins/zsh-completions/src $fpath)

      # Keybindings
      bindkey -e
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey '^[w' kill-region
      bindkey '^o' zsh_llm_suggestions_groq

      # History
      HISTSIZE=5000
      HISTFILE=~/.zsh_history
      SAVEHIST=$HISTSIZE
      setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups \
             hist_save_no_dups hist_ignore_dups hist_find_no_dups

      # Completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      # zoxide, starship
      eval "$(zoxide init --cmd cd zsh)"
      eval "$(starship init zsh)"

      # fzfvim function
fzfvim() {
        local query="\${1:-}"
        FZF_DEFAULT_COMMAND="fd -H --type f -e md -e lua -e txt -e sh -e py -e cpp -e json -e conf -e zshrc" \
        FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always {}' --bind 'change:reload:fd -H --type f -e md -e lua -e txt -e sh -e py -e cpp -e json -e conf -e zshrc {q} || true'" \
        fzf --ansi --phony --query="$query" --exit-0 | while IFS= read -r file; do
          nvim "$file"
        done
      }

      # livegrep function (your version with smarter preview/jump)
      livegrep() {
        local search_dir="\${1:-.}"
        FZF_DEFAULT_COMMAND="fd -H --type f -e md -e lua -e txt -e sh -e py -e cpp -e json -e conf -e zshrc -e js -e ts -e html -e css -e yml -e yaml -e xml -e toml -e ini -e cfg -e log -e sql -e rs -e go -e java -e c -e h -e rb -e php -e pl -e vim -e rc" \
        fzf --phony --query '' \
          --bind "change:reload:sh -c '
            query=\"\$1\"
            if [ -z \"\$query\" ]; then
              fd -H --type f -e md -e lua -e txt -e sh -e py -e cpp -e json -e conf -e zshrc -e js -e ts -e html -e css -e yml -e yaml -e xml -e toml -e ini -e cfg -e log -e sql -e rs -e go -e java -e c -e h -e rb -e php -e pl -e vim -e rc
            else
              fd -H --type f -e md -e lua -e txt -e sh -e py -e cpp -e json -e conf -e zshrc -e js -e ts -e html -e css -e yml -e yaml -e xml -e toml -e ini -e cfg -e log -e sql -e rs -e go -e java -e c -e h -e rb -e php -e pl -e vim -e rc -0 | xargs -0 rg -l \"\$query\" 2>/dev/null || true
            fi
          ' _ {q} || true" \
          --delimiter ':' \
          --preview 'file={1}; last_word=$(echo {q} | awk "{print \$NF}"); if [ -n "$last_word" ]; then line=$(rg --line-number --no-heading --smart-case "$last_word" "$file" 2>/dev/null | head -n1 | cut -d: -f1); if [ -n "$line" ]; then start_line=$((line - 5)); if [ $start_line -lt 1 ]; then start_line=1; fi; end_line=$((line + 45)); bat --style=numbers --color=always --highlight-line "$line" --line-range "$start_line:$end_line" "$file" 2>/dev/null; else bat --style=numbers --color=always "$file" 2>/dev/null; fi; else bat --style=numbers --color=always "$file" 2>/dev/null; fi' \
          --preview-window 'right:50%:wrap' \
          --bind 'enter:execute:last_word=$(echo {q} | awk "{print \$NF}"); if [ -n "$last_word" ]; then line=$(rg --line-number --no-heading --smart-case "$last_word" {1} 2>/dev/null | head -n1 | cut -d: -f1); nvim "+\${line:-1}" {1}; else nvim {1}; fi'
      }

      # Conda on-demand (unchanged)
      conda_on_demand_function() {
        echo "Activated default Anaconda environment"
        eval "$(/home/dusts/.miniconda3/bin/conda shell.zsh hook 2>/dev/null)"
      }
      conda_on_demand_widget() { conda_on_demand_function; zle reset-prompt; }
      zle -N conda_on_demand_widget
      bindkey '^[c' conda_on_demand_widget
    '';
  };

  # Zoxide/FZF helpers
  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  # Plugins & files are symlinked from your dotfiles repo (as you already set up)
  xdg.configFile."zsh/plugins".source = "${dotfiles}/.config/zsh/plugins";
  home.file.".bliss_dircolors".source = "${dotfiles}/.bliss_dircolors";

  # If you still want to keep a .zshrc in your repo, you can — but avoid duplicating logic with initExtra.
  # home.file.".zshrc".source = "${dotfiles}/.zshrc";
}
