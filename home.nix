{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  # --- Packages ---
  home.packages = with pkgs; [
    # cli tools
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    gh        # github cli
    lazygit
    uv        # fast python package manager
    neovim

    # language runtimes
    nodejs_22
    python312

    # font
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # --- Shell (Oh-My-Zsh) ---
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude";
      rebuild = "cd ~/.dotfiles && ./rebuild.sh";
    };
  };

  # --- Git ---
  programs.git = {
    enable = true;
    lfs.enable = true;
    # email and signingkey intentionally left out - set per machine:
    #   git config --global user.email "your-email"
    settings = {
      user.name = "Alex Ong";
      log.follow = true;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  # --- Symlinks (edit-in-place: real files live in this repo) ---

  # Terminal & editor configs
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";

  # VS Code settings
  home.file."Library/Application Support/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.vscode/settings.json";
  home.file."Library/Application Support/Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.vscode/keybindings.json";

  # Claude Code
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/CLAUDE.md";
  home.file.".claude/notify.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/notify.sh";
    executable = true;
  };
  home.file.".claude/statusline.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/statusline.sh";
    executable = true;
  };
  home.file.".claude/agents".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/agents";
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/skills";
}
