# dotfiles

Declarative macOS setup using [Nix](https://nixos.org/), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager). One command takes a fresh Mac to a fully configured dev environment.

Inspired by [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles).

## What gets installed

**Apps (via Homebrew):** WezTerm, VS Code, Claude Code, Bruno, Obsidian, OpenSuperWhisper, herdr

**CLI tools (via Nix):** ripgrep, fd, fzf, jq, gh, lazygit, uv, neovim

**Runtimes (via Nix):** Node.js 20, Python 3.12

**Shell:** Oh-My-Zsh with robbyrussell theme, zsh-autosuggestions, zsh-syntax-highlighting

**macOS defaults:** Dark mode, fast key repeat, dock autohide, Finder list view, tap-to-click

**Configs (symlinked from this repo):** WezTerm, herdr, Neovim, VS Code settings/keybindings, Claude Code (settings, agents, skills, statusline, notifications)

## Fresh Mac setup

```bash
# 1. Install git (if not already present)
xcode-select --install

# 2. Clone and bootstrap
git clone https://github.com/alexong7/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh

# 3. Post-bootstrap manual steps
./post-bootstrap.sh    # prints the checklist
```

Bootstrap takes ~10-15 minutes. It installs Determinate Nix, then uses nix-darwin to install and configure everything.

## After bootstrap

### Manual steps (~10 min)

1. **SSH key:** `ssh-keygen -t ed25519` → add to GitHub
2. **Git email:** `git config --global user.email "your-email"`
3. **Dotfiles remote:** `cd ~/.dotfiles && git remote set-url origin git@github.com:alexong7/dotfiles.git`
4. **Obsidian vault:** `cd ~/Documents && git clone git@github.com:alexong7/Obsidian-Notes.git "Obsidian Notes/Obsidian Notes"`
5. **VS Code extensions:** `~/.dotfiles/install-vscode-extensions.sh`
6. **Sign into apps:** VS Code, Obsidian, Claude Code

## Making changes

### Config files (WezTerm, Claude, VS Code, herdr, Neovim)

Edit the file in `home/` — changes take effect immediately (they're symlinked).

### Adding/removing apps or packages

Edit `configuration.nix` (Homebrew apps) or `home.nix` (Nix packages), then:

```bash
./rebuild.sh
```

### Adding a Homebrew cask

```nix
# configuration.nix
homebrew.casks = [
  # ... existing casks ...
  "new-app"
];
```

### Adding a Nix package

```nix
# home.nix
home.packages = with pkgs; [
  # ... existing packages ...
  new-package
];
```

### Adding a shell alias

```nix
# home.nix
shellAliases = {
  # ... existing aliases ...
  myalias = "some command";
};
```

## File structure

```
flake.nix           -- entry point, wires dependencies together
configuration.nix   -- macOS defaults + Homebrew apps
home.nix            -- shell, packages, symlinks
bootstrap.sh        -- run once on fresh Mac
rebuild.sh          -- apply changes after editing nix configs
home/
  .config/wezterm/  -- terminal config
  .config/herdr/    -- terminal multiplexer config
  .config/nvim/     -- neovim config
  .claude/          -- Claude Code settings, agents, skills
  .vscode/          -- VS Code settings + keybindings
```

## Important notes

- **`zap` cleanup is intentional.** Homebrew removes anything not declared in `configuration.nix` on every rebuild. This forces everything to be declarative and reproducible. If you install something via `brew install` directly, it will be removed on the next rebuild. Add it to `configuration.nix` instead.
- **Git identity is intentionally omitted.** Set `user.email` manually per machine so the same dotfiles work on both personal and work machines.
- **VS Code extensions are installed via script**, not Nix, because the home-manager VS Code module requires extensions to be in nixpkgs (many aren't).
