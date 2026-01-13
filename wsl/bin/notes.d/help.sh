#!/usr/bin/env bash
# Help command: show usage information

cmd_help() {
    cat << 'EOF'
notes - A CLI tool for managing your notes with git sync

USAGE:
    notes                           Open notes folder in nvim (pull, edit, commit, push)
    notes add "message"             Add quick note to inbox
    notes add <folder> <file>       Create new note in folder and open in nvim
    notes add <folder> <sub> <file> Create note in subfolder (creates folders if needed)
    notes list                      Show tree view of all notes
    notes search [query]            Fuzzy search notes by filename
    notes search --deep [query]     Fuzzy search notes by content
    notes help                      Show this help message

FOLDER SHORTCUTS:
    p, projects     -> 1-projects/
    a, areas        -> 2-areas/
    r, resources    -> 3-resources/
    arc, archive    -> 4-archive/

EXAMPLES:
    notes                               # Open notes in nvim
    notes add "Remember to buy milk"    # Quick note to inbox
    notes add p my-project              # Create 1-projects/my-project.md
    notes add a work meetings           # Create 2-areas/work/meetings.md
    notes add p doku ideas feature      # Create 1-projects/doku/ideas/feature.md
    notes search                        # Browse all notes with fzf
    notes search readme                 # Search for files containing "readme"
    notes search --deep TODO            # Search inside file contents for "TODO"

REQUIREMENTS:
    - git (with remote configured)
    - nvim
    - tree (for list command)
    - fzf (for search command)
    - ripgrep (for deep search)
EOF
}
