#!/usr/bin/env bash
# Add command: quick note to inbox or create file in folder

cmd_add() {
    check_notes_dir
    git_pull
    
    # If only one argument and no folder shortcut, it's a quick note
    if [[ $# -eq 1 ]]; then
        local folder
        folder=$(resolve_folder "$1")
        
        if [[ -z "$folder" ]]; then
            # It's a quick note message
            add_quick_note "$1"
            return
        else
            error "Missing filename. Usage: notes add <folder> <filename>"
        fi
    fi
    
    # If no arguments, show error
    if [[ $# -eq 0 ]]; then
        error "Missing arguments. Usage: notes add \"message\" or notes add <folder> [subfolders...] <filename>"
    fi
    
    # Check if first arg is a folder shortcut
    local folder
    folder=$(resolve_folder "$1")
    
    if [[ -z "$folder" ]]; then
        # First arg is not a folder, treat entire input as quick note
        add_quick_note "$*"
    else
        # First arg is a folder, create a new file
        shift
        create_note_file "$folder" "$@"
    fi
}

add_quick_note() {
    local message="$1"
    local inbox_dir="$NOTES_DIR/0-inbox"
    local inbox_file="$inbox_dir/inbox.md"
    
    # Create inbox directory if it doesn't exist
    mkdir -p "$inbox_dir"
    
    # Create inbox.md if it doesn't exist
    if [[ ! -f "$inbox_file" ]]; then
        echo "# Inbox" > "$inbox_file"
        echo "" >> "$inbox_file"
    fi
    
    # Append the note with timestamp
    {
        echo ""
        echo "## $(date '+%Y-%m-%d %H:%M')"
        echo "$message"
    } >> "$inbox_file"
    
    success "Note added to inbox."
    git_sync "quick note: $(hostname) - $(date '+%Y-%m-%d %H:%M')"
}

create_note_file() {
    local base_folder="$1"
    shift
    
    if [[ $# -eq 0 ]]; then
        error "Missing filename. Usage: notes add <folder> [subfolders...] <filename>"
    fi
    
    # Last argument is the filename, everything else is subfolder path
    local args=("$@")
    local filename="${args[-1]}"
    unset 'args[-1]'
    local subfolders=("${args[@]}")
    
    # Build the full path
    local full_path="$NOTES_DIR/$base_folder"
    
    for subfolder in "${subfolders[@]}"; do
        full_path="$full_path/$subfolder"
    done
    
    # Create directories if they don't exist
    mkdir -p "$full_path"
    
    # Add .md extension if not present
    if [[ "$filename" != *.md ]]; then
        filename="$filename.md"
    fi
    
    local file_path="$full_path/$filename"
    
    # Check if file already exists
    if [[ -f "$file_path" ]]; then
        info "File already exists, opening..."
    else
        # Create file with template
        local title="${filename%.md}"
        {
            echo "# $title"
            echo ""
            echo "Created: $(date '+%Y-%m-%d')"
            echo ""
        } > "$file_path"
        success "Created: $file_path"
    fi
    
    # Open in nvim
    nvim "$file_path"
    
    # Sync after closing
    git_sync "add: $filename - $(hostname) - $(date '+%Y-%m-%d %H:%M')"
}
