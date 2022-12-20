#!/bin/bash

. ./.bin/util.sh

DOTPATH="$HOME/dotfiles"; export DOTPATH
DOTFILES_GITHUB="https://github.com/cazuu/dotfiles.git"; export DOTFILES_GITHUB

dotfiles_logo='
      | |     | |  / _(_) |           
    __| | ___ | |_| |_ _| | ___  ___  
   / _` |/ _ \| __|  _| | |/ _ \/ __| 
  | (_| | (_) | |_| | | | |  __/\__ \ 
   \__,_|\___/ \__|_| |_|_|\___||___/ 
'

dotfiles_download() {
    if [ -d "$DOTPATH" ]; then
        e_warning "$DOTPATH: already exists"
        return
    fi

    e_header "Downloading dotfiles..."

    if is_exists "git"; then
        git clone --recursive "$DOTFILES_GITHUB" "$DOTPATH"
    elif is_exists "curl" || is_exists "wget"; then
        local tarball="https://github.com/cazuu/dotfiles/archive/master.tar.gz"
        if is_exists "curl"; then
            curl -L "$tarball"
        elif is_exists "wget"; then
            wget -O - "$tarball"
        fi | tar xvz
        if [ ! -d dotfiles-master ]; then
            echo "dotfiles-master: not found"
            exit 1
        fi
        command mv -f dotfiles-master "$DOTPATH"
    else
        echo "curl or wget required"
        exit 1
    fi

    find "$DOTPATH/.bin" -name "*.sh" | xargs chmod +x

    e_done "Download dotfiles"
}

echo "$dotfiles_logo"

e_header "[START] Dotfiles bootstrap"

dotfiles_download
make all

e_header "[END] Dotfiles bootstrap"

