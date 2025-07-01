#!/bin/bash

# Set the path to your folder
folder_path="$HOME/.password-store/"

# Check if the folder exists
if [ ! -d "$folder_path" ]; then
	echo "Folder does not exist: $folder_path"
	exit 1
fi

# Use find to get a list of files in the folder and extract only the filenames without extensions
files=$(find "$folder_path" -type f -exec basename {} \; | sed 's/\.[^.]*$//' | grep -v '^$')

# Use fzf for fuzzy searching
selected_file=$(echo "$files" | fzf --prompt="Select a file: ")

# Check if a file was selected
if [ -n "$selected_file" ]; then
	pass -c "$selected_file"
else
	echo "No password selected."
fi
