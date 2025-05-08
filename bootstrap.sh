#!/bin/bash

# util.sh functions directly embedded
# is_exists returns true if executable $1 exists in $PATH
is_exists() {
    which "$1" >/dev/null 2>&1
    return $?
}

e_newline() {
    printf "\n"
}

e_header() {
    e_newline
    printf " \033[37;1m%s\033[m\n" "$*"
}

e_run() {
    printf " \033[37;1m%s\033[m...\033[32mRUN\033[m\n" "● $*"
}

e_error() {
    printf " \033[31m%s\033[m\n" "✖ $*" 1>&2
}

e_warning() {
    printf " \033[31m%s\033[m\n" "$*"
}

e_done() {
    printf " \033[37;1m%s\033[m...\033[32mOK\033[m\n" "✔ $*"
    e_newline
}

e_arrow() {
    printf " \033[37;1m%s\033[m\n" "➜ $*"
}

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

    # Check if curl or wget is available first
    if ! is_exists "curl" && ! is_exists "wget"; then
        e_error "curl or wget required but not found"
        exit 1
    fi

    if is_exists "git"; then
        git clone --recursive "$DOTFILES_GITHUB" "$DOTPATH"
    else
        local tarball="https://github.com/cazuu/dotfiles/archive/master.tar.gz"
        if is_exists "curl"; then
            curl -L "$tarball"
        elif is_exists "wget"; then
            wget -O - "$tarball"
        fi | tar xvz
        if [ ! -d dotfiles-master ]; then
            e_error "dotfiles-master: not found"
            exit 1
        fi
        command mv -f dotfiles-master "$DOTPATH"
    fi

    if [ -d "$DOTPATH" ]; then
        e_done "Download dotfiles"
        if [ -d "$DOTPATH/.bin" ]; then
            find "$DOTPATH/.bin" -name "*.sh" | xargs chmod +x
        fi
    else
        e_error "Failed to download dotfiles"
        exit 1
    fi
}

echo "$dotfiles_logo"

e_header "[START] Dotfiles bootstrap"

dotfiles_download

if [ -d "$DOTPATH" ]; then
    cd "$DOTPATH"
    if is_exists "make"; then
        make all
    else
        e_warning "make command not found. Please install build tools."
    fi
fi

e_header "[END] Dotfiles bootstrap"

