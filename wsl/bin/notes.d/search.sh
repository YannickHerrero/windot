#!/usr/bin/env bash
# Search command: fuzzy search notes by title or content

cmd_search() {
    check_notes_dir
    
    if ! command -v fzf &> /dev/null; then
        error "fzf is not installed. Please install it with: brew install fzf"
    fi
    
    local deep=false
    local query=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --deep|-d)
                deep=true
                shift
                ;;
            *)
                query="$1"
                shift
                ;;
        esac
    done
    
    git_pull
    
    local selected
    
    if [[ "$deep" == true ]]; then
        # Search content with ripgrep + fzf
        if ! command -v rg &> /dev/null; then
            error "ripgrep (rg) is not installed. Please install it with: brew install ripgrep"
        fi
        
        selected=$(
            cd "$NOTES_DIR" && \
            rg --files-with-matches --no-messages "${query:-.}" \
                --glob '!.git' \
                --type md 2>/dev/null | \
            fzf --preview "rg --context 3 --color=always '${query:-.}' {}" \
                --preview-window=right:60%:wrap \
                --query="$query"
        )
    else
        # Search by filename
        selected=$(
            cd "$NOTES_DIR" && \
            find . -type f -name '*.md' ! -path './.git/*' | \
            sed 's|^\./||' | \
            fzf --preview "head -20 '$NOTES_DIR/{}'" \
                --preview-window=right:60%:wrap \
                --query="$query"
        )
    fi
    
    if [[ -z "$selected" ]]; then
        info "No file selected."
        return 0
    fi
    
    # Open selected file in nvim
    nvim "$NOTES_DIR/$selected"
    
    # Sync after closing
    git_sync
}
