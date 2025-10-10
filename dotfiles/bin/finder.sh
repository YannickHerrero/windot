#!/bin/sh

if [ -z "$EDITOR" ]
then
  EDITOR=vi
fi

while true 
do
  SELECTED=$(CLICOLOR_FORCE=1 ls -G -a | fzf)
  if [ -z "$SELECTED" ]
  then
    exit 0
  fi

  if [ -d "$SELECTED" ]
  then
    cd $SELECTED
  else
    $EDITOR $SELECTED
  fi
done
