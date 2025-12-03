#!/bin/bash
# Install prerequisites: Homebrew, Go, Rust

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing prerequisites..."

# Homebrew
if is_installed brew; then
    echo -e "${YELLOW}[SKIP]${NC} Homebrew already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Go
if is_installed go; then
    echo -e "${YELLOW}[SKIP]${NC} Go already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} Go"
    sudo apt update
    sudo apt install -y golang-go
fi

# Rust
if is_installed cargo; then
    echo -e "${YELLOW}[SKIP]${NC} Rust already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add to PATH for current session
    source "$HOME/.cargo/env"
fi

echo "Prerequisites installation complete!"
