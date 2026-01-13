#!/usr/bin/env bash
# List command: show tree view of all notes

cmd_list() {
    check_notes_dir
    
    if ! command -v tree &> /dev/null; then
        error "tree is not installed. Please install it with: sudo apt install tree"
    fi
    
    tree "$NOTES_DIR" -I '.git' --dirsfirst -C
}
