# Fuzzy directory finder - cd into selected directory
f() {
    local dir
    dir=$(find /home/$USER/dev /home/$USER/.config -type d \( \
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
    awk -F'/' '{if(NF>=2) print "../"$(NF-1)"/"$NF"\t"$0; else print $0"\t"$0}' | \
    fzf --delimiter='\t' --with-nth=1 \
        --preview 'ls -la --color=always {2} | grep -vE "node_modules|\.git"' \
        --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' | \
    cut -f2)
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

# Fuzzy file finder - open selected file in nvim
ff() {
    local file
    file=$(find /home/$USER/dev /home/$USER/.config -type d \( \
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
    fzf --preview 'batcat --color=always --style=numbers --line-range=:500 {}' --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')
    if [ -n "$file" ]; then
        nvim "$file"
    fi
}
