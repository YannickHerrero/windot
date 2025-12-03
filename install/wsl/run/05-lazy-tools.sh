#!/bin/bash
# Install lazy tools: lazydocker, lazygit, lazysql, yazi

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure Go bin is in PATH
export PATH="$PATH:$(go env GOPATH)/bin"

# Ensure Homebrew is in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true

echo "Installing lazy tools..."

# lazydocker
if is_installed lazydocker; then
    echo -e "${YELLOW}[SKIP]${NC} lazydocker already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} lazydocker"
    go install github.com/jesseduffield/lazydocker@latest
fi

# lazygit
if is_installed lazygit; then
    echo -e "${YELLOW}[SKIP]${NC} lazygit already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} lazygit"
    go install github.com/jesseduffield/lazygit@latest
fi

# lazysql (via brew)
if is_installed lazysql; then
    echo -e "${YELLOW}[SKIP]${NC} lazysql already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} lazysql"
    brew install lazysql
fi

# yazi (via brew)
if is_installed yazi; then
    echo -e "${YELLOW}[SKIP]${NC} yazi already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} yazi"
    brew install yazi
fi

echo "Lazy tools installation complete!"
