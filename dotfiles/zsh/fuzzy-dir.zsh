fd() {
    local dir
    dir=$(find /home/$USER/perso /home/$USER/project /home/$USER/.dotfiles /home/$USER/.config /home/$USER/dev -type d \( \
        -path "*/node_modules" -o \
        -path "*/.git" -o \
        -path "*/.cache" -o \
        -path "*/.vscode" -o \
        -path "*/.npm" -o \
        -path "*/dist" -o \
        -path "*/.bun" -o \
        -path "*/.local" -o \
        -path "*/.next" -o \
        -path "*/.expo" -o \
        -path "*/.asdf" -o \
        -path "*/.docker" -o \
        -path "*/build" \
    \) -prune -o -type d -print | \
    fzf --preview 'tree -C -L 2 -I "node_modules|.git" {} | head -200' --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

ff() {
    local file
    file=$(find /home/$USER/perso /home/$USER/project /home/$USER/.dotfiles /home/$USER/.config /home/$USER/dev -type d \( \
        -path "*/node_modules" -o \
        -path "*/.git" -o \
        -path "*/.cache" -o \
        -path "*/.vscode" -o \
        -path "*/.npm" -o \
        -path "*/dist" -o \
        -path "*/.bun" -o \
        -path "*/.local" -o \
        -path "*/.next" -o \
        -path "*/.expo" -o \
        -path "*/db" -o \
        -path "*/.asdf" -o \
        -path "*/build" -o \
        -path "*/__pycache__" -o \
        -path "*/.idea" -o \
        -path "*/.env" -o \
        -path "*/.vs" -o \
        -path "*/vendor" -o \
        -path "*/coverage" -o \
        -path "*/.terraform" -o \
        -path "*/.bundle" -o \
        -path "*/tmp" -o \
        -path "*/logs" -o \
        -path "*/.sass-cache" -o \
        -path "*/.docker" \
    \) -prune -o -type f -print | \
    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')
    if [ -n "$file" ]; then
        nvim "$file"
    fi
}

