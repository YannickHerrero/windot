export PATH="$HOME/.local/bin:/snap/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

autoload -Uz compinit && compinit
zinit cdreplay -q

# Source configs (includes tools.zsh which activates mise)
for config in ~/.zsh/*.zsh; do
    source "$config"
done

# Source local/private config (not tracked by git)
[[ -f ~/.zsh/local.zsh ]] && source ~/.zsh/local.zsh
