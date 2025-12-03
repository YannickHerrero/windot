#!/bin/bash
# Install utilities: bat, btop, eza, tldr, fastfetch, fzf

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing utilities..."

# bat
if is_installed bat || is_installed batcat; then
    echo -e "${YELLOW}[SKIP]${NC} bat already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} bat"
    sudo apt update
    sudo apt install -y bat
fi

# btop
if is_installed btop; then
    echo -e "${YELLOW}[SKIP]${NC} btop already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} btop"
    sudo apt install -y btop
fi

# fzf
if is_installed fzf; then
    echo -e "${YELLOW}[SKIP]${NC} fzf already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} fzf"
    sudo apt install -y fzf
fi

# tldr
if is_installed tldr; then
    echo -e "${YELLOW}[SKIP]${NC} tldr already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} tldr"
    sudo apt install -y tldr
fi

# eza
if is_installed eza; then
    echo -e "${YELLOW}[SKIP]${NC} eza already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} eza"
    sudo apt install -y eza 2>/dev/null || {
        # Fallback to cargo if apt doesn't have eza
        if is_installed cargo; then
            cargo install eza
        else
            echo "eza not available via apt and cargo not installed, skipping"
        fi
    }
fi

# fastfetch
if is_installed fastfetch; then
    echo -e "${YELLOW}[SKIP]${NC} fastfetch already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} fastfetch"
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null || true
    sudo apt update
    sudo apt install -y fastfetch
fi

echo "Utilities installation complete!"
