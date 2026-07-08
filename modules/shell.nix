{ config, pkgs, ... }:
{
  ##################################################################################################################
  #
  # Shell Configuration - Modern CLI Experience
  #
  ##################################################################################################################

  home.packages = with pkgs; [
    # Core search and navigation
    fzf           # Fuzzy finder
    ripgrep       # Fast grep alternative (rg)

    # Modern CLI replacements
    bat           # Better cat with syntax highlighting
    eza           # Better ls with colors and git integration
    fd            # Better find
    zoxide        # Smarter cd that learns your habits
    dust          # Better du (disk usage)
    duf           # Better df (disk free)

    # Git enhancements
    delta         # Beautiful diff viewer
    lazygit       # Terminal UI for git
    gh            # GitHub CLI

    # Additional useful tools
    jq            # JSON processor
    yq            # YAML processor
    htop          # Process viewer
    tree          # Directory tree viewer
  ];

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History configuration
    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    # Shell aliases
    shellAliases = {
      # NixOS rebuild aliases
      nos = "sudo nixos-rebuild switch --flake /home/matty/dev/nixos-config#$(hostname)";
      nrs = "sudo nixos-rebuild switch --flake /home/matty/dev/nixos-config#$(hostname)";
      nrb = "sudo nixos-rebuild boot --flake /home/matty/dev/nixos-config#$(hostname)";
      nrt = "sudo nixos-rebuild test --flake /home/matty/dev/nixos-config#$(hostname)";

      # Modern CLI tool aliases
      cat = "bat";
      ls = "eza --icons --git";
      ll = "eza --icons --git -l";
      la = "eza --icons --git -la";
      tree = "eza --tree";
      find = "fd";

      # Git aliases
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
      lg = "lazygit";

      # Utility aliases
      df = "duf";
      du = "dust";
      top = "btop";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    # Additional zsh options
    initContent = ''
      # Fix unknown terminal type on remote systems that lack kitty terminfo
      export TERM=xterm-256color

      # Enable vi mode
      bindkey -v

      # Better history search with arrow keys
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward

      # Ctrl+R for fzf history search
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # FZF configuration
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

      # Use ripgrep for fzf file search
      export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

      # Zoxide initialization (must be at end)
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # Quick directory jumping with zi
      alias cd="z"
    '';

    # Oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "history"
        "colored-man-pages"
        "command-not-found"
      ];
    };
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Prompt format
      format = "$all";

      # Character configuration
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      # Directory configuration
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      # Git configuration
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        style = "bold yellow";
        conflicted = "🏳";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "$";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      # Command duration
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };

      # Nix shell indicator
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };

  # Bat (better cat) configuration
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # Zoxide (better cd) configuration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;           # Start windows/panes at 1, not 0
    escapeTime = 0;          # No delay for escape key (important for vim)
    aggressiveResize = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible              # Sane defaults
      yank                  # Copy to system clipboard
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_status_modules_right "session date_time"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
      {
        plugin = resurrect;  # Save/restore sessions
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;  # Auto-save sessions every 15 min
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Prefix: Ctrl+Space (ergonomic alternative to Ctrl+B)
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Reload config with prefix+r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Split panes with | and - (intuitive)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New window keeping current path
      bind c new-window -c "#{pane_current_path}"

      # Pane navigation with vim keys (h/j/k/l)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Pane resizing with vim keys (hold prefix, use H/J/K/L)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Fast window switching with Alt+number (no prefix needed)
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5

      # Alt+h/l to switch windows without prefix
      bind -n M-h previous-window
      bind -n M-l next-window

      # Vi-style copy mode
      bind Enter copy-mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send-keys -X cancel

      # Stay in copy mode after mouse drag
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-no-clear

      # Better window/pane titles
      set -g set-titles on
      set -g set-titles-string "#T — #W"
      setw -g automatic-rename on

      # Activity alerts
      setw -g monitor-activity on
      set -g visual-activity off

      # Focus events (needed for vim autoread)
      set -g focus-events on
    '';
  };

  # Git configuration
  programs.git = {
    enable = true;
  };

  # Delta (git diff viewer) configuration
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
    };
  };

  # Lazygit configuration
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          lightTheme = false;
          activeBorderColor = ["#89b4fa" "bold"];
          inactiveBorderColor = ["#a6adc8"];
          selectedLineBgColor = ["#313244"];
        };
      };
    };
  };
}
