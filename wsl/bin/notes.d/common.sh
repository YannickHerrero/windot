#!/usr/bin/env bash
# Common functions and variables for notes CLI

NOTES_DIR="$HOME/notes"

# Folder mappings (short -> full path)
declare -A FOLDER_MAP=(
    ["p"]="1-projects"
    ["projects"]="1-projects"
    ["a"]="2-areas"
    ["areas"]="2-areas"
    ["r"]="3-resources"
    ["resources"]="3-resources"
    ["arc"]="4-archive"
    ["archive"]="4-archive"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print error message and exit
error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

# Print warning message
warn() {
    echo -e "${YELLOW}Warning:${NC} $1" >&2
}

# Print success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Print info message
info() {
    echo -e "${BLUE}$1${NC}"
}

# Check if notes directory exists and has a remote
check_notes_dir() {
    if [[ ! -d "$NOTES_DIR" ]]; then
        error "Notes directory not found at $NOTES_DIR. Please create it and initialize a git repository."
    fi
    
    if [[ ! -d "$NOTES_DIR/.git" ]]; then
        error "Notes directory is not a git repository. Please run: git -C $NOTES_DIR init"
    fi
    
    local remote
    remote=$(git -C "$NOTES_DIR" remote 2>/dev/null)
    if [[ -z "$remote" ]]; then
        error "No git remote configured. Please add a remote with: git -C $NOTES_DIR remote add origin <url>"
    fi
}

# Pull latest changes
git_pull() {
    info "Pulling latest changes..."
    if ! git -C "$NOTES_DIR" pull --rebase --autostash 2>&1; then
        error "Failed to pull changes. Please resolve any conflicts manually."
    fi
}

# Commit and push if there are changes
git_sync() {
    cd "$NOTES_DIR" || exit 1
    
    git add -A
    
    if git diff --cached --quiet; then
        info "No changes to commit."
        return 0
    fi
    
    local commit_msg="sync: $(hostname) - $(date '+%Y-%m-%d %H:%M')"
    if [[ -n "${1:-}" ]]; then
        commit_msg="$1"
    fi
    
    info "Committing changes..."
    if ! git commit -m "$commit_msg" 2>&1; then
        error "Failed to commit changes."
    fi
    
    info "Pushing to remote..."
    if ! git push 2>&1; then
        error "Failed to push changes. Please check your network connection and try again."
    fi
    
    success "Changes synced successfully."
}

# Resolve folder shortcut to full path
resolve_folder() {
    local input="$1"
    local resolved="${FOLDER_MAP[$input]}"
    
    if [[ -n "$resolved" ]]; then
        echo "$resolved"
    else
        echo ""
    fi
}
