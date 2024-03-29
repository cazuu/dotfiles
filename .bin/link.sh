#!/usr/bin/env bash

. ./.bin/util.sh

DOTPATH="$HOME/dotfiles/.bin"

e_run 'link.sh'

if [ ! -e "$DOTPATH" ]; then
    echo "Error: Directory $DOTPATH does not exist."
    exit 1
fi

cd "$DOTPATH" || exit 1

for file in .??*; do
    [[ "$file" = ".git" ]] && continue
    [[ "$file" = ".DS_Store" ]] && continue
    [[ "$file" = ".gitignore" ]] && continue

    ln -fvns "$DOTPATH/$file" "$HOME/$file"
done

e_done 'link.sh'
