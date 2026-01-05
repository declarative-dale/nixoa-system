# SPDX-License-Identifier: Apache-2.0
# Home Manager configuration for NiXOA admin user
# Manages user-specific settings: shell, packages, dotfiles

{ config, lib, pkgs, osConfig ? {}, ... }:

let
  # Get admin username and shell from system config via the top-level config
  adminUsername = if (builtins.hasAttr "nixoa" config) && (builtins.hasAttr "admin" config.nixoa)
                   then config.nixoa.admin.username
                   else "xoa";
  stateVersion = if (builtins.hasAttr "nixoa" config) && (builtins.hasAttr "system" config.nixoa)
                  then config.nixoa.system.stateVersion
                  else "25.11";

  # Command for fzf to use fd (a fast find alternative) for file searching
  fdSearchCmd = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
in
{
  # ==========================================================================
  # HOME MANAGER BASIC SETUP
  # ==========================================================================

  home.username = adminUsername;
  home.homeDirectory = "/home/${adminUsername}";
  home.stateVersion = stateVersion;

  # ==========================================================================
  # USER PACKAGES
  # ==========================================================================

  home.packages = with pkgs; (
    # Base packages (always installed)
    []
  ) ++ lib.optionals (osConfig.nixoa.extras.enable or false) [
    # Enhanced terminal tools (included when extras are enabled)
    bat           # Cat replacement with syntax highlighting
    eza           # Modern ls replacement
    fd            # Find replacement (used for fzf default search)
    ripgrep       # Rg, a faster grep alternative
    dust          # Du alternative for disk usage
    duf           # Disk usage utility with more features
    procs         # Improved ps command
    broot         # Tree navigation tool
    delta         # Improved diff for git
    jq            # JSON processor
    yq-go         # YAML processor (Go version of yq)
    gping         # Ping with graph output
    dog           # DNS lookup (dig replacement)
    bottom        # Modern top/htop alternative
    bandwhich     # Bandwidth utilization viewer
    tealdeer      # Tldr pages viewer
    lazygit       # Terminal UI for git
    gh            # GitHub CLI

    # To add additional user packages, edit this section directly.
    # Examples:
    #   htop          # system monitor
    #   tmux          # terminal multiplexer
    #   neovim        # text editor
  ];

  # ==========================================================================
  # USER ENVIRONMENT (STORAGE PATHS, VARIABLES)
  # ==========================================================================

  home.sessionVariables = {
    # Expose the Xen Orchestra mounts directory as an environment variable
    XO_MOUNTS = "/var/lib/xo/mounts";
  };

  # ==========================================================================
  # ZSH CONFIGURATION
  # ==========================================================================

  # Always enable zsh when admin shell is zsh, and configure all options when enabled
  programs.zsh = lib.mkIf (osConfig.nixoa.admin.shell == "zsh") {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;         # Zsh autosuggestions (typeahead suggestions)
    syntaxHighlighting.enable = true;     # Syntax highlighting for command line

    history = {
      size = 50000;                       # Large history file to remember lots of commands
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      extended = true;
      share = true;                       # Share history across sessions
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"                   # Git plugin (aliases and helpers)
        "sudo"                  # Easily repeat last command with sudo
        "docker"                # Docker command aliases/completion
        "kubectl"               # Kubectl integration
        "systemd"               # Systemd unit management aliases
        "ssh-agent"             # SSH agent plugin (manage keys)
        "command-not-found"     # Suggest installations for unknown commands
        "colored-man-pages"     # Colorize man pages
        "history-substring-search"  # Incremental history search (bound to arrow keys below)
      ];
    };

    shellAliases = {
      # Modern replacements for common commands
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --git";
      la = "eza -la --icons --group-directories-first --git";
      lt = "eza --tree --level=2 --icons";
      cat = "bat --style=changes,header";               # Use bat for viewing files with changes highlighted
      catn = "bat --style=numbers,changes,header";      # Bat with line numbers

      # Navigation shortcuts (using zoxide under the hood)
      ".." = "cd ..";
      "..." = "cd ../..";
      cd = "z";    # Use zoxide's 'z' to jump to frequently used dirs
      cdi = "zi";  # Use zoxide's 'zi' for interactive directory selection (fzf)

      # Git command shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";

      # System management shortcuts
      syslog = "journalctl -xe";                  # View system log errors
      sysfail = "systemctl --failed";             # Show failed systemd units
      sysrestart = "sudo systemctl restart";      # Restart a systemd service (usage: sysrestart <unit>)
      sysstatus = "sudo systemctl status";        # Check status of a systemd service (usage: sysstatus <unit>)
    };

    # Zsh initialization commands
    initExtra = ''
      # Configure FZF with preview (set here to avoid shell export issues with complex arguments)
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}'"

      # Bind Up/Down arrows to history substring search (from oh-my-zsh plugin)
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      # (Ctrl+R is bound by fzf integration to open searchable command history)
    '';

    defaultKeymap = "emacs";  # Use Emacs keybindings in shell (e.g. Ctrl+A, Ctrl+E for navigation)
  };

  # ==========================================================================
  # TOOL CONFIGURATIONS (when extras are enabled)
  # ==========================================================================

  programs.bat = lib.mkIf (osConfig.nixoa.extras.enable or false) {
    enable = true;
    config = {
      theme = "Dracula";                   # Set bat's color theme
      style = "changes,header";            # Default style: show git changes and file header
      map-syntax = [
        "*.conf:INI"                      # Treat .conf files as INI for syntax highlighting
        ".ignore:Git Ignore"              # Treat .ignore like .gitignore syntax
      ];
    };
  };

  programs.git = lib.mkIf (osConfig.nixoa.extras.enable or false) {
    enable = true;
    settings = {
      init.defaultBranch = "main";         # Use 'main' as default branch name for new repos
      pull.rebase = true;                  # Default `git pull` to rebase
      core.pager = "${pkgs.delta}/bin/delta";                        # Use delta for paging diffs
      delta = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
      merge.conflictstyle = "diff3";       # Include base diff in merge conflicts
      diff.colorMoved = "default";         # Default moved lines coloring
    };
  };

  programs.direnv = lib.mkIf (osConfig.nixoa.extras.enable or false) {
    enable = true;
    nix-direnv.enable = true;             # Integrate direnv with Nix (nix-direnv)
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = lib.mkIf (osConfig.nixoa.extras.enable or false) {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fzf = lib.mkIf (osConfig.nixoa.extras.enable or false) {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # Use fd for default file search (Ctrl-T and general fzf) and bat for preview in fzf
    defaultCommand = fdSearchCmd;         # FZF_DEFAULT_COMMAND (list files using fd)
    fileWidgetCommand = fdSearchCmd;      # FZF_CTRL_T_COMMAND (also use fd for Ctrl-T)
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # ==========================================================================
  # BASH CONFIGURATION
  # ==========================================================================

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # Shell aliases only in interactive mode (not during login shell initialization)
    # This prevents syntax errors with aliases containing --flags during SSH login
  };

  # ==========================================================================
  # OH-MY-POSH CONFIGURATION (when extras are enabled)
  # ==========================================================================

  programs.oh-my-posh = lib.mkIf (osConfig.nixoa.extras.enable or false) {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    useTheme = "night-owl";
  };

  # Let Home Manager manage itself (allows using the `home-manager` command for this user)
  programs.home-manager.enable = true;
}
