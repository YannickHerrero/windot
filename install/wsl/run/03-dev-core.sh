#!/bin/bash
# Install dev core: cmake, build-essential, python, docker, neovim

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing dev core tools..."

# cmake
if is_installed cmake; then
    echo -e "${YELLOW}[SKIP]${NC} cmake already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} cmake"
    sudo apt update
    sudo apt install -y cmake
fi

# build-essential (g++, gcc, make)
if is_installed g++; then
    echo -e "${YELLOW}[SKIP]${NC} build-essential already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} build-essential"
    sudo apt install -y build-essential
fi

# python3 and pip
if is_installed python3; then
    echo -e "${YELLOW}[SKIP]${NC} python3 already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} python3"
    sudo apt install -y python3 python3-pip python3-venv
fi

# docker
if is_installed docker; then
    echo -e "${YELLOW}[SKIP]${NC} docker already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} docker"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    echo "Note: Log out and back in for docker group to take effect"
fi

# neovim v0.11.3
if is_installed nvim; then
    echo -e "${YELLOW}[SKIP]${NC} neovim already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} neovim v0.11.3"
    curl -fLo /tmp/nvim.appimage https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage
    chmod u+x /tmp/nvim.appimage
    # Extract and install (AppImage may not work directly in WSL)
    cd /tmp
    ./nvim.appimage --appimage-extract
    sudo mv squashfs-root /opt/nvim
    sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
    rm /tmp/nvim.appimage
fi

echo "Dev core tools installation complete!"
