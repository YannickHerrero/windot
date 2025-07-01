# File Navigation & Management
alias cd="z"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias tree="eza --tree --icons --level=2 ." 
alias f=". ~/.dotfiles/bin/fzf-cs.sh"         # Fuzzy finder
alias d=". ~/.dotfiles/bin/tmux-starter.sh"         # Fuzzy finder
alias add=". ~/.dotfiles/bin/add-to-tree.sh"  # Add to fuzzy finder tree

# Text Editors & Files
alias v="nvim"
alias cat="bat"
alias mkcd='function _mkcd() { mkdir -p "$1" && cd "$1" }; _mkcd'
alias vswap="rm -rf ~/.local/state/nvim/swap/"  # Clear Neovim swap files

# Git Operations
alias gadd="git diff --name-only | grep -E '\.ts$|\.tsx$|\.js$|\.mjs$' | xargs --no-run-if-empty npx prettier --write; git add ."
alias git-perso="cp ~/git-credentials-switcher/.git-credentials.perso ~/.git-credentials"
alias git-pro="cp ~/git-credentials-switcher/.git-credentials.pro ~/.git-credentials"

# Development & Tools
alias sdco="pnpm --filter workstation start --hostName sdco-js-test.cdc-habitat.fr --localhostProxyPort 443  --ssoIssuer sdco-js-test.cdc-habitat.fr"  # Start development server
alias tstart="~/.dotfiles/bin/tmux-starter.sh"    # Start Tmux session
alias psd=". ~/.dotfiles/bin/copy-password.sh"    # Password management
alias t="~/.dotfiles/bin/tmux-sessionizer.sh"  # Tmux session management

# Miscellaneous
alias p="~/.dotfiles/bin/welcome.sh"
alias val="GIT_SSH_COMMAND=\"ssh -i ~/.ssh/val-solutions\" git"
