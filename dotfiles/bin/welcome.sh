#!/bin/bash

display_welcome() {
  echo ""
  echo "Welcome, $USER!"
  echo "Today is $(date '+%A, %B %d, %Y')"
  echo "Terminal: $TERM"
  echo ""
}

random_pokemon() {
  if command -v pokeget &> /dev/null; then
    POKEMON_COUNT=386
    
    RANDOM_NUM=$(( $RANDOM % $POKEMON_COUNT + 1 ))
    
    pokeget $RANDOM_NUM
  else
    echo "pokeget not found. Install it with:"
    echo "npm install -g pokeget"
  fi
}

display_welcome
random_pokemon
