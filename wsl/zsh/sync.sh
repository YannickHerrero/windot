#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy .zshrc to home directory
cp "$SCRIPT_DIR/.zshrc" ~/.zshrc

# Create zsh config directory and copy all config files
mkdir -p ~/.zsh
cp "$SCRIPT_DIR"/*.zsh ~/.zsh/

echo "Synced zsh config to ~/.zshrc and ~/.zsh/"
echo "Run 'source ~/.zshrc' to apply changes"
