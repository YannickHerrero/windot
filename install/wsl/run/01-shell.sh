#!/bin/bash
# Install shell tools: zsh, git-delta

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing shell tools..."

# zsh
if is_installed zsh; then
    echo -e "${YELLOW}[SKIP]${NC} zsh already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} zsh"
    sudo apt update
    sudo apt install -y zsh
fi

# git-delta
if is_installed delta; then
    echo -e "${YELLOW}[SKIP]${NC} git-delta already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} git-delta"
    # Download latest release
    DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
    sudo dpkg -i /tmp/delta.deb
    rm /tmp/delta.deb
fi

echo "Shell tools installation complete!"
