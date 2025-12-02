eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
eval "$(zoxide init --cmd z zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
