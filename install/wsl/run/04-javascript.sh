#!/bin/bash
# Install JavaScript tools: nvm, node, pnpm, bun, eas-cli

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing JavaScript tools..."

# nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo -e "${YELLOW}[SKIP]${NC} nvm already installed"
    source "$NVM_DIR/nvm.sh"
else
    echo -e "${GREEN}[INSTALL]${NC} nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source "$NVM_DIR/nvm.sh"
fi

# node (LTS)
if is_installed node; then
    echo -e "${YELLOW}[SKIP]${NC} node already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} node (LTS)"
    nvm install --lts
    nvm use --lts
fi

# pnpm
if is_installed pnpm; then
    echo -e "${YELLOW}[SKIP]${NC} pnpm already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} pnpm"
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# bun
if is_installed bun; then
    echo -e "${YELLOW}[SKIP]${NC} bun already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} bun"
    curl -fsSL https://bun.sh/install | bash
fi

# eas-cli
if is_installed eas; then
    echo -e "${YELLOW}[SKIP]${NC} eas-cli already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} eas-cli"
    npm install -g eas-cli
fi

echo "JavaScript tools installation complete!"
