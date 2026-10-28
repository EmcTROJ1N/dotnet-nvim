#!/bin/bash
set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${BLUE}▸${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $1"; }
error()   { echo -e "${RED}✗${RESET} $1"; exit 1; }
header()  { echo -e "\n${BOLD}$1${RESET}"; }

# ── OS detection ──────────────────────────────────────────────────────────────
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ -f /etc/debian_version ]]; then
  OS="debian"
elif [[ -f /etc/fedora-release ]]; then
  OS="fedora"
elif [[ -f /etc/arch-release ]]; then
  OS="arch"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

install_pkg() {
  case "$OS" in
    mac)    brew install "$@" ;;
    debian) sudo apt-get install -y "$@" ;;
    fedora) sudo dnf install -y "$@" ;;
    arch)   sudo pacman -S --noconfirm "$@" ;;
    *)      warn "Unknown OS — install manually: $*" ;;
  esac
}

# ── Homebrew (macOS only) ─────────────────────────────────────────────────────
header "1. Package manager"
if [[ "$OS" == "mac" ]]; then
  if ! has brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installed"
  else
    success "Homebrew already installed"
  fi
elif [[ "$OS" == "debian" ]]; then
  sudo apt-get update -q
  success "apt updated"
fi

# ── Neovim ────────────────────────────────────────────────────────────────────
header "2. Neovim"
if ! has nvim; then
  info "Installing Neovim..."
  case "$OS" in
    mac)    brew install neovim ;;
    debian) sudo apt-get install -y neovim ;;
    fedora) sudo dnf install -y neovim ;;
    arch)   sudo pacman -S --noconfirm neovim ;;
    *)      error "Install Neovim manually: https://github.com/neovim/neovim/releases" ;;
  esac
  success "Neovim installed"
else
  NVIM_VER=$(nvim --version | head -1)
  success "Neovim already installed ($NVIM_VER)"
fi

# ── Core dependencies ─────────────────────────────────────────────────────────
header "3. Dependencies"

if ! has git; then
  info "Installing git..."
  install_pkg git
fi
success "git: $(git --version)"

if ! has rg; then
  info "Installing ripgrep..."
  install_pkg ripgrep
fi
success "ripgrep: $(rg --version | head -1)"

if ! has fd; then
  info "Installing fd..."
  case "$OS" in
    mac)    brew install fd ;;
    debian) sudo apt-get install -y fd-find && sudo ln -sf "$(which fdfind)" /usr/local/bin/fd ;;
    fedora) sudo dnf install -y fd-find ;;
    arch)   sudo pacman -S --noconfirm fd ;;
  esac
fi
success "fd: $(fd --version)"

if ! has node; then
  info "Installing Node.js..."
  case "$OS" in
    mac)    brew install node ;;
    debian) curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs ;;
    fedora) sudo dnf install -y nodejs ;;
    arch)   sudo pacman -S --noconfirm nodejs npm ;;
  esac
fi
success "node: $(node --version)"

if ! has tree-sitter; then
  info "Installing tree-sitter-cli..."
  npm install -g tree-sitter-cli
fi
success "tree-sitter: $(tree-sitter --version 2>/dev/null || echo 'ok')"

# ── Nerd Font ─────────────────────────────────────────────────────────────────
header "4. Nerd Font (JetBrainsMono)"
if [[ "$OS" == "mac" ]]; then
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono" && \
     ! ls ~/Library/Fonts/JetBrains* 2>/dev/null | grep -q .; then
    info "Installing JetBrainsMono Nerd Font..."
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-jetbrains-mono-nerd-font
    success "JetBrainsMono Nerd Font installed"
  else
    success "JetBrainsMono Nerd Font already installed"
  fi
else
  FONT_DIR="$HOME/.local/share/fonts"
  if ! fc-list | grep -qi "JetBrainsMono"; then
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    curl -fsSL "$FONT_URL" -o /tmp/JetBrainsMono.tar.xz
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR" --wildcards "*.ttf" 2>/dev/null || true
    fc-cache -f "$FONT_DIR"
    rm /tmp/JetBrainsMono.tar.xz
    success "JetBrainsMono Nerd Font installed"
  else
    success "JetBrainsMono Nerd Font already installed"
  fi
fi

# ── Optional: .NET & dotnet-ef ────────────────────────────────────────────────
header "5. Optional: .NET (for C# / EF Core)"
if has dotnet; then
  success ".NET already installed: $(dotnet --version)"
  if ! dotnet tool list -g | grep -q "dotnet-ef"; then
    info "Installing dotnet-ef globally..."
    dotnet tool install --global dotnet-ef
    success "dotnet-ef installed"
  else
    success "dotnet-ef already installed"
  fi
else
  warn ".NET not found — skip (install from https://dot.net if you need C# / EF Core)"
fi

# ── Optional: xkb-switch (Linux keyboard layout in statusline) ───────────────
if [[ "$OS" != "mac" ]]; then
  header "6. Optional: xkb-switch (keyboard layout in statusline)"
  if ! has xkb-switch; then
    case "$OS" in
      debian) sudo apt-get install -y xkb-switch 2>/dev/null && success "xkb-switch installed" || warn "xkb-switch not available — install manually if needed" ;;
      arch)   sudo pacman -S --noconfirm xkb-switch 2>/dev/null && success "xkb-switch installed" || warn "xkb-switch not available" ;;
      *)      warn "xkb-switch not installed — keyboard layout won't show in statusline" ;;
    esac
  else
    success "xkb-switch already installed"
  fi
fi

# ── Neovim config ─────────────────────────────────────────────────────────────
header "7. Neovim config"
NVIM_CONFIG="$HOME/.config/nvim"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" == "$NVIM_CONFIG" ]]; then
  success "Already installed to ~/.config/nvim"
else
  if [[ -d "$NVIM_CONFIG" ]]; then
    BACKUP="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    warn "Existing config found — backing up to $BACKUP"
    mv "$NVIM_CONFIG" "$BACKUP"
  fi
  info "Copying config to ~/.config/nvim..."
  cp -r "$SCRIPT_DIR" "$NVIM_CONFIG"
  success "Config installed to ~/.config/nvim"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ Installation complete!${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "  1. Set your terminal font to ${BOLD}JetBrainsMono Nerd Font${RESET}"
echo -e "  2. Open ${BOLD}nvim${RESET} — plugins install automatically on first launch"
echo -e "  3. Run ${BOLD}:Keys${RESET} inside nvim to see all keybindings"
echo ""
echo -e "  ${BOLD}Per-project config (.neovim/ folder):${RESET}"
echo -e "  :RunSetup   — configure run configurations"
echo -e "  :EfSetup    — configure EF Core migration projects"
echo ""
