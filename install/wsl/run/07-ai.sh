#!/bin/bash
# Install AI tools: claude-code

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

# Ensure nvm is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

echo "Installing AI tools..."

# claude-code
if is_installed claude; then
    echo -e "${YELLOW}[SKIP]${NC} claude-code already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} claude-code"
    npm install -g @anthropic-ai/claude-code
fi

echo "AI tools installation complete!"
