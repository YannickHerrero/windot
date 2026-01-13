#!/usr/bin/env bash
# Default command: pull, open nvim, commit and push on close

cmd_open() {
    check_notes_dir
    git_pull
    
    # Open nvim in notes dir without changing current directory
    nvim "$NOTES_DIR"
    
    git_sync
}
