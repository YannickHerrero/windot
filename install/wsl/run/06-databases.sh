#!/bin/bash
# Install database tools: postgresql-client

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

is_installed() {
    command -v "$1" &> /dev/null
}

echo "Installing database tools..."

# postgresql-client
if is_installed psql; then
    echo -e "${YELLOW}[SKIP]${NC} postgresql-client already installed"
else
    echo -e "${GREEN}[INSTALL]${NC} postgresql-client"
    sudo apt update
    sudo apt install -y postgresql-client
fi

echo "Database tools installation complete!"
