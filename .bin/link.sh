#!/usr/bin/env bash

# shellcheck source=.bin/util.sh
. "$(cd "$(dirname "$0")" && pwd)/util.sh"

DOTPATH="$(cd "$(dirname "$0")" && pwd)"

e_run 'link.sh'

for file in .zshrc .zsh_plugins.txt .Brewfile; do
    ln -fvns "$DOTPATH/$file" "$HOME/$file"
done

e_done 'link.sh'
