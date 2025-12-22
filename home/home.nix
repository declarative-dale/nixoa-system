# SPDX-License-Identifier: Apache-2.0
# Home Manager configuration for NiXOA admin user
# Manages user-specific settings: shell, packages, dotfiles

{ lib, pkgs, username, nixoaCfg ? {}, ... }:

let
  # Get extras enable flag
  extrasEnabled = nixoaCfg.extras.enable or false;

  # Get user packages from config
  userPackages = nixoaCfg.packages.user.extra or [];
in
{
  # ==========================================================================
  # HOME MANAGER BASIC SETUP
  # ==========================================================================

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = nixoaCfg.stateVersion or "25.11";

  # Allow unfree packages if needed
  nixpkgs.config.allowUnfree = true;

  # ==========================================================================
  # USER PACKAGES
  # ==========================================================================

  home.packages = with pkgs; (
    # Map user packages from config
    map (name:
      if pkgs ? ${name}
      then pkgs.${name}
      else throw ''
        Package "${name}" not found in nixpkgs.
        Check spelling or remove from system-settings.toml [packages.user] extra array.
      ''
    ) userPackages
  ) ++ lib.optionals extrasEnabled [
    # Enhanced terminal tools (only if extras enabled)
    oh-my-posh
    zoxide
    fzf
    bat
    eza
    fd
    ripgrep
    dust
    duf
    procs
    broot
    delta
    jq
    yq-go
    gping
    dog
    bottom
    bandwhich
    tealdeer
    lazygit
    gh
  ];

  # ==========================================================================
  # ZSH CONFIGURATION (when extras enabled)
  # ==========================================================================

  programs.zsh = lib.mkIf extrasEnabled {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      path = "\${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      extended = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "systemd"
        "ssh-agent"
        "command-not-found"
        "colored-man-pages"
        "history-substring-search"
      ];
    };

    shellAliases = {
      # Modern replacements
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --git";
      la = "eza -la --icons --group-directories-first --git";
      lt = "eza --tree --level=2 --icons";
      cat = "bat --style=changes,header";
      catn = "bat --style=numbers,changes,header";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      cd = "z";
      cdi = "zi";

      # Git
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";

      # System
      syslog = "journalctl -xe";
      sysfail = "systemctl --failed";
      sysrestart = "sudo systemctl restart";
      sysstatus = "sudo systemctl status";
    };

    initExtra = ''
      # Initialize oh-my-posh with dracula theme
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/dracula.omp.json)"

      # Initialize zoxide (smarter cd)
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # fzf configuration
      export FZF_DEFAULT_COMMAND='${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}"'

      # Initialize fzf key bindings and completion
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # bat theme
      export BAT_THEME="Dracula"

      # Bind keys for history substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^R' fzf-history-widget
    '';

    # ZSH options
    defaultKeymap = "emacs";
  };

  # ==========================================================================
  # BAT CONFIGURATION
  # ==========================================================================

  programs.bat = lib.mkIf extrasEnabled {
    enable = true;
    config = {
      theme = "Dracula";
      style = "changes,header";
      map-syntax = [
        "*.conf:INI"
        ".ignore:Git Ignore"
      ];
    };
  };

  # ==========================================================================
  # GIT CONFIGURATION
  # ==========================================================================

  programs.git = lib.mkIf extrasEnabled {
    enable = true;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.pager = "${pkgs.delta}/bin/delta";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      delta = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # ==========================================================================
  # DIRENV CONFIGURATION
  # ==========================================================================

  programs.direnv = lib.mkIf extrasEnabled {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # ==========================================================================
  # FZF CONFIGURATION
  # ==========================================================================

  programs.fzf = lib.mkIf extrasEnabled {
    enable = true;
    enableZshIntegration = true;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
