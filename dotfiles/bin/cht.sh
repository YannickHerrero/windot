#!/usr/bin/env bash
languages=$(echo "javascript typescript zsh css html tmux lua svelte nodejs" | tr ' ' '\n')
core_utils=$(echo "find man tldr sed awk tr cp ls grep xargs rg ps mv kill lsof less head tail tar cp rm rename jq cat ssh cargo git git-worktree git-status git-commit git-rebase docker docker-compose stow chmod chown make" | tr ' ' '\n')

selected=$(printf "$languages\n$core_utils" | fzf)

if [[ -z $selected ]]; then
	exit 0
fi

if printf "$languages" | grep -qs $selected; then
	read -p "Enter Query: " query
	query=$(echo $query | tr ' ' '+')
	tmux neww bash -c "curl -s cht.sh/$selected/$query | less"
else
	tmux neww bash -c "curl -s cht.sh/$selected | less"
fi
