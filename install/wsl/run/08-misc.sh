#!/bin/bash
# Install misc tools: ansible, xleak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure cargo is in PATH
source "$HOME/.cargo/env" 2>/dev/null || true

echo "Installing misc tools..."

# ansible
if is_installed ansible; then
    echo -e "${YELLOW}[SKIP]${NC} ansible already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} ansible"
    sudo apt update
    sudo apt install -y ansible
fi

# xleak
if is_installed xleak; then
    echo -e "${YELLOW}[SKIP]${NC} xleak already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} xleak"
    cargo install xleak
fi

echo "Misc tools installation complete!"
