#!/usr/bin/env bash
thePath=$(bat ~/.dotfiles/project_list | fzf --preview "eza --tree --level=1 --git-ignore --color=always {} | head -200")
cd "$thePath"
