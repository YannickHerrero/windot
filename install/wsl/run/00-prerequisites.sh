#!/bin/bash
# Install prerequisites: mise (polyglot tool manager)
# Mise will handle: node, pnpm, bun, go, rust, and CLI tools

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing prerequisites..."

# mise
if is_installed mise; then
    echo -e "${YELLOW}[SKIP]${NC} mise already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} mise"
    curl https://mise.run | sh
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
fi

# Ensure mise config is in place
MISE_CONFIG_DIR="$HOME/.config/mise"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WINDOT_MISE_CONFIG="$SCRIPT_DIR/../../../wsl/config/mise/config.toml"

if [ -f "$WINDOT_MISE_CONFIG" ]; then
    mkdir -p "$MISE_CONFIG_DIR"
    if [ ! -L "$MISE_CONFIG_DIR/config.toml" ] || [ "$(readlink -f "$MISE_CONFIG_DIR/config.toml")" != "$(readlink -f "$WINDOT_MISE_CONFIG")" ]; then
        ln -sf "$(readlink -f "$WINDOT_MISE_CONFIG")" "$MISE_CONFIG_DIR/config.toml"
        echo -e "${GREEN}[LINK]${NC} mise config symlinked"
    else
        echo -e "${YELLOW}[SKIP]${NC} mise config already linked"
    fi
fi

# Install all tools defined in mise config
echo -e "${GREEN}[INSTALL]${NC} Installing mise tools (this may take a while)..."
mise install --yes

echo "Prerequisites installation complete!"
echo "Installed tools via mise:"
mise list
