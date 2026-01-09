#!/bin/bash

# Claude check hooks
#
# Prevents commits authored by or mentioning Claude in the message.
#
# Installs two git hooks: pre-commit (checks author name/email) and commit-msg (checks message content).
# ---

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    echo "Please run this script from within a git repository."
    exit 1
fi

GIT_DIR=$(git rev-parse --git-dir)
COMMIT_MSG_HOOK_PATH="${GIT_DIR}/hooks/commit-msg"
PRE_COMMIT_HOOK_PATH="${GIT_DIR}/hooks/pre-commit"

# Check if hooks already exist
if [ -f "$PRE_COMMIT_HOOK_PATH" ] || [ -f "$COMMIT_MSG_HOOK_PATH" ]; then
    echo -e "${YELLOW}Warning: Claude check hooks already exist${NC}"
    read -p "Do you want to overwrite them? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Create the pre-commit hook (checks author info)
cat > "$PRE_COMMIT_HOOK_PATH" << 'EOF'
#!/bin/bash

# Pre-commit hook to reject commits co-authored or authored by Claude

RED='\033[0;31m'
NC='\033[0m' # No Color

# Get git config for author name and email
AUTHOR_NAME=$(git config user.name)
AUTHOR_EMAIL=$(git config user.email)

# Convert to lowercase for case-insensitive comparison
AUTHOR_NAME_LOWER=$(echo "$AUTHOR_NAME" | tr '[:upper:]' '[:lower:]')
AUTHOR_EMAIL_LOWER=$(echo "$AUTHOR_EMAIL" | tr '[:upper:]' '[:lower:]')

# Check for "claude" in author name
if [[ "$AUTHOR_NAME_LOWER" == *"claude"* ]]; then
    echo -e "${RED}✗ Commit rejected: Commits must not be authored by or co-authored by Claude${NC}"
    echo "  Author: $AUTHOR_NAME"
    exit 1
fi

# Check for "claude" in author email
if [[ "$AUTHOR_EMAIL_LOWER" == *"claude"* ]]; then
    echo -e "${RED}✗ Commit rejected: Commits must not be authored by or co-authored by Claude${NC}"
    echo "  Email: $AUTHOR_EMAIL"
    exit 1
fi

# All checks passed
exit 0
EOF

# Create the commit-msg hook (checks commit message)
cat > "$COMMIT_MSG_HOOK_PATH" << 'EOF'
#!/bin/bash

# Commit-msg hook to reject commits mentioning Claude

RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the commit message
COMMIT_MSG=$(cat "$1")

# Convert to lowercase for case-insensitive comparison
COMMIT_MSG_LOWER=$(echo "$COMMIT_MSG" | tr '[:upper:]' '[:lower:]')

# Check for "claude" in commit message
if [[ "$COMMIT_MSG_LOWER" == *"claude"* ]]; then
    echo -e "${RED}✗ Commit rejected: Commits must not mention Claude${NC}"
    echo "  Message preview: $(echo "$COMMIT_MSG" | head -1)"
    exit 1
fi

# All checks passed
exit 0
EOF

# Make the hooks executable
chmod +x "$PRE_COMMIT_HOOK_PATH"
chmod +x "$COMMIT_MSG_HOOK_PATH"

echo -e "${GREEN}✓ Successfully installed claude check hooks${NC}"
echo "  Pre-commit hook: $PRE_COMMIT_HOOK_PATH"
echo "  Commit-msg hook: $COMMIT_MSG_HOOK_PATH"
echo ""
echo "The hooks will now reject commits that:"
echo "  • Are authored by or co-authored by Claude"
echo "  • Mention Claude in the commit message"
echo ""
echo -e "${YELLOW}Note:${NC} All checks are case-insensitive."
